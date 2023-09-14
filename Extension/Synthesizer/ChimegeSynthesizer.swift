//
//  ChimegeSynthesizer.swift
//  voiceExtension
//
//  Created by Erdene-Ochir Tuguldur on 21.11.22.
//

import AVFoundation
import CoreML
import Foundation
import TextNormalizerSwift

class ChimegeSynthesizer {
    struct Settings: Codable {
        var rate: Int32?
        var volume: Int32?
        var pitch: Int32?
    }

    static let documentsDirectory = try! FileManager.default.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: true)
    @JSONFileBacked<[String]>(storage: documentsDirectory.appending(component: "exposed.json")) var exposedLocales
    @JSONFileBacked<Settings>(storage: documentsDirectory.appending(component: "settings.json"), create: Settings.init) private var settings

    var rate: Int32? { get { settings?.rate } set { settings?.rate = newValue } }
    var volume: Int32? { get { settings?.volume } set { settings?.volume = newValue } }
    var pitch: Int32? { get { settings?.pitch } set { settings?.pitch = newValue } }

    let mongolian_synthesizer = MongolianSynthesizer()
    let wav_synthesizer = WavSynthesizer()
    let english_synthesizer = EnglishSynthesizer()

    let enru_normalizer = EnRuNormalizer()
    let text_normalizer = TextNormalizerSwift()
    let default_group = UserDefaults(suiteName: "group.chimege.sonur.app")!
    var lowResource : String

    private init() {
        lowResource = default_group.value(forKey: "lowResource") as? String ?? "false"
    }

    public func ensure_voice_is_loaded(voiceName: String) {
        mongolian_synthesizer.ensure_voice_is_loaded(voiceName: voiceName)
    }

    public func speak(unit: SynthAudioUnit, speechRequest: AVSpeechSynthesisProviderRequest) {
        let ssmlText = speechRequest.ssmlRepresentation
        NSLog("chimegesynth ssml: \(ssmlText)")
        let prosodyRegex = /<prosody[^>]*>/
        var ssmlBegin = ""
        var ssmlEnd = ""
        if let match = ssmlText.firstMatch(of: prosodyRegex) {
            ssmlBegin = "<speak>" + match.output
            ssmlEnd = "</prosody></speak>"
        }
        var rawText = TextUtils.xml_remover(ssmlText)
        rawText = rawText.trimmingCharacters(in: .whitespacesAndNewlines)
        NSLog("chimegesynth rawtext: \(rawText)")
        rawText = enru_normalizer.normalize(text: rawText)
        if rawText == "" {
            return
        }
        var shouldSignalOutputMutex = true
        let is_wav_synthesized = wav_synthesizer.speak(voiceName: mongolian_synthesizer.voiceName!,
                                                       unit: unit, shouldSignalOutputMutex: shouldSignalOutputMutex, text: rawText,
                                                       rate: rate!, pitch: pitch!, volume: volume!)
        if is_wav_synthesized {
            return
        }

        let lang_segmented_text = LangSegmentation.segment_text_by_language(text: rawText)
        for (lang, text) in lang_segmented_text {
            while !Thread.current.isCancelled && unit.getOutputCount() > 20000 {
                Thread.sleep(forTimeInterval: TimeInterval(floatLiteral: 0.05))
                // NSLog("chimegesynth: \(unit.output.count) waiting...")
            }
           
            NSLog("chimegesynth \(lang) \(text)")
            let text = text.trimmingCharacters(in: .whitespacesAndNewlines)
            if text == "" {
                continue
            }
            #if os(iOS)
                let mongolian = true // in iOS always read in Mongolian?
            #else
                let mongolian = lang == "mn"
            #endif
            if mongolian {
                let _config = default_group.string(forKey: "normalizer-config") ?? ""
                var normalizedTexts: [String]
                if _config.isEmpty {
                    var _input = text_normalizer.text_with_default_options(text)
                    #if os(iOS)
                    if lowResource == "false" {
                        _input["soft_threshold"] = 100
                        _input["hard_threshold"] = 130
                    }else {
                        _input["soft_threshold"] = 60
                        _input["hard_threshold"] = 80
                    }
                    
                    #endif
                    normalizedTexts = try! text_normalizer.normalize_tts_text(_input)
                } else {
                    var _cfg = try! JSONSerialization.jsonObject(with: _config.data(using: .utf8)!, options: []) as! [String: Any]
                    _cfg["text"] = text
                    #if os(iOS)
                    if lowResource == "false" {
                        _cfg["soft_threshold"] = 100
                        _cfg["hard_threshold"] = 130
                    }else {
                        _cfg["soft_threshold"] = 60
                        _cfg["hard_threshold"] = 80
                    }
                    #endif
                    normalizedTexts = try! text_normalizer.normalize_tts_text(_cfg)
                }
                NSLog("chimegesynth config string: \(_config)")
                if normalizedTexts.count == 0 {
                    normalizedTexts.append("нууц тэмдэгт")
                }
                for normalizedText in normalizedTexts {
                    let normalizedText = furtherTextNormalization(text: normalizedText.trimmingCharacters(in: .whitespacesAndNewlines))
                    NSLog("chimegesynth norm text: \(normalizedText.count) \(normalizedText)")
                    if normalizedText == "" {
                        continue
                    }
                    
                    while !Thread.current.isCancelled && unit.getOutputCount() > 20000 {
                        Thread.sleep(forTimeInterval: TimeInterval(floatLiteral: 0.05))
                        // NSLog("chimegesynth: \(unit.output.count) waiting...")
                    }

                    let mel: MLMultiArray = mongolian_synthesizer.gen_mel(normalizedText: normalizedText)
                    mongolian_synthesizer.gen_audio_stream(unit: unit, shouldSignalOutputMutex: shouldSignalOutputMutex, mel: mel,
                                                           rate: rate!, pitch: pitch!, volume: volume!)

                    if shouldSignalOutputMutex {
                        shouldSignalOutputMutex = false
                    }
                    if Thread.current.isCancelled {
                        break
                    }
                }
            } else {
                NSLog("chimegesynth en text \(ssmlBegin + text + ssmlEnd)")
                english_synthesizer.speak(unit: unit, shouldSignalOutputMutex: shouldSignalOutputMutex, text: text,
                                          ssmlBegin: ssmlBegin, ssmlEnd: ssmlEnd)
                if shouldSignalOutputMutex {
                    shouldSignalOutputMutex = false
                }
            }
            if Thread.current.isCancelled {
                break
            }
        }
    }

    private static let _single = ChimegeSynthesizer()
    static var single: ChimegeSynthesizer {
        if Thread.isMainThread { return _single }
        return DispatchQueue.main.sync { return _single }
    }
}

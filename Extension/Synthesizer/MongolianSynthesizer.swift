//
//  MongolianSynthesizer.swift
//  voiceExtension
//
//  Created by Erdene-Ochir Tuguldur on 21.11.22.
//

import CoreML
import Foundation

class MongolianSynthesizer {
    public var voiceName: String?
    var tts: ChimegeModel?
    var vocoder: ChimegeModel?

    #if os(iOS)
        let model_suffix = "_small"
        let tts_out_feature_name = "var_710"
        let vocoder_out_feature_name = "var_387"
    #else
        let model_suffix = ""
        let tts_out_feature_name = "var_710"
        let vocoder_out_feature_name = "var_1000"
    #endif

    init() {
        // ensure_voice_is_loaded(voiceName: "female2")
    }

    public func ensure_voice_is_loaded(voiceName: String) {
        var requestedVoiceName = voiceName.lowercased()
        if self.voiceName == requestedVoiceName {
            return
        }
        if requestedVoiceName == "default" && self.voiceName == nil {
            #if os(iOS)
                requestedVoiceName = "female1"
            #else
                requestedVoiceName = "female2"
            #endif
        }
        autoreleasepool {
            do {
                let conf = MLModelConfiguration()
                conf.computeUnits = .cpuOnly
                self.tts = try ChimegeModel(modelName: requestedVoiceName + model_suffix, configuration: conf)
                self.vocoder = try ChimegeModel(modelName: requestedVoiceName + model_suffix + "_vocoder", configuration: conf)
                self.voiceName = requestedVoiceName
            } catch {
                fatalError("chimegesynth can't initialize models!")
            }
        }
    }

    public func gen_mel(normalizedText: String) -> MLMultiArray {
        var mel: MLMultiArray?
        autoreleasepool {
            let seq = TextUtils.text_to_sequence(text: normalizedText)
            let speedInput: MLMultiArray = try! MLMultiArray(shape: [1], dataType: .float32)
            speedInput[0] = 1.0
            let textLengthsInput: MLMultiArray = try! MLMultiArray(shape: [1], dataType: .int32)
            textLengthsInput[0] = NSNumber(value: seq.count)
            let textInput: MLMultiArray = try! MLMultiArray(shape: [1, NSNumber(value: seq.count)], dataType: .int32)
            for i in 0 ..< seq.count {
                textInput[i] = NSNumber(value: seq[i])
            }

            do {
                let modelInput = try MLDictionaryFeatureProvider(dictionary: [
                    "text": MLFeatureValue(multiArray: textInput),
                    "text_lengths": MLFeatureValue(multiArray: textLengthsInput),
                    "speed": MLFeatureValue(multiArray: speedInput),
                ])
                mel = try self.tts!.prediction(input: modelInput, options: MLPredictionOptions(),
                                               outputFeatureName: tts_out_feature_name)
            } catch {
                NSLog("chimegesynth mel gen failed!")
                fatalError("chimegesynth mel gen failed!")
            }
            // NSLog("chimegesynth mel shape: \(mel!.shape)")
        }
        return mel!
    }

    public func gen_audio_stream(unit: SynthAudioUnit, shouldSignalOutputMutex: Bool, mel: MLMultiArray,
                                 rate: Int32, pitch: Int32, volume: Int32)
    {
        var previous_buffer: [Float32] = []
        let overlap_len = 5
        let overlap_audio_len = overlap_len * 256
        let chunk_length = 40
        let min_mel_length = 15
        let mel_length = mel.shape[2].intValue
        let last_mel_length = mel_length % chunk_length
        var sliceCount: Int = mel_length / chunk_length
        let btlt = MLArrayUtils.bartlett(len: overlap_audio_len * 2)

        var _rate: Float = 1.0
        if rate < 50 {
            _rate = 0.5 + 0.01 * Float(rate)
        } else {
            _rate = 1.0 + 0.04 * Float(rate - 50)
        }
        var _pitch: Float = 1.0
        if pitch < 50 {
            _pitch = 0.5 + 0.01 * Float(pitch)
        } else {
            _pitch = 1.0 + 0.02 * Float(pitch - 50)
        }
        let _volume = 0.02 * Float(volume)
        // NSLog("chimegesynth rate/pitch/vol \(_rate) \(_pitch) \(_volume)")
        let sonic = Sonic(sampleRate: 22050, rate: _rate, pitch: _pitch, volume: _volume)

        previous_buffer.reserveCapacity(overlap_audio_len)
        if last_mel_length < min_mel_length {
            sliceCount -= 1
        }
        var slice_index_tuples: [(Int, Int)] = []
        for i in 0 ..< sliceCount {
            slice_index_tuples.append((i * chunk_length, (i + 1) * chunk_length + overlap_len))
        }
        slice_index_tuples.append((sliceCount * chunk_length, mel_length))

        var isOutputMutexSignalled = !shouldSignalOutputMutex
        let signalOutputMutexAfterNthLoop = 1
        var loopIndex = 0
        for (start, end) in slice_index_tuples {
            if Thread.current.isCancelled {
                if !isOutputMutexSignalled {
                    isOutputMutexSignalled = true
                    unit.outputThreadMutex.signal()
                }
                break
            }

            autoreleasepool {
                var modelOutput: MLMultiArray?
                autoreleasepool {
                    do {
                        let z = try MLMultiArray(shape: [1, mel.shape[1], NSDecimalNumber(value: end - start)] as [NSNumber], dataType: .float32)
                        for i in start ..< end {
                            for j in 0 ..< mel.shape[1].intValue {
                                z[[0, j, i - start] as [NSNumber]] = mel[[0, j, i] as [NSNumber]]
                            }
                        }

                        let modelInput = try MLDictionaryFeatureProvider(dictionary: [
                            "z": MLFeatureValue(multiArray: z),
                        ])
                        modelOutput = try self.vocoder!.prediction(input: modelInput, options: MLPredictionOptions(),
                                                                   outputFeatureName: vocoder_out_feature_name)
                    } catch {
                        NSLog("chimegesynth can't vocode")
                        fatalError("chimegesynth can't vocode")
                    }
                }

                let samples_length = modelOutput!.shape[2].intValue
                var samples = [Float32]()
                samples.reserveCapacity(samples_length)
                for i in 0 ..< samples_length {
                    let key = [0, 0, i] as [NSNumber]
                    samples.append(modelOutput![key].floatValue)
                }

                if previous_buffer.count > 0 {
                    for i in 0 ..< overlap_audio_len {
                        samples[i] = samples[i] * btlt[i] + previous_buffer[i] * btlt[overlap_audio_len + i]
                    }
                }
                sonic.process(samples: Array(samples[0 ... (samples_length - overlap_audio_len - 1)]))
                var processedSamples = sonic.readProcessedSamples()
                previous_buffer.removeAll(keepingCapacity: true)
                if end == mel_length {
                    sonic.process(samples: Array(samples[(samples_length - overlap_audio_len) ... (samples_length - 1)]))
                    sonic.flush()
                    processedSamples.append(contentsOf: sonic.readProcessedSamples())
                } else {
                    previous_buffer.append(contentsOf: samples[(samples_length - overlap_audio_len) ... (samples_length - 1)])
                }

                unit.outputDispatchGroup.enter()
                unit.output.reserveCapacity(unit.output.count + processedSamples.count)
                unit.output.append(contentsOf: processedSamples)
                unit.outputTotal += processedSamples.count
                unit.outputDispatchGroup.leave()
            }

            loopIndex += 1
            if signalOutputMutexAfterNthLoop >= loopIndex && !isOutputMutexSignalled {
                isOutputMutexSignalled = true
                unit.outputThreadMutex.signal()
            }
        }

        if !isOutputMutexSignalled {
            isOutputMutexSignalled = true
            unit.outputThreadMutex.signal()
        }
    }
}

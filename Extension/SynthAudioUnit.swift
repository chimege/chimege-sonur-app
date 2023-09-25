import AVFoundation
import CoreML

enum SonurParameter: AUParameterAddress {
    case rate, volume, pitch
}

public class SynthAudioUnit: AVSpeechSynthesisProviderAudioUnit {
    private var outputBus: AUAudioUnitBus
    private var _outputBusses: AUAudioUnitBusArray!
    private var parameterObserver: NSKeyValueObservation!
    
    public var format: AVAudioFormat
    public var output: [Float32] = []
//    public var
    public var outputOffset: Int = 0
    public var outputTotal: Int = 0
    public var outputFinished = false
    public var outputDispatchGroup = DispatchGroup()
    public var outputThreadMutex = DispatchSemaphore(value: 0)
    public var is_empty = false
    private var outputThread: Thread?
    private var lowResource: String

    private var settingsVoice: UserDefaults? = UserDefaults(suiteName: "group.chimege.sonur.app")
    private var speechRequest: AVSpeechSynthesisProviderRequest? = nil

    @objc override init(componentDescription: AudioComponentDescription, options: AudioComponentInstantiationOptions) throws {
        let basicDescription = AudioStreamBasicDescription(
            mSampleRate: 22050,
            mFormatID: kAudioFormatLinearPCM,
            mFormatFlags: kAudioFormatFlagsNativeFloatPacked | kAudioFormatFlagIsNonInterleaved,
            mBytesPerPacket: 4,
            mFramesPerPacket: 1,
            mBytesPerFrame: 4,
            mChannelsPerFrame: 1,
            mBitsPerChannel: 32,
            mReserved: 0
        )
        format = AVAudioFormat(cmAudioFormatDescription: try! CMAudioFormatDescription(audioStreamBasicDescription: basicDescription))
        outputBus = try AUAudioUnitBus(format: format)
        lowResource = settingsVoice!.value(forKey: "lowResource") as? String ?? "false"
        try super.init(componentDescription: componentDescription, options: options)
        _outputBusses = AUAudioUnitBusArray(audioUnit: self, busType: AUAudioUnitBusType.output, busses: [outputBus])

        parameterTree = .createTree(withChildren: [
            AUParameterTree.createGroup(
                withIdentifier: "sonur",
                name: "ChimegeSonur",
                children: [
                    AUParameterTree.createParameter(
                        withIdentifier: "rate",
                        name: "Rate",
                        address: SonurParameter.rate.rawValue,
                        min: 0, max: 100, unit: .percent,
                        unitName: nil,
                        valueStrings: nil,
                        dependentParameters: nil
                    ),
                    AUParameterTree.createParameter(
                        withIdentifier: "volume",
                        name: "Volume",
                        address: SonurParameter.volume.rawValue,
                        min: 0, max: 100, unit: .percent,
                        unitName: nil,
                        valueStrings: nil,
                        dependentParameters: nil
                    ),
                    AUParameterTree.createParameter(
                        withIdentifier: "pitch",
                        name: "Pitch",
                        address: SonurParameter.pitch.rawValue,
                        min: 0, max: 100, unit: .percent,
                        unitName: nil,
                        valueStrings: nil,
                        dependentParameters: nil
                    ),
                ]
            ),
        ])
        parameterTree?.implementorValueProvider = { param in
            switch param.address {
            case SonurParameter.rate.rawValue: return AUValue(ChimegeSynthesizer.single.rate ?? 50)
            case SonurParameter.volume.rawValue: return AUValue(ChimegeSynthesizer.single.volume ?? 50)
            case SonurParameter.pitch.rawValue: return AUValue(ChimegeSynthesizer.single.pitch ?? 50)
            default:
                NSLog("chimegesynth unknown param \(param)")
                return 0
            }
        }
        parameterTree?.implementorValueObserver = { param, value in
            switch param.address {
            case SonurParameter.rate.rawValue: ChimegeSynthesizer.single.rate = Int32(value)
            case SonurParameter.volume.rawValue: ChimegeSynthesizer.single.volume = Int32(value)
            case SonurParameter.pitch.rawValue: ChimegeSynthesizer.single.pitch = Int32(value)
            default:
                NSLog("chimegesynth unknown param \(param)")
            }
        }
        for p in parameterTree?.allParameters ?? [] {
            if p.unit != .indexed {
                p.value = parameterTree?.implementorValueProvider(p) ?? 0
            }
        }
    }

    override public var outputBusses: AUAudioUnitBusArray {
        return _outputBusses
    }

    override public func allocateRenderResources() throws {
        try super.allocateRenderResources()
    }
    
    func getOutputCount() -> Int {
        var outputCount = 0
        outputDispatchGroup.enter()
        outputCount = output.count
        outputDispatchGroup.leave()
        return outputCount
    }

    private func performRender(
        actionFlags: UnsafeMutablePointer<AudioUnitRenderActionFlags>,
        timestamp _: UnsafePointer<AudioTimeStamp>,
        frameCount: AUAudioFrameCount,
        outputBusNumber _: Int,
        outputAudioBufferList: UnsafeMutablePointer<AudioBufferList>,
        renderEvents _: UnsafePointer<AURenderEvent>?,
        renderPull _: AURenderPullInputBlock?
    ) -> AUAudioUnitStatus {
        //        if !is_empty {
        //        }
        let unsafeBuffer = UnsafeMutableAudioBufferListPointer(outputAudioBufferList)[0]
        let frames = unsafeBuffer.mData!.assumingMemoryBound(to: Float32.self)
        frames.update(repeating: 0, count: Int(frameCount))
        if is_empty {
            actionFlags.pointee = .offlineUnitRenderAction_Complete
            is_empty = false
            return noErr
        }
        //let ssml: String = TextUtils.xml_remover(speechRequest?.ssmlRepresentation ?? "")
        //if (speechRequest != nil || ssml != "") || frameCount > (output.count - outputOffset) {
        //    usleep(1000 * 20)
        //}

        while true {
            outputDispatchGroup.enter()
            let shouldWait = !outputFinished && outputOffset >= outputTotal
            outputDispatchGroup.leave()
            if shouldWait {
                usleep(1000 * 20)
            } else {
                break
            }
        }
        
        
        if outputOffset > 10000 {
            outputDispatchGroup.enter()
            let removeparts = outputOffset - 1000
            outputTotal -= removeparts
            output.removeFirst(removeparts)
            outputOffset = 1000
            outputDispatchGroup.leave()
        }

        outputDispatchGroup.enter()

        let count = min(output.count - outputOffset, Int(frameCount))
        output.withUnsafeBufferPointer { ptr in
            frames.update(from: ptr.baseAddress!.advanced(by: self.outputOffset), count: count)
        }
        outputAudioBufferList.pointee.mBuffers.mDataByteSize = UInt32(count * MemoryLayout<Float32>.size)

        outputOffset += count
        if outputFinished && outputOffset >= outputTotal {
            self.speechRequest = nil
            NSLog("chimegesynth render complete")
            actionFlags.pointee = .offlineUnitRenderAction_Complete
            output.removeAll()
            outputOffset = 0
            outputTotal = 0
            outputFinished = false
        }

        outputDispatchGroup.leave()

        return noErr
    }

    override public var internalRenderBlock: AUInternalRenderBlock { self.performRender }

    override public func synthesizeSpeechRequest(_ speechRequest: AVSpeechSynthesisProviderRequest) {
        self.speechRequest = speechRequest
        is_empty = false
        let ssmlText = speechRequest.ssmlRepresentation
        NSLog("chimegesynth ssml: \(ssmlText)")
//        let prosodyRegex = /<prosody[^>]*>/
        var rawText = TextUtils.xml_remover(ssmlText)
        rawText = rawText.trimmingCharacters(in: .whitespacesAndNewlines)
        NSLog("chimegesynth rawtext: \(rawText)")
        rawText = EnRuNormalizer().normalize(text: rawText)
        if rawText == "" {
            is_empty = true
            return
        }
        
        let voiceName = speechRequest.voice.identifier.components(separatedBy: ".").last!
        ChimegeSynthesizer.single.ensure_voice_is_loaded(voiceName: voiceName)

        outputDispatchGroup.enter()
        output.removeAll()
        outputOffset = 0
        outputTotal = 0
        outputFinished = false
        outputThread = Thread(block: {
            ChimegeSynthesizer.single.speak(unit: self, speechRequest: speechRequest)
            self.outputDispatchGroup.enter()
            self.outputFinished = true
            self.outputDispatchGroup.leave()
        })
        outputThread?.start()
        outputDispatchGroup.leave()
        outputThreadMutex.wait()
    }

    override public func cancelSpeechRequest() {
        is_empty = false
        self.speechRequest = nil

        NSLog("chimegesynth cancelSpeechRequest")
        if outputThread != nil {
            outputThread!.cancel()
            // TODO: join
            outputThread = nil
        }

        outputDispatchGroup.enter()

        output.removeAll()
        outputOffset = 0
        outputTotal = 0
        outputFinished = false

        outputDispatchGroup.leave()
    }

    override public func messageChannel(for _: String) -> AUMessageChannel {
        class MC: AUMessageChannel {
            var settingsVoice: UserDefaults? = UserDefaults(suiteName: "group.chimege.sonur.app")
            var callHostBlock: CallHostBlock? { get { return nil } set {} }
            func callAudioUnit(_ message: [AnyHashable: Any]) -> [AnyHashable: Any] {
                var resp: [AnyHashable: Any] = [:]
                if message["initHost"] as? Bool == true {
                    let langs = ["english", "japan", "korea"]
                    resp["voiceOverLocales"] = langs
                    resp["exposedLocales"] = langs
                }
                if message["expose"] is [String] {
                    resp["exposedLocales"] = [String]()
                }
                return resp
            }
        }
        return MC()
    }

    override public var speechVoices: [AVSpeechSynthesisProviderVoice] {
        get {
            #if os(iOS)
                let languages = ["ru"]
            #else
                let languages = ["en", "ru", "hr", "bg", "uk"]
            #endif
            let voices = ["female1", "female2", "female3", "male1", "male2", "male3"]
            var list = [AVSpeechSynthesisProviderVoice]()
            for lang in languages {
                for voice in voices {
                    list.append(AVSpeechSynthesisProviderVoice(name: voice, identifier: "chimege.sonur.\(lang).\(voice)",
                                                               primaryLanguages: [lang], supportedLanguages: [lang]))
                }
            }
            return list
        }
        set {}
    }
}

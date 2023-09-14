//
//  EnglishSynthesizer.swift
//  voiceExtension
//
//  Created by Erdene-Ochir Tuguldur on 25.11.22.
//

import Foundation
import AVFoundation

class EnglishSynthesizer {
    let synthesizer: AVSpeechSynthesizer
    let settingsVoice: UserDefaults? = UserDefaults(suiteName: "group.chimege.sonur.app")
    
    init() {
        self.synthesizer = AVSpeechSynthesizer()
    }
    
    public func speak(unit: SynthAudioUnit, shouldSignalOutputMutex: Bool, text: String, ssmlBegin: String, ssmlEnd: String) {
        let voiceIdentifier = settingsVoice?.value(forKey: "voiceIdentifier") as? String ?? "com.apple.voice.compact.en-GB.Daniel"
        let ssmlUtterance = AVSpeechUtterance(ssmlRepresentation: ssmlBegin + text + ssmlEnd)
        var utterance = AVSpeechUtterance(string: text)
        if ssmlUtterance != nil {
            utterance = ssmlUtterance!
        }
        NSLog("chimegesynth voice: \(voiceIdentifier)")
        utterance.voice = AVSpeechSynthesisVoice(identifier: voiceIdentifier)
        
        let currentThread = Thread.current
        let waitUntilSynthesized = DispatchSemaphore(value: 0)
        
        var isOutputMutexSignalled = !shouldSignalOutputMutex
        let signalOutputMutexAfterNthLoop = 5
        var loopIndex = 0
        
        self.synthesizer.write(utterance) {(buffer: AVAudioBuffer) in
            guard let pcmBuffer = buffer as? AVAudioPCMBuffer else {
                fatalError("unknown buffer type: \(buffer)")
            }
            
            if pcmBuffer.frameLength == 0 {
                // Done
                //NSLog("chimegesynth english finished \(unit.mystr)")
                if !isOutputMutexSignalled {
                    isOutputMutexSignalled = true
                    unit.outputThreadMutex.signal()
                }
                waitUntilSynthesized.signal()
            } else {
                let outputLength = Int(pcmBuffer.frameLength)
                var _output = [Float32]()
                _output.reserveCapacity(outputLength)
                for i in 0..<outputLength {
                    _output.append(Float(pcmBuffer.int16ChannelData![0][i * pcmBuffer.stride]) / 32767.0)
                }
                
                unit.outputDispatchGroup.enter()
                unit.output.reserveCapacity(unit.output.count + outputLength)
                unit.output.append(contentsOf: _output)
                unit.outputTotal += outputLength
                //if unit.outputTotal < 10000 {
                //    NSLog("chimegesynth english \(unit.outputTotal) \(unit.mystr)")
                //}
                unit.outputDispatchGroup.leave()
                
                if currentThread.isCancelled {
                    self.synthesizer.stopSpeaking(at: .immediate)
                    //NSLog("chimegesynth cancelled \(unit.mystr)")
                    waitUntilSynthesized.signal()
                }
                loopIndex += 1
                if loopIndex >= signalOutputMutexAfterNthLoop && !isOutputMutexSignalled {
                    isOutputMutexSignalled = true
                    unit.outputThreadMutex.signal()
                }
            }
        }
        
        waitUntilSynthesized.wait()
    }
}

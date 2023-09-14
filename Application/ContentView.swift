// Copyright 2022 Yury Popov
//
// Permission is hereby granted, free of charge, to any person obtaining a
// copy of this software and associated documentation files (the "Software"),
// to deal in the Software without restriction, including without limitation
// the rights to use, copy, modify, merge, publish, distribute, sublicense,
// and/or sell copies of the Software, and to permit persons to whom the
// Software is furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in
// all copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL
// THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING
// FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER
// DEALINGS IN THE SOFTWARE.

import AudioToolbox
import AudioUnit
import AVFoundation
import SwiftUI

let engine = AVAudioEngine()
let playerNode = AVAudioPlayerNode()
let format = AVAudioFormat(commonFormat: .pcmFormatFloat32, sampleRate: 22050, channels: 1, interleaved: true)!
let settingsVoice: UserDefaults? = UserDefaults(suiteName: "group.chimege.sonur.app")

class _Dummy {
    @objc var voicesData: Data? { nil }
    @objc var langsData: Data? { nil }
}

struct ContentView: View {
    let audioUnit: AVAudioUnit
    let auChannel: AUMessageChannel
    var userDefaults = UserDefaults(suiteName: "group.chimege.sonur.app")!
    @State var lowResource : Bool
    
#if os(iOS)
    let audioSession = AVAudioSession.sharedInstance()
#endif
    @State var langId: String = "gmw/en-US"
    @State var voiceId: String = ""
    @State var voiceOverLocales = Set<String>()
    @State var exposedLocales = Set<String>()
    init(audioUnit: AVAudioUnit) {
        self.audioUnit = audioUnit
        auChannel = audioUnit.auAudioUnit.messageChannel(for: "sonurData")
        let lowCheck = userDefaults.value(forKey: "lowResource") as? String ?? "false"
        if lowCheck == "false"{
            self.lowResource = false
        }else{
            self.lowResource = true
        }
        
#if os(iOS)
        try? audioSession.setCategory(
            .playback,
            mode: .spokenAudio,
            policy: .default,
            options: [.duckOthers]
        )
#endif
        
        let res = auChannel.callAudioUnit?(["initHost": true])
        
        voiceOverLocales = Set(res?["voiceOverLocales"] as? [String] ?? [])
        exposedLocales = Set(res?["exposedLocales"] as? [String] ?? [])
        if engine.isRunning { engine.stop() }
        engine.attach(audioUnit)
        engine.connect(audioUnit, to: engine.outputNode, format: format)
        engine.prepare()
#if !os(iOS)
        try? engine.start()
#endif
        
        AVSpeechSynthesisProviderVoice.updateSpeechVoices()
    }
    var body: some View {
        ScrollView {
            VStack {
                
#if !os(iOS)
                VoiceSelector(settingsVoice!)
#endif
                
                ForEach(audioUnit.auAudioUnit.parameterTree?.allParameters.filter { $0.unit != .indexed } ?? [], id: \.address, content: ParameterSlider.init)
#if os(iOS)
                Toggle("Smaller RAM", isOn: $lowResource).toggleStyle(.switch).padding()
#endif
            }.padding()
            
            NormalizerOptionControl(settingsVoice!)
            
        }
        .onChange(of: exposedLocales, perform: { newValue in
            _ = self.auChannel.callAudioUnit?(["expose": newValue.sorted()])
            AVSpeechSynthesisProviderVoice.updateSpeechVoices()
        })
        .navigationTitle("Chimege Sonur")
#if os(iOS)
        .onAppear { try? audioSession.setActive(true); try? engine.start() }
        .onDisappear { engine.stop(); try? audioSession.setActive(false) }
        .onChange(of: lowResource, perform: { new_value in
            userDefaults.set(new_value, forKey: "lowResource")
        })
#endif
        .toolbar {
            NavigationLink(destination: { AboutScreen() }, label: { Image(systemName: "info.circle") })
                .accessibilityLabel("About")
        }
#if os(iOS)
        .scrollDismissesKeyboard(.immediately)
        .navigationBarTitleDisplayMode(.inline)
#endif
    }
}

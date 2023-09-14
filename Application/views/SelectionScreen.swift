import AVFoundation
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
import Foundation
import SwiftUI

struct VoiceSelectorScreen: View {
    let jp: [(id: String, name: String)]
    let kr: [(id: String, name: String)]
    let en: [(id: String, name: String)]
    let settingsVoice: UserDefaults? = UserDefaults(suiteName: "group.chimege.sonur.app")
    let userdefault: UserDefaults
//    @State private var selectedVoiceID: String = "" {
//        didSet {
//            userdefault.set(selectedVoiceID, forKey: "selectedVoice")
//        }
//    }
    @Binding private var voiceName: String
    @Binding private var selectedVoiceID: String

    init(_ userdefault: UserDefaults, _ voiceName: Binding<String>, _ selectedVoiceId: Binding<String>) {
        self.userdefault = userdefault
        let voicesKorean = AVSpeechSynthesisVoice.speechVoices().filter { $0.language == "ko-KR" }
        let voicesJapan = AVSpeechSynthesisVoice.speechVoices().filter { $0.language == "ja-JP" }
        let voicesEnglish = AVSpeechSynthesisVoice.speechVoices().filter { $0.identifier.contains("com.apple.voice") || $0.identifier.contains("com.apple.ttsbundle.siri") }
        kr = zip(voicesKorean.map { $0.identifier }, voicesKorean.map { $0.name }).map { (id: $0.0, name: $0.1) }
        jp = zip(voicesJapan.map { $0.identifier }, voicesJapan.map { $0.name }).map { (id: $0.0, name: $0.1) }
        en = zip(voicesEnglish.map { $0.identifier }, voicesEnglish.map { $0.name }).map { (id: $0.0, name: $0.1) }
        _voiceName = voiceName
        _selectedVoiceID = selectedVoiceId
    }

    func setVoice(_ voice: (id: String, name: String)) {
        voiceName = voice.name
        selectedVoiceID = voice.id
    }

    @Environment(\.presentationMode) var presentation

    var body: some View {
        List {
            Section("English") {
                ForEach(en, id: \.id) { item in
                    Button(action: {
                        settingsVoice?.set(item.name, forKey: "voiceName")
                        settingsVoice?.set(item.id, forKey: "voiceIdentifier")
                        setVoice(item)
                        self.presentation.wrappedValue.dismiss()
                    }) {
                        HStack {
                            Text(item.name + (item.id.contains("enhanced") ? " (enhanced)" : "")).frame(maxWidth: .infinity, alignment: .leading)
                            Image(systemName: "checkmark")
                                .tint(.accentColor)
                                .opacity(selectedVoiceID == item.id ? 1 : 0)
                        }
                    }.tint(.primary).buttonStyle(BorderlessButtonStyle())
                }
            }
            Section("Korean") {
                ForEach(kr, id: \.id) { item in
                    Button(action: {
                        settingsVoice?.set(item.name, forKey: "voiceName")
                        settingsVoice?.set(item.id, forKey: "voiceIdentifier")
                        setVoice(item)
                        self.presentation.wrappedValue.dismiss()
                    }) {
                        HStack {
                            Text(item.name).frame(maxWidth: .infinity, alignment: .leading)
                            Image(systemName: "checkmark")
                                .tint(.accentColor)
                                .opacity(selectedVoiceID.contains(item.id) ? 1 : 0)
                        }
                    }.tint(.primary).buttonStyle(BorderlessButtonStyle())
                }
            }
            Section("Japan") {
                ForEach(jp, id: \.id) { item in
                    Button(action: {
                        settingsVoice?.set(item.name, forKey: "voiceName")
                        settingsVoice?.set(item.id, forKey: "voiceIdentifier")
                        setVoice(item)
                        self.presentation.wrappedValue.dismiss()
                    }) {
                        HStack {
                            Text(item.name).frame(maxWidth: .infinity, alignment: .leading)
                            Image(systemName: "checkmark")
                                .tint(.accentColor)
                                .opacity(selectedVoiceID.contains(item.id) ? 1 : 0)
                        }
                    }.tint(.primary).buttonStyle(BorderlessButtonStyle())
                }
            }
        }
        #if os(macOS)
        .listStyle(InsetListStyle(alternatesRowBackgrounds: true))
        #endif
        .navigationTitle("Voices")
    }
}

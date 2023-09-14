//
//  VoiceSelector.swift
//  ChimegeSonur
//
//  Created by Work on 2022.12.12.
//

import SwiftUI

struct VoiceSelector: View {
    let userdefault: UserDefaults
    let settingsVoice: UserDefaults? = UserDefaults(suiteName: "group.chimege.sonur.app")
    @State var voicename: String {
       didSet {
            userdefault.set(voicename, forKey: "selectedVoiceName")
        }
    }
    @State var selectedVoiceID: String{
        didSet {
            userdefault.set(voicename, forKey: "selectedVoice")
        }
    }
    
    init(_ userdefault: UserDefaults) {
        self.userdefault = userdefault
        voicename = settingsVoice?.value(forKey: "voiceName") as? String ?? "Voices"
        selectedVoiceID = settingsVoice?.value(forKey: "voiceIdentifier") as? String ?? "com.apple.voice.compact.en-GB.Daniel"
    }

    var body: some View {
        HStack {
            NavigationLink(voicename) {
                VoiceSelectorScreen(userdefault, $voicename , $selectedVoiceID) 
                }
        }
    }
}

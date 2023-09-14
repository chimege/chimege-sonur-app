import SwiftUI

struct IconLinkButton: View {
    func _openURL(_ urlString: String) {
#if os(iOS)
        UIApplication.shared.open(URL(string: urlString)!)
#else
        NSWorkspace.shared.open(URL(string: urlString)!)
#endif
    }
    
    let iconName: String
    let url: String
    
    var body: some View {
        Button(action: {
            _openURL(url)
        }) { Image(iconName).resizable().tint(Color.white).frame(width: 34, height: 34) }.buttonStyle(.plain)
    }
}

struct AboutScreen: View {
    private let url = URL(string: "https://sonur.chimege.com")
#if os(iOS)
    private let platform = "iOS"
#else
    private let platform = "macOS"
#endif
    var body: some View {
        ScrollView {
            VStack(alignment: .leading ,spacing: 10) {
                Text("Chimege Sonur").font(.headline)
                #if os(iOS)
                Text("Chimege Sonur is a screen reader app for the people who visually impaired and speak Mongolian. Voice over does not currently support Mongolian, so we have included it in Russian. When setting up, go to Voice over's speech menu, click on add new language and select Russian language. After that, select Sonur on Russian language. To read alphanumeric and common characters set Russian on rotor language.")
                #else
                Text("Chimege Sonur is a screen reader app for the people who visually impaired and speak Mongolian. Voice over does not currently support Mongolian, so we have included it in English. When setting up, go to VoiceOver Utility's speech menu and select Sonur voice. And to read all the characters on the keyboard, click the add voice button, add Bulgarian, Croatian, Russian and Ukrainian languages, then go sonur all.")
                #endif
                
                Divider()
                
                Text("Contact US").font(.headline)
                Text("Phone number: 77401140")
                HStack{
                    Text("Web address:")
                    Link("https://sonur.chimege.com", destination: url!)
                }
                Divider()
                
                Text("Address").font(.headline)
                Text("City tower 4th floor 401, Sukhbaater square 8/1. Ulaanbaater, Mongolia")
            }
            .padding()
            .background(RoundedRectangle(cornerRadius: 8).foregroundColor(Color.secondaryBackground))
            .padding(.horizontal).padding(.top)
        }.navigationTitle("About")
    }
}

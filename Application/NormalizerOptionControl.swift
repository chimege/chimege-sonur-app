//
//  NormalizerOptionControl.swift
//  ChimegeSonur
//
//  Created by Chinbat on 2022.12.09.
//

import Foundation
import SwiftUI

#if os(iOS)
    let SOFT_THRESHOLD = 100
    let HARD_THRESHOLD = 130
#else
    let SOFT_THRESHOLD = 150
    let HARD_THRESHOLD = 300
#endif

private enum NormalizerOptions {
    static let default_option: [String: Any] = [
        "split_sentences": true,
        "abbreviation_level": "abbreviation",
        "read_symbols": "no_temdegt",
        "read_emojis": true,
        "use_phonemizer": true,
        "dont_read_number_n": false,
        "read_legal_number": false,
        "read_roman_number": false,
        "number_chunker": "default",
        "read_balarhai_egshig_clearly": false,
        "soft_threshold": SOFT_THRESHOLD,
        "hard_threshold": HARD_THRESHOLD,
    ]
}

struct NormalizerOptionControl: View {
    @State private var config: [String: Any]
    @State var abbreviation_level: String
    @State var read_symbols: String
    @State var read_emojis: Bool
    @State var use_phonemizer: Bool
    @State var dont_read_number_n: Bool
    @State var read_legal_number: Bool
    @State var read_roman_number: Bool
    @State var number_chunker: String

    private var userdefault: UserDefaults
    init(_ userdefault: UserDefaults) {
        let _config = String(decoding: try! JSONSerialization.data(withJSONObject: NormalizerOptions.default_option, options: .prettyPrinted), as: UTF8.self)
        var configstring: String = userdefault.string(forKey: "normalizer-config") ?? ""
        self.userdefault = userdefault

        if configstring.isEmpty {
            userdefault.set(_config, forKey: "normalizer-config")
            configstring = userdefault.string(forKey: "normalizer-config")!
        }
        let __config = try! JSONSerialization.jsonObject(with: configstring.data(using: .utf8)!, options: []) as! [String: Any]

        abbreviation_level = __config["abbreviation_level"] as! String
        read_symbols = __config["read_symbols"] as! String
        read_emojis = __config["read_emojis"] as! Bool
        use_phonemizer = __config["use_phonemizer"] as! Bool
        dont_read_number_n = __config["dont_read_number_n"] as! Bool
        read_legal_number = __config["read_legal_number"] as! Bool
        read_roman_number = __config["read_roman_number"] as! Bool
        number_chunker = __config["number_chunker"] as! String
        config = __config
    }

    static let values = [
        "abbreviation": "Abbreviate fully",
        "letter": "Letter by letter",
        "skip": "Skip",
        "default": "Smart",
        "whole": "Whole",
        "double": "By two digits",
        "single": "By single digits",
        "buh_temdegt": "All symbols",
        "tugeemel_temdegt": "Read common symbols",
        "no_temdegt": "Do not read",
    ]

    let abbr_tags = ["abbreviation", "letter", "skip"]
    let number_chunker_tags = ["default", "whole", "double", "single"]
    let symbol_tags = ["buh_temdegt", "tugeemel_temdegt", "no_temdegt"]

    var body: some View {
        VStack {
            // Toggle("Фонемайзер хэрэглэх", isOn: $use_phonemizer).toggleStyle(.switch)
            // Toggle("Өгүүлбэрийг салгах", isOn: $split_sentences).toggleStyle(.switch)
            Toggle("Read Emoji", isOn: $read_emojis).toggleStyle(.switch)
            Toggle("Leave Number Word Junctions", isOn: $dont_read_number_n).toggleStyle(.switch)
            Toggle("Read List Index Numbers", isOn: $read_legal_number).toggleStyle(.switch)
            Toggle("Read Roman Number", isOn: $read_roman_number).toggleStyle(.switch)
            // Toggle("Балархай эгшгийг тод унших", isOn: $read_balarhai_egshig_clearly).toggleStyle(.switch)

            Picker("Abbreviation Options", selection: $abbreviation_level) {
                // Text("Abbreviate fully").tag("abbreviation")
                // Text("Letter by letter").tag("letter")
                // Text("Skip").tag("skip")

                ForEach(abbr_tags, id: \.self) { tag in
                    Text(NormalizerOptionControl.values[tag]!).tag(tag)
                }
            }
            #if os(iOS)
            .pickerStyle(.navigationLink)
            #endif
            .padding(.top, 15).accessibilityHint(NormalizerOptionControl.values[abbreviation_level]! + " selected")
            Picker("Number Options", selection: $number_chunker) {
                // Text("Smart").tag("default")
                // Text("Whole").tag("whole")
                // Text("By two digits").tag("double")
                // Text("By single digits").tag("single")
                ForEach(number_chunker_tags, id: \.self) { tag in
                    Text(NormalizerOptionControl.values[tag]!).tag(tag)
                }
            }
            #if os(iOS)
            .pickerStyle(.navigationLink)
            #endif
            .padding(.top, 15).accessibilityHint(NormalizerOptionControl.values[number_chunker]! + " selected")
            Picker("Symbol Options", selection: $read_symbols) {
                // Text("All symbols").tag("buh_temdegt")
                // Text("Read common symbols").tag("tugeemel_temdegt")
                // Text("Do not read").tag("no_temdegt")
                ForEach(symbol_tags, id: \.self) { tag in
                    Text(NormalizerOptionControl.values[tag]!).tag(tag)
                }
                //                        Text("").tag("single")
            }
            #if os(iOS)
            .pickerStyle(.navigationLink)
            #endif
            .padding(.top, 15).accessibilityHint(NormalizerOptionControl.values[read_symbols]! + " selected")
            .onChange(of: abbreviation_level, perform: { new_value in
                config["abbreviation_level"] = new_value
                userdefault.set(String(decoding: try! JSONSerialization.data(withJSONObject: config), as: UTF8.self), forKey: "normalizer-config")
            })
            .onChange(of: number_chunker, perform: { new_value in
                config["number_chunker"] = new_value
                userdefault.set(String(decoding: try! JSONSerialization.data(withJSONObject: config), as: UTF8.self), forKey: "normalizer-config")
            })
            .onChange(of: read_symbols, perform: { new_value in
                config["read_symbols"] = new_value
                userdefault.set(String(decoding: try! JSONSerialization.data(withJSONObject: config), as: UTF8.self), forKey: "normalizer-config")
            })
            .onChange(of: read_emojis, perform: { new_value in
                config["read_emojis"] = new_value
                userdefault.set(String(decoding: try! JSONSerialization.data(withJSONObject: config), as: UTF8.self), forKey: "normalizer-config")
            })
            .onChange(of: use_phonemizer, perform: { new_value in
                config["use_phonemizer"] = new_value
                userdefault.set(String(decoding: try! JSONSerialization.data(withJSONObject: config), as: UTF8.self), forKey: "normalizer-config")
            })
            .onChange(of: dont_read_number_n, perform: { new_value in
                config["dont_read_number_n"] = new_value
                userdefault.set(String(decoding: try! JSONSerialization.data(withJSONObject: config), as: UTF8.self), forKey: "normalizer-config")
            })
            .onChange(of: read_legal_number, perform: { new_value in
                config["read_legal_number"] = new_value
                userdefault.set(String(decoding: try! JSONSerialization.data(withJSONObject: config), as: UTF8.self), forKey: "normalizer-config")
            })
            .onChange(of: read_roman_number, perform: { new_value in
                config["read_roman_number"] = new_value
                userdefault.set(String(decoding: try! JSONSerialization.data(withJSONObject: config), as: UTF8.self), forKey: "normalizer-config")
            })
        }.padding(.all, 20)
    }
}

//
//  ChimegeUtils.swift
//  Synth
//
//  Created by Erdene-Ochir Tuguldur on 2022.11.29.
//

import CoreML
import Foundation
import SwiftyPyRegex

func furtherTextNormalization(text: String) -> String {
    var text = text.replacingOccurrences(of: "\"", with: "")
    text = text.replacingOccurrences(of: "'", with: "")
    text = text.trimmingCharacters(in: .whitespacesAndNewlines)
    if text.count > 0 {
        let lastChar = text.suffix(1)
        if lastChar != "?" && lastChar != "!" && lastChar != "." {
            text = text + "."
        }
    }

    return text
}

enum TextUtils {
    static let symbol_to_id: [Character: Int] = {
        let symbols = "_-!'(),.:;? абвгдеёжзийклмноөпрстуүфхцчшъыьэюя"

        var _symbol_to_id: [Character: Int] = [:]
        for (index, sym) in symbols.enumerated() {
            _symbol_to_id[sym] = index
        }
        return _symbol_to_id
    }()

    static func text_to_sequence(text: String) -> [Int] {
        var sequence: [Int] = []
        for letter in text.lowercased() {
            let id = symbol_to_id[letter] ?? nil
            if id != nil {
                sequence.append(id!)
            }
        }
        return sequence
    }

    static func xml_remover(_ text: String) -> String {
        return re.sub("<[^>]*>", "", text)
    }
}

enum MLArrayUtils {
    static func bartlett(len: Int) -> [Float32] {
        var btlt: [Float32] = []
        let M = Float32(len)
        for i in 0 ..< len {
            btlt.append(Float32((((M - 1) / 2) - abs(Float32(i) - (M - 1) / 2)) * (2 / (M - 1))))
        }
        return btlt
    }
}

@available(macOS 12.0, iOS 15.0, tvOS 15.0, watchOS 8.0, *)
class ChimegeModel {
    let model: MLModel

    init(model: MLModel) {
        self.model = model
    }

    convenience init(modelName: String, configuration: MLModelConfiguration) throws {
        let bundle = Bundle(for: type(of: self))
        let urlOfModel = bundle.url(forResource: modelName, withExtension: "mlmodelc")!
        try self.init(contentsOf: urlOfModel, configuration: configuration)
    }

    convenience init(contentsOf modelURL: URL, configuration: MLModelConfiguration) throws {
        try self.init(model: MLModel(contentsOf: modelURL, configuration: configuration))
    }

    func prediction(input: MLFeatureProvider, options: MLPredictionOptions,
                    outputFeatureName: String) throws -> MLMultiArray
    {
        let outFeatures = try model.prediction(from: input, options: options)
        return outFeatures.featureValue(for: outputFeatureName)!.multiArrayValue!
    }
}

enum LangSegmentation {
    private static func _get_char_lang(c: Character) -> String {
        let characterString = String(c)
        let scalars = characterString.unicodeScalars
        let unicodeName = scalars[scalars.startIndex].properties.name
        if unicodeName == nil {
            return "other"
        }
        if unicodeName!.contains("LATIN") {
            return "en"
        }
        if unicodeName!.contains("HANGUL") {
            return "kr"
        }
        if unicodeName!.contains("CJK") {
            return "jp"
        }
        if unicodeName!.contains("HIRAGANA") {
            return "jp"
        }
        if unicodeName!.contains("KATAKANA") {
            return "jp"
        }
        if unicodeName!.contains("CYRILLIC") {
            return "mn"
        }

        return "other"
    }

    static func segment_text_by_language(text: String) -> [(String, String)] {
        var currentLang = "other"
        var currentSegment = ""
        var segments = [(String, String)]()
        for c in text {
            let cLang = _get_char_lang(c: c)
            if cLang == "other" {
                currentSegment += String(c)
            } else {
                if cLang == "other" {
                    currentLang = cLang
                    currentSegment += String(c)
                } else if cLang == currentLang {
                    currentSegment += String(c)
                } else {
                    if currentSegment.count > 0 {
                        segments.append((currentLang, currentSegment))
                    }
                    currentLang = cLang
                    currentSegment = String(c)
                }
            }
        }
        if currentLang == "other" {
            currentLang = "mn"
        }
        segments.append((currentLang, currentSegment))
        var removeids = [Int]()
        for i in 0 ..< segments.count {
            if i > 0 && segments[i - 1].0 == "other" && segments[i].0 == "mn" {
                removeids.append(i - 1)
                segments[i].1 = segments[i - 1].1 + segments[i].1
            }
        }
        segments = segments.indices.filter {
            !removeids.contains($0)
        }.map { segments[$0] }
        return segments
    }
}

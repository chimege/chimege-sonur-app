//
//  WavSynthesizer.swift
//  Synth
//
//  Created by Erdene-Ochir Tuguldur on 2022.12.14.
//

import Foundation
import AVFoundation

class WavSynthesizer {
    private var wavs: [String: String] = [:]
    
    init() {
        wavs["а"] = "a"; wavs["А"] = "tom_a"; wavs["Прописная А"] = "tom_a"
        wavs["б"] = "b"; wavs["Б"] = "tom_b"; wavs["Прописная Б"] = "tom_b"
        wavs["в"] = "v"; wavs["В"] = "tom_v"; wavs["Прописная В"] = "tom_v"
        wavs["г"] = "g"; wavs["Г"] = "tom_g"; wavs["Прописная Г"] = "tom_g"
        wavs["д"] = "d"; wavs["Д"] = "tom_d"; wavs["Прописная Д"] = "tom_d"
        wavs["е"] = "ye"; wavs["Е"] = "tom_ye"; wavs["Прописная Е"] = "tom_ye"
        wavs["ё"] = "yo"; wavs["Ё"] = "tom_yo"; wavs["Прописная Ё"] = "tom_yo"
        wavs["ж"] = "j"; wavs["Ж"] = "tom_j"; wavs["Прописная Ж"] = "tom_j"
        wavs["з"] = "z"; wavs["З"] = "tom_z"; wavs["Прописная З"] = "tom_z"
        wavs["и"] = "i"; wavs["И"] = "tom_i"; wavs["Прописная И"] = "tom_i"
        wavs["й"] = "hagas_i"; wavs["Й"] = "tom_hagas_i"; wavs["Прописная Й"] = "tom_hagas_i"
        wavs["к"] = "k"; wavs["К"] = "tom_k"; wavs["Прописная К"] = "tom_k"
        wavs["л"] = "l"; wavs["Л"] = "tom_l"; wavs["Прописная Л"] = "tom_l"
        wavs["м"] = "m"; wavs["М"] = "tom_m"; wavs["Прописная М"] = "tom_m"
        wavs["н"] = "n"; wavs["Н"] = "tom_n"; wavs["Прописная Н"] = "tom_n"
        wavs["о"] = "o"; wavs["О"] = "tom_o"; wavs["Прописная О"] = "tom_o"
        wavs["ө"] = "oe"; wavs["Ө"] = "tom_oe"
        wavs["закрытый o"] = "oe"; wavs["Прописная закрытый o"] = "tom_oe"
        wavs["п"] = "p"; wavs["П"] = "tom_p"; wavs["Прописная П"] = "tom_p"
        wavs["р"] = "r"; wavs["Р"] = "tom_r"; wavs["Прописная Р"] = "tom_r"
        wavs["с"] = "s"; wavs["С"] = "tom_s"; wavs["Прописная С"] = "tom_s"
        wavs["т"] = "t"; wavs["Т"] = "tom_t"; wavs["Прописная Т"] = "tom_t"
        wavs["у"] = "u"; wavs["У"] = "tom_u"; wavs["Прописная У"] = "tom_u"
        wavs["ү"] = "ou"; wavs["Ү"] = "tom_ou"
        wavs["у прямая"] = "ou"; wavs["Прописная у прямая"] = "tom_ou"
        wavs["ф"] = "f"; wavs["Ф"] = "tom_f"; wavs["Прописная Ф"] = "tom_f"
        wavs["х"] = "h"; wavs["Х"] = "tom_h"; wavs["Прописная Х"] = "tom_h"
        wavs["ц"] = "ts"; wavs["Ц"] = "tom_ts"; wavs["Прописная Ц"] = "tom_ts"
        wavs["ч"] = "ch"; wavs["Ч"] = "tom_ch"; wavs["Прописная Ч"] = "tom_ch"
        wavs["ш"] = "sh"; wavs["Ш"] = "tom_sh"; wavs["Прописная Ш"] = "tom_sh"
        wavs["щ"] = "sch"; wavs["Щ"] = "tom_sch"; wavs["Прописная Щ"] = "tom_sch"
        wavs["ъ"] = "hatuugiin_temdeg"; wavs["Ъ"] = "tom_hatuugiin_temdeg"; wavs["Прописная Ъ"] = "tom_hatuugiin_temdeg"
        wavs["ь"] = "zoolnii_temdeg"; wavs["Ь"] = "tom_zoolnii_temdeg"; wavs["Прописная Ь"] = "tom_zoolnii_temdeg"
        wavs["ы"] = "er_ugiin_i"; wavs["Ы"] = "tom_er_ugiin_i"; wavs["Прописная Ы"] = "tom_er_ugiin_i"
        wavs["э"] = "e"; wavs["Э"] = "tom_e"; wavs["Прописная Э"] = "tom_e"
        wavs["ю"] = "yu"; wavs["Ю"] = "tom_yu"; wavs["Прописная Ю"] = "tom_yu"
        wavs["я"] = "ya"; wavs["Я"] = "tom_ya"; wavs["Прописная Я"] = "tom_ya"
        
        wavs["0"] = "teg"; wavs["1"] = "neg"; wavs["2"] = "hoyor"; wavs["3"] = "gurav"
        wavs["4"] = "dorov"; wavs["5"] = "tav"; wavs["6"] = "zurgaa"
        wavs["7"] = "doloo"; wavs["8"] = "naim"; wavs["9"] = "yos"
        
        wavs["асуултын тэмдэг"] = "asuultiin_temdeg"; wavs["вопросительный знак"] = "asuultiin_temdeg"
        wavs["багын тэмдэг"] = "bagiin_temdeg"; wavs["меньше"] = "bagiin_temdeg"
        wavs["ихийн тэмдэг"] = "ihiin_temdeg"; wavs["больше"] = "ihiin_temdeg"
        wavs["давхар цэг"] = "davhar_tseg"; wavs["двоеточие"] = "davhar_tseg"
        wavs["цэгтэй таслал"] = "tsegtei_taslal"; wavs["точка с запятой"] = "tsegtei_taslal"
        wavs["дусал хаалт"] = "dusal_haalt"; wavs["апостроф"] = "dusal_haalt"
        wavs["хос дусал хаалт"] = "hos_dusal_haalt"; wavs["кавычка"] = "hos_dusal_haalt"
        wavs["бөхрөг зураас"] = "bohrog_zuraas"; wavs["обратный слэш"] = "bohrog_zuraas"
        wavs["босоо зураас"] = "bosoo_zuraas"; wavs["вертикальная линия"] = "bosoo_zuraas"
        wavs["их хаалт нээх"] = "zuun_goy_haalt"; wavs["левая фигурная скобка"] = "zuun_goy_haalt"
        wavs["их хаалт хаах"] = "baruun_goy_haalt"; wavs["правая фигурная скобка"] = "baruun_goy_haalt"
        wavs["дунд хаалт нээх"] = "neeh_dorvoljin_haalt"; wavs["левая квадратная скобка"] = "neeh_dorvoljin_haalt"
        wavs["дунд хаалт хаах"] = "haah_dorvoljin_haalt"; wavs["правая квадратная скобка"] = "haah_dorvoljin_haalt"
        wavs["нэмэх тэмдэг"] = "nemeh"; wavs["плюс"] = "nemeh"
        wavs["тэнцүүгийн тэмдэг"] = "tentsuugiin_temdeg"; wavs["равно"] = "tentsuugiin_temdeg"
        wavs["дундуур зураас"] = "hasah"; wavs["дефис"] = "hasah";
        wavs["доогуур зураас"] = "dooguur_zuraas"; wavs["подчеркивание"] = "dooguur_zuraas"
        wavs["бага хаалт нээх"] = "neeh_haalt"; wavs["левая скобка"] = "neeh_haalt"
        wavs["бага хаалт хаах"] = "haah_haalt"; wavs["правая скобка"] = "haah_haalt"
        wavs["од"] = "od"; wavs["звезда"] = "od"
        wavs["хувь тэмдэг"] = "huvi"; wavs["процент"] = "huvi"
        wavs["знак решётка"] = "chagt"
        wavs["восклицательный знак"] = "anhaarliin_temdeg"
        wavs["цэг"] = "tseg"; wavs["точка"] = "tseg"
        wavs["таслал"] = "taslal"; wavs["запятая"] = "taslal"
        wavs["малгай"] = "malgai"; wavs["крышка"] = "malgai"
        wavs["налуу зураас"] = "naluu_zuraas"; wavs["слэш"] = "naluu_zuraas"
        wavs["ээнд"] = "and"; wavs["ampersand"] = "and"
        wavs["ээт"] = "et"; wavs["эт (собачка)"] = "et"
        wavs["төгрөгийн тэмдэг"] = "togrog"; wavs["знак тугрика"] = "togrog"
        wavs["знак доллара"] = "долларын тэмдэг"; wavs["знак доллара"] = "dollar"
        wavs["долгио"] = "dolgio"; wavs["тильда"] = "dolgio"
        
        wavs["знак иены"] = "yen"
        wavs["знак евро"] = "euro"
        wavs["знак фунта"] = "funt"
    }
    
    public func speak(voiceName: String, unit: SynthAudioUnit, shouldSignalOutputMutex: Bool, text: String,
                      rate: Int32, pitch: Int32, volume: Int32) -> Bool {
        let wav_file = self.wavs[text]
        if wav_file == nil {
            return false
        }
        let full_wav_file = "\(voiceName)_\(wav_file!)"
        
        do {
            //let bundle = Bundle(for: type(of:self))
            let file = try AVAudioFile(forReading: Bundle.main.url(forResource: full_wav_file, withExtension:"wav")!)
            let buffer = AVAudioPCMBuffer(pcmFormat: unit.format, frameCapacity: AVAudioFrameCount(file.length))
            try file.read(into: buffer!)
            
            
            let outputLength = Int(buffer!.frameLength)
            let stride = buffer!.stride
            var _output = [Float32]()
            _output.reserveCapacity(outputLength)
            for i in 0..<outputLength {
                _output.append(buffer!.floatChannelData![0][i * stride])
            }
            
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
            var _volume = 0.02 * Float(volume)
            _rate = _rate + 0.8
            _volume = 0.8 * _volume
            let sonic = Sonic(sampleRate: 22050, rate: _rate, pitch: _pitch, volume: _volume)
            
            sonic.process(samples: _output)
            sonic.flush()
            let processedSamples = sonic.readProcessedSamples()
            
            unit.outputDispatchGroup.enter()
            unit.output.reserveCapacity(unit.output.count + processedSamples.count)
            unit.output.append(contentsOf: processedSamples)
            unit.outputTotal += processedSamples.count
            unit.outputDispatchGroup.leave()
        } catch {
            NSLog("chimegesynth wav synth failed!")
            fatalError("chimegesynth wav synth failed!")
        }
        
        if shouldSignalOutputMutex {
            unit.outputThreadMutex.signal()
        }
        
        return true
    }
}

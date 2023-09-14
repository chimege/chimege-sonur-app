//
//  ParameterSlider.swift
//  ChimegeSonur
//
//  Created by Work on 2022.12.12.
//

import SwiftUI
import AudioUnit

struct ParameterSlider: View {
        let parameter: AUParameter
        @State var value: Float
        init(_ param: AUParameter) {
            parameter = param
            value = Float(param.value)
        }

        #if os(iOS)
            private let isiOS = true
        #else
            private let isiOS = false
        #endif
        var body: some View {
            VStack {
                Text("\(parameter.displayName): \(Int32(value))")
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .accessibilityHidden(true)
                Slider(
                    value: $value,
                    in: Float(parameter.minValue) ... Float(parameter.maxValue),
                    step: 1,
                    onEditingChanged: { if !$0 { parameter.value = .init(value) } },
                    minimumValueLabel: Text("\(Int32(parameter.minValue))").accessibilityHidden(isiOS),
                    maximumValueLabel: Text("\(Int32(parameter.maxValue))").accessibilityHidden(isiOS),
                    label: {}
                )
                .accessibilityElement(children: .contain)
                .accessibilityLabel("\(Text(parameter.displayName))")
                .accessibilityHint("\(Int32(parameter.minValue))хувь to \(Int32(parameter.maxValue))хувь")
            }
            .padding()
            .background(
                RoundedRectangle(cornerRadius: 8).foregroundColor(.secondaryBackground)
            )
        }
}

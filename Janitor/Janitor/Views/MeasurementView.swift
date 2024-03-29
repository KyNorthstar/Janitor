//
//  MeasurementView.swift
//  MeasurementView
//
//  Created by Ky Leggiero on 2021-07-25.
//

import SwiftUI

import JanitorKit



struct MeasurementView<Unit: MeasurementUnit>: View {
    
    private let measurement: Measurement
    
    
    init(_ measurement: Measurement) {
        self.measurement = measurement
    }
    
    
    var body: some View {
        HStack(alignment: .firstTextBaseline, spacing: 2) {
            value
                .font(.title2)
            
            unit
                .foregroundColor(.secondary)
        }
    }
    
    
    private var value: Text {
        if #available(macOS 12.0, *) {
            return Text(measurement.value, format: FloatingPointFormatStyle())
        }
        else {
            return Text(measurement.value.description)
        }
    }
    
    
    private var unit: Text {
        return Text(measurement.unit.symbol)
    }
    
    
    
    typealias Measurement = JanitorKit.Measurement<Unit>
}



private extension MeasurementView {
    static var valueFormatter: some Formatter {
        let result = NumberFormatter()
        result.allowsFloats = true
        result.alwaysShowsDecimalSeparator = false
        result.isLenient = true
        return result
    }
}



struct MeasurementView_Previews: PreviewProvider {
    static var previews: some View {
        MeasurementView(12.days)
    }
}

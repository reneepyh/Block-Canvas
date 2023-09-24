//
//  PriceChart.swift
//  Block Canvas
//
//  Created by Renee Hsu on 2023/9/16.
//

import SwiftUI
import Charts

struct EthPriceChart: View {
    
    var ethPriceData: [EthHistoryPriceData] = []
    
    var minPrice: Double {
        ethPriceData.map { $0.price }.min() ?? 0.0
    }
    
    var maxPrice: Double {
        ethPriceData.map { $0.price }.max() ?? 0.0
    }
    
    var body: some View {
        VStack {
            GroupBox("ETH") {
                Chart {
                    ForEach(ethPriceData) {
                        LineMark(
                            x: .value("Time", $0.time, unit: .minute),
                            y: .value("Price", $0.price)
                        )
                        .interpolationMethod(.monotone)
                    }
                }
                .chartXAxis {
                    AxisMarks(preset: .aligned, values: .stride(by: .hour, count: 6)) { _ in
                        AxisValueLabel(format: .dateTime.hour(.defaultDigits(amPM: .abbreviated)))
                        AxisGridLine()
                    }
                }
                .chartYAxis {
                    AxisMarks(position: .leading)
                 }
                .chartYScale(domain: (minPrice - 10)...(maxPrice + 10))
                .padding()
            }
            .groupBoxStyle(BlankGroupBoxStyle())
        }
    }
}

struct BlankGroupBoxStyle: GroupBoxStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.content
            .background(.clear)
    }
}

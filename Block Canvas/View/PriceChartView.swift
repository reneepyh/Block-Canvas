//
//  PriceChart.swift
//  Block Canvas
//
//  Created by Renee Hsu on 2023/9/16.
//

import SwiftUI
import Charts

struct ETHPriceChart: View {
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
                        .foregroundStyle(Color(uiColor: .tertiary))
                    }
                }
                .chartBackground { chartProxy in
                    Color.init(uiColor: .primary)
                }
                .chartXAxis {
                    AxisMarks(preset: .aligned, values: .stride(by: .hour, count: 6)) { _ in
                        AxisValueLabel(format: .dateTime.hour(.defaultDigits(amPM: .abbreviated))).foregroundStyle(Color.init(uiColor: .secondaryBlur))
                        AxisGridLine().foregroundStyle(Color.init(uiColor: .secondaryBlur))
                    }
                }
                .chartYAxis {
                    AxisMarks(position: .leading) { _ in
                        AxisGridLine().foregroundStyle(Color.init(uiColor: .secondaryBlur))
                        AxisValueLabel().foregroundStyle(Color.init(uiColor: .secondaryBlur))
                    }
                 }
                .chartYScale(domain: (minPrice - 10)...(maxPrice + 10))
                .padding()
            }
            .groupBoxStyle(BlankGroupBoxStyle())
        }
    }
}

struct XTZPriceChart: View {
    var xtzPriceData: [EthHistoryPriceData] = []
    
    var minPrice: Double {
        xtzPriceData.map { $0.price }.min() ?? 0.0
    }
    
    var maxPrice: Double {
        xtzPriceData.map { $0.price }.max() ?? 0.0
    }
    
    var body: some View {
        VStack {
            GroupBox("XTZ") {
                Chart {
                    ForEach(xtzPriceData) {
                        LineMark(
                            x: .value("Time", $0.time, unit: .minute),
                            y: .value("Price", $0.price)
                        )
                        .interpolationMethod(.monotone)
                        .foregroundStyle(Color(uiColor: .tertiary))
                    }
                }
                .chartBackground { chartProxy in
                    Color.init(uiColor: .primary)
                }
                .chartXAxis {
                    AxisMarks(preset: .aligned, values: .stride(by: .hour, count: 6)) { _ in
                        AxisValueLabel(format: .dateTime.hour(.defaultDigits(amPM: .abbreviated))).foregroundStyle(Color.init(uiColor: .secondaryBlur))
                        AxisGridLine().foregroundStyle(Color.init(uiColor: .secondaryBlur))
                    }
                }
                .chartYAxis {
                    AxisMarks(position: .leading) { _ in
                        AxisGridLine().foregroundStyle(Color.init(uiColor: .secondaryBlur))
                        AxisValueLabel().foregroundStyle(Color.init(uiColor: .secondaryBlur))
                    }
                 }
                .chartYScale(domain: (minPrice - 0.05)...(maxPrice + 0.05))
                .padding()
            }
            .groupBoxStyle(BlankGroupBoxStyle())
        }
    }
}

struct BlankGroupBoxStyle: GroupBoxStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.content
            .background(Color.init(uiColor: .primary))
    }
}

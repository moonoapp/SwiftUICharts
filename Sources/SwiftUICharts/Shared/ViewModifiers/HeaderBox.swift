//
//  HeaderBox.swift
//  LineChart
//
//  Created by Will Dale on 03/01/2021.
//

import SwiftUI

/**
 Displays the metadata about the chart as well as optionally touch overlay information.
 */
internal struct HeaderBox<T>: ViewModifier where T: CTChartData {
    
    @ObservedObject private var chartData: T
    
    init(chartData: T) {
        self.chartData = chartData
    }
    
    var titleBox: some View {
        VStack(alignment: .leading) {
            Text(LocalizedStringKey(chartData.metadata.title))
                .font(chartData.metadata.titleFont)
                .foregroundColor(chartData.metadata.titleColour)
            Text(LocalizedStringKey(chartData.metadata.subtitle))
                .font(chartData.metadata.subtitleFont)
                .foregroundColor(chartData.metadata.subtitleColour)
        }
    }
    
    var touchOverlay: some View {
        VStack(alignment: touchOverlayAlignment) {
            if chartData.infoView.isTouchCurrent {
                ForEach(chartData.infoView.touchOverlayInfo, id: \.id) { point in
                    chartData.infoDescription(info: point)
                        .font(chartData.chartStyle.infoBoxDescriptionFont)
                        .foregroundColor(chartData.chartStyle.infoBoxDescriptionColour)
                    chartData.infoValueUnit(info: point)
                        .font(chartData.chartStyle.infoBoxValueFont)
                        .foregroundColor(chartData.chartStyle.infoBoxValueColour)
                }
            } else {
                Text("")
                    .font(chartData.chartStyle.infoBoxValueFont)
                Text("")
                    .font(chartData.chartStyle.infoBoxDescriptionFont)
            }
        }
    }
    
    internal func body(content: Content) -> some View {
        Group {
            #if !os(tvOS)
            if chartData.isGreaterThanTwo() {
                switch chartData.chartStyle.infoBoxPlacement {
                case .floating:
                    VStack(alignment: .leading) {
                        titleBox
                        content
                    }
                case .infoBox:
                    VStack(alignment: .leading) {
                        titleBox
                        content
                    }
                case .header:
                    VStack(alignment: .leading) {
                        if chartData.infoView.isTouchCurrent {
                            touchOverlay
                        } else {
                            titleBox
                        }
                        content
                    }
                }
            } else { content }
            #elseif os(tvOS)
            if chartData.isGreaterThanTwo() {
                VStack(alignment: .leading) {
                    titleBox
                    content
                }
            } else { content }
            #endif
        }
    }
    
    private var touchOverlayAlignment: HorizontalAlignment {
        switch chartData.chartStyle.infoBoxPlacement {
        case .header:
            return .leading
        default:
            return .trailing
        }
    }
}

extension View {
    /**
     Displays the metadata about the chart.
     
     Adds a view above the chart that displays the title and subtitle.
     If infoBoxPlacement is set to .header then the datapoint info will
     be displayed here as well.
     
     - Parameter chartData: Chart data model.
     - Returns: A  new view containing the chart with a view above
     to display metadata.
     */
    public func headerBox<T:CTChartData>(chartData: T) -> some View {
        self.modifier(HeaderBox(chartData: chartData))
    }
}

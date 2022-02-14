//
//  MediumWidget.swift
//  WidgetsExtension
//
//  Created by Yerzhan Tulepov on 12.02.2022.
//

import SwiftUI
import WidgetKit

struct MediumWidget : View {
    var entry: SolatEntry
    
    var body: some View {
        ZStack {
            Image("Background")
                .resizable()
                .aspectRatio(contentMode: .fill)
                .opacity(0.15)
            
            VStack {
                HStack {
                    Text(entry.dateByHijrah)
                        .font(.custom("Montserrat Medium", size: 14))
                    
                    Spacer()
                    
                    Text(entry.city)
                        .font(.custom("Oswald Light", size: 16))
                }.padding(.horizontal, 10)
                
                HStack {
                    SolatTime(type: AzanType.fadjr, time: entry.fadjr, isActive: entry.type == .fadjr)
                    SolatTime(type: AzanType.sunrise, time: entry.sunrise, isActive: entry.type == .sunrise)
                    SolatTime(type: AzanType.dhuhr, time: entry.dhuhr, isActive: entry.type == .dhuhr)
                    SolatTime(type: AzanType.asr, time: entry.asr, isActive: entry.type == .asr)
                    SolatTime(type: AzanType.maghrib, time: entry.maghrib, isActive: entry.type == .maghrib)
                    SolatTime(type: AzanType.isha, time: entry.isha, isActive: entry.type == .isha)
                }
            }.foregroundColor(Color.white)
                .padding(7)
        }
    }
}

struct SolatTime : View {
    let type: AzanType
    let time: String
    let isActive: Bool
    
    var body: some View {
        VStack {
            Text(type.rawValue)
                .font(.custom(isActive ? "Oswald Regular" : "Oswald Light", size: 12))
                .padding(.bottom, -5)
            
            Divider()
                .background(Color.white)
            
            Text(time)
                .font(.custom(isActive ? "Montserrat SemiBold" : "Montserrat Regular", size: 12))
                .padding(.top, -5)
        }.padding(5)
            .background(Color(red: 47 / 255, green: 128 / 255, blue: 237 / 255)
                            .opacity(isActive ? 1 : 0))
                            .clipShape(RoundedRectangle(cornerRadius: 6))
                            .shadow(radius: 3)
    }
}

struct Preview: PreviewProvider {
    static var previews: some View {
        MediumWidget(entry: Provider.previewEntry)
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(Color("WidgetBackground"))
            .previewContext(WidgetPreviewContext(family: .systemMedium))
    }
}

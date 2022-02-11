//
//  HijrahDate.swift
//  WidgetsExtension
//
//  Created by Yerzhan Tulepov on 12.02.2022.
//

import Foundation

func getCurrentHijrahDate() -> String {
    let calendar = Calendar(identifier: Calendar.Identifier.islamicUmmAlQura)
    
    let formater = DateFormatter()
    formater.calendar = calendar
    formater.locale = Locale(identifier: "ru")
    formater.dateFormat = "d MMMM yyyy"
    
    return formater.string(from: Date())
}

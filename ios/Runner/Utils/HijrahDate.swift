//
//  HijrahDate.swift
//  Runner
//
//  Created by Yerzhan Tulepov on 19.01.2022.
//

func getCurrentHidrahDate() -> String {
    let calendar = Calendar(identifier: Calendar.Identifier.islamicUmmAlQura)
    
    let formater = DateFormatter()
    formater.calendar = calendar
    formater.locale = Locale(identifier: "ru")
    formater.dateFormat = "d MMMM yyyy"
    
    return formater.string(from: Date())
}

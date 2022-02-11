//
//  MuftiyatApi.swift
//  WidgetsExtension
//
//  Created by Yerzhan Tulepov on 12.02.2022.
//

import Alamofire

struct MuftiyatApi {
    static func getTimes(latitude: String, longitude: String) async throws -> MuftiyatDto {
        let year = Calendar.current.component(.year, from: Date())
        let url = "https://namaz.muftyat.kz/kk/api/times/\(year)/\(latitude)/\(longitude)"
        return try await AF.request(url).serializingDecodable(MuftiyatDto.self).value
    }
}

struct TimesDto : Decodable {
    let date: String
    let Fajr: String
    let Sunrise: String
    let Dhuhr: String
    let Asr: String
    let Maghrib: String
    let Isha: String
}

struct MuftiyatDto : Decodable {
    let success: Bool
    let result: [TimesDto]
}

//
//  MuftiyatService.swift
//  Runner
//
//  Created by Yerzhan Tulepov on 18.01.2022.
//

import Alamofire

struct MuftiyatService {
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

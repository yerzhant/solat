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
        let url = "https://api.muftyat.kz/prayer-times/\(year)/\(latitude)/\(longitude)"
        return try await AF.request(url).serializingDecodable(MuftiyatDto.self).value
    }
}

struct TimesDto : Decodable {
    let Date: String
    let fajr: String
    let sunrise: String
    let dhuhr: String
    let asr: String
    let maghrib: String
    let isha: String
}

struct MuftiyatDto : Decodable {
    let success: Bool
    let result: [TimesDto]
}

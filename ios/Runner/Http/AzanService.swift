//
//  AzanService.swift
//  Runner
//
//  Created by Yerzhan Tulepov on 19.01.2022.
//

import Alamofire

struct AzanService {
    static func getCurrentDateByHijrah() async throws -> String {
        try await AF.request("https://azan.kz/api/site/current-date-by-hidjra").serializingString().value
    }
}

//
//  AzanApi.swift
//  WidgetsExtension
//
//  Created by Yerzhan Tulepov on 12.02.2022.
//

import Alamofire

struct AzanApi {
    static func getCurrentDateByHijrah() async throws -> String {
        try await AF.request("https://azan.kz/api/site/current-date-by-hidjra")
            .serializingString()
            .value
            .replacingOccurrences(of: "\"", with: "")
    }
}

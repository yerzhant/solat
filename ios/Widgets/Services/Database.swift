//
//  Database.swift
//  WidgetsExtension
//
//  Created by Yerzhan Tulepov on 12.02.2022.
//

import SQLite

struct Database {
    private let db: Connection
    private let timesTable = Table("times")
    
    private let dateColumn = Expression<String>("date")
    
    init() throws {
        let docsPath = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true).first!
        db = try Connection("\(docsPath)/solat.sqlite3")
    }
    
    func find(on date: String) throws -> Times? {
        try db.prepare(timesTable.filter(dateColumn == date)).map { row in
            try row.decode() as Times
        }.first
    }
}

struct Times : Codable {
    let date: String
    let fadjr: String
    let sunrise: String
    let dhuhr: String
    let asr: String
    let maghrib: String
    let isha: String
}

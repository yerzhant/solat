//
//  Database.swift
//  Runner
//
//  Created by Yerzhan Tulepov on 19.01.2022.
//

import SQLite
import Foundation

struct Database {
    private let db: Connection
    private let timesTable = Table("times")
    
    private let dateColumn = Expression<String>("date")
    private let fadjrColumn = Expression<String>("fadjr")
    private let sunriseColumn = Expression<String>("sunrise")
    private let dhuhrColumn = Expression<String>("dhuhr")
    private let asrColumn = Expression<String>("asr")
    private let maghribColumn = Expression<String>("maghrib")
    private let ishaColumn = Expression<String>("isha")
    
    init() throws {
        let docsPath = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true).first!
        db = try Connection("\(docsPath)/solat.sqlite3")
        try migrate()
    }
    
    func find(on date: String) throws -> Times? {
        try db.prepare(timesTable.filter(dateColumn == date)).map { row in
            try row.decode() as Times
        }.first
    }
    
    func replaceAll(by times: [Times]) throws {
        try db.run(timesTable.delete())
        try db.run(timesTable.insertMany(times))
    }
    
    private func migrate() throws {
        if db.version == 0 {
            try db.run(timesTable.create { t in
                t.column(dateColumn, primaryKey: true)
                t.column(fadjrColumn)
                t.column(sunriseColumn)
                t.column(dhuhrColumn)
                t.column(asrColumn)
                t.column(maghribColumn)
                t.column(ishaColumn)
            })
            
            db.version = 1
        }
    }
}

private extension Connection {
    var version: Int32 {
        get { return Int32(try! scalar("PRAGMA user_version") as! Int64)}
        set { try! run("PRAGMA user_version = \(newValue)") }
    }
}

//
//  FukuokaCSV.swift
//  FukuokaCOVID19
//
//  Created by 楢崎修二 on 2020/11/26.
//

import Foundation
import CodableCSV

var covidData: [Patient] = loadData()

let url = URL(string:
                // "https://ckan.open-governmentdata.org/dataset/8a9688c2-7b9f-4347-ad6e-de3b339ef740/resource/765d78d5-6754-43eb-850e-a658b086469b/download/400009_pref_fukuoka_covid19_patients.csv"
                "https://ckan.open-governmentdata.org/dataset/8a9688c2-7b9f-4347-ad6e-de3b339ef740/resource/6e61270c-9c69-4aee-82d2-e575b5352e51/download/400009_pref_fukuoka_covid19_patients.csv"
)!
func loadData() -> [Patient] {
    if let data = try? Data(contentsOf: url) {
        do {
            let parsed = try CSVReader.decode(input: data)
            var result: [Patient] = []
            for record in parsed.dropFirst() {
                let data: Patient = Patient(id: record[0],
                                                  code: record[1],
                                                  pref: record[2],
                                                  town: record[3],
                                                  release_date: parseDate(record[4]),
                                                  release_dayOfWeek: record[5],
                                                  sick_date: record[6],
                                                  location: record[7],
                                                  age: record[8],
                                                  gender: record[9],
                                                  patient_property: record[10],
                                                  patient_status: record[11],
                                                  patient_sympton: record[12],
                                                  patient_abroad: record[13],
                                                  appendix: record[14],
                                                  recovered: record[15],
                                                  reason_unknown: record[16],
                                                  deep_connected: record[17],
                                                  been_abroad: record[18]
                )
                result.append(data)
            }
            return result
        } catch let error {
            print(error)
            return []
        }
    }
    return []
}

func parseDate(_ str: String) -> Date {
    let formatter = DateFormatter()
    formatter.locale = Locale(identifier: "en_US_POSIX")
    formatter.dateFormat = "yyyy/MM/d"
    if let date = formatter.date(from: str) {
        return date
    } else {
        return formatter.date(from: "2020/01/01")!
    }
}

// No, 全国地方公共団体コード, 都道府県名, 市区町村名, 公表_年月日,
// 曜日, 発症_年月日, 居住地, 年代, 性別,
// 患者_属性, 患者_状態, 患者_症状, 患者_渡航歴の有無フラグ, 備考,
// 退院済フラグ, 感染経路不明, 濃厚接触者, 海外渡航歴有
public struct Patient: Codable, Identifiable {
    var elapsed: Int {
        get {
            let today = Date()
            let cal = Calendar(identifier: .gregorian)
            let days = cal.dateComponents([.day], from: release_date, to: today)
            return days.day ?? 0
        }
    }
    var release_month: String {
        get {
            let formatter = DateFormatter()
            formatter.locale = Locale(identifier: "ja_JP")
            formatter.dateFormat = "yyyy/MM"
            return formatter.string(from: self.release_date)
        }
    }

    public let id: String
    let code: String
    let pref: String
    let town: String
    let release_date: Date
    
    let release_dayOfWeek: String
    let sick_date: String
    let location: String
    let age: String
    let gender: String
    
    let patient_property: String
    let patient_status: String
    let patient_sympton: String
    let patient_abroad: String
    let appendix: String
    
    let recovered: String
    let reason_unknown: String
    let deep_connected: String
    let been_abroad: String
}

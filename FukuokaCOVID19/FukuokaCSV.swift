//
//  FukuokaCSV.swift
//  FukuokaCOVID19
//
//  Created by 楢崎修二 on 2020/11/26.
//

import Foundation
import CodableCSV

var covidData: [FukuokaCSV] = loadData()

let url = URL(string: "https://ckan.open-governmentdata.org/dataset/8a9688c2-7b9f-4347-ad6e-de3b339ef740/resource/c27769a2-8634-47aa-9714-7e21c4038dd4/download/400009_pref_fukuoka_covid19_patients.csv")!

func loadData() -> [FukuokaCSV] {
    if let data = try? Data(contentsOf: url) {
        do {
            let parsed = try CSVReader.decode(input: data)
            var result: [FukuokaCSV] = []
            for record in parsed {
                let data: FukuokaCSV = FukuokaCSV(id: record[0],
                                                  code: record[1],
                                                  pref: record[2],
                                                  town: record[3],
                                                  release_date: record[4],
                                                  release_dayOfWeek: record[5],
                                                  sick_date: record[6],
                                                  location: record[7],
                                                  age: record[8],
                                                  gender: record[9],
                                                  patient_property: "",
                                                  patient_status: "",
                                                  patient_sympton: "",
                                                  patient_abroad: "",
                                                  appendix: "",
                                                  recovered: "",
                                                  reason_unknown: record[16],
                                                  deep_connected: "",
                                                  been_abroad: ""
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

// No, 全国地方公共団体コード, 都道府県名, 市区町村名, 公表_年月日,
// 曜日, 発症_年月日, 居住地, 年代, 性別,
// 患者_属性, 患者_状態, 患者_症状, 患者_渡航歴の有無フラグ, 備考,
// 退院済フラグ, 感染経路不明, 濃厚接触者, 海外渡航歴有
public struct FukuokaCSV: Codable, Identifiable {
    public let id: String
    let code: String
    let pref: String
    let town: String
    let release_date: String
    
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

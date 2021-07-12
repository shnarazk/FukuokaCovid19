//
//  FukuokaCOVID19App.swift
//  FukuokaCOVID19
//
//  Created by 楢崎修二 on 2020/11/26.
//

import SwiftUI

@main
struct FukuokaCOVID19App: App {
    var body: some Scene {
        WindowGroup {
            ContentView(patients: covidData)
        }
    }
}

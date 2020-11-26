//
//  ContentView.swift
//  FukuokaCOVID19
//
//  Created by 楢崎修二 on 2020/11/26.
//

import SwiftUI

struct ContentView: View {
    var body: some View {
        VStack {
            Text("Hello, world! \(covidData.count)")
                .padding()
            List {
                ForEach(covidData) { p in
                    HStack {
                        Text("\(p.id): \(p.release_date), \(p.location), \(p.age), \(p.gender)")
                    }
                }
            }
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}

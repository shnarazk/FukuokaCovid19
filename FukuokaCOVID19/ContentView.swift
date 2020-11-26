//
//  ContentView.swift
//  FukuokaCOVID19
//
//  Created by 楢崎修二 on 2020/11/26.
//

import SwiftUI
import SwiftUICharts

struct ContentView: View {
    var patients: [Patient]
    var body: some View {
        VStack {
            LocationView(patients: groupByLocation(patients, threshold: 50))
            // PatientsView(patients: patients)
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView(patients: covidData)
    }
}

struct PatientsView: View {
    var patients: [Patient]
    var body: some View {
        List {
            ForEach(patients) { p in
                Text("\(p.id): \(p.release_date), \(p.location), \(p.age), \(p.gender)")
            }
        }
    }
}

struct LocationView: View {
    var patients: [(String, [Patient])]
    var body: some View {
        VStack {
            GraphView(data: patients.map {(c, p) in (c, p.count)}, title: "--")
        NavigationView {
            List {
                ForEach(patients, id: \.self.0) { g in
                    NavigationLink(destination: PatientsView(patients: g.1)) {
                        Text("\(g.0): \(g.1.count)")
                    }
                }
            }
            .navigationTitle("都市別")
        }
        }
    }
}

struct GraphView: View {
    var data: [(String, Int)]
    var title: String
    var body: some View {
        BarChartView(data: ChartData(values: data), title: title, form: ChartForm.extraLarge, dropShadow: false)
    }
}

func groupByLocation(_ list: [Patient], threshold: Int) -> [(String, [Patient])] {
    var dict: [String: [Patient]] = [:]
    var unkonwn: [Patient] = []
    for p in list {
        if p.location == "" {
            unkonwn.append(p)
            continue
        }
        let loc: String = p.location
        if nil == dict[loc] {
            dict[loc] = []
        }
        dict[loc]!.append(p)
    }
    var list: [(String, [Patient])] = []
    var misc: [Patient] = []
    for i in dict {
        if threshold <= i.value.count {
            list.append((i.key, i.value))
        } else {
            misc.append(contentsOf: i.value)
        }
    }
    list.sort(by: { $0.1.count > $1.1.count})
    if 0 < misc.count {
        list.append(("その他", misc))
    }
    if 0 < unkonwn.count {
        list.append(("不明", unkonwn))
    }
    return list
}

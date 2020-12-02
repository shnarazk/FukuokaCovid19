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
    @State var mode: Int = 1
    var body: some View {
        VStack {
            // GraphView(data: groupBy(patients, mapper: { p in p.release_month }).map {(c, p) in (c, p.count)}, title: "月別")
            GraphView(data: mode == 1 ? groupBy(patients, mapper: { p in p.release_date.to_str() }).map {(c, p) in (c, p.count)}
                        : groupByLocation(patients, threshold: 50).map {(c, p) in (c, p.count)},
                      title: mode == 1 ? "詳細" : "地域別")
            .padding()
            Picker(selection: $mode, label: EmptyView(), content: {
                Text("月別詳細").tag(1)
                Text("地域別詳細").tag(2)
            })
            .pickerStyle(SegmentedPickerStyle())
            .padding(.horizontal, 10)
            GroupView(patients: mode == 2 ? groupByLocation(patients, threshold: 50) : groupBy(patients, mapper: { p in p.release_month }),
                      title: "福岡県COVID19データ(\(patients.last(where: { _ in true })!.release_date.to_str())更新)")
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
                // p.release_mon    th
                Text("\(p.id): \(p.release_date.to_str()) (\(p.elapsed)日前), \(p.location), \(p.age), \(p.gender)")
            }
        }
    }
}

struct GroupView: View {
    var patients: [(String, [Patient])]
    var title: String
    var body: some View {
        VStack {
            // GraphView(data: patients.map {(c, p) in (c, p.count)}, title: "--")
            NavigationView {
                List {
                    ForEach(patients, id: \.self.0) { g in
                        NavigationLink(destination: PatientsView(patients: g.1)) {
                            HStack {
                                Image(systemName: "arrow.forward.circle.fill")
                                    .padding(.trailing, 10)
                                Text("\(g.0) (\(g.1.count)人)")
                                    .foregroundColor(1000 <= g.1.count ? .primary : .secondary)
                            }
                        }
                    }
                }
            }
            .navigationTitle(title)
        }
    }
}

struct GraphView: View {
    var data: [(String, Int)]
    var title: String
    var body: some View {
        BarChartView(data: ChartData(values: data), title: title,
                     form: CGSize(width: 1000, height: 250), dropShadow: true, valueSpecifier: "%.0f人"
        )
    }
}

func groupBy(_ list: [Patient], mapper: (Patient) -> String, order: ((String, [Patient]), (String, [Patient])) -> Bool = {$0.0 < $1.0 }) -> [(String, [Patient])] {
    var dict: [String: [Patient]] = [:]
    var unkonwn: [Patient] = []
    for p in list {
        let key: String = mapper(p)
        if key == "" {
            unkonwn.append(p)
            continue
        }
        if nil == dict[key] {
            dict[key] = []
        }
        dict[key]!.append(p)
    }
    var list: [(String, [Patient])] = []
    for i in dict {
        list.append((i.key, i.value))
    }
    list.sort(by: order)
    if 0 < unkonwn.count {
        list.append(("不明", unkonwn))
    }
    return list
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

extension Date {
    func to_str() -> String {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "ja_JP")
        formatter.dateStyle = .medium
        return formatter.string(from: self)
    }
}

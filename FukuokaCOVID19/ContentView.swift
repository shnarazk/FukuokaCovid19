//
//  ContentView.swift
//  FukuokaCOVID19
//
//  Created by 楢崎修二 on 2020/11/26.
//

import SwiftUI
import SwiftUICharts

enum Mode: Hashable {
    case ByAge
    case ByArea
    case ByDate
}

struct ContentView: View {
    var patients: [Patient]
    @State var mode: Mode = .ByDate
    var body: some View {
        let groupByDate = groupBy(patients.filter({ $0.elapsed < 356}), mapper: { $0.release_date.to_str() })
        let groupByMonth = groupBy(patients.filter({ $0.elapsed < 356}), mapper: { $0.release_month }, order: {$0.0 > $1.0 })
        let groupByArea = groupByLocation(patients, threshold: 50)
        let groupByAge = groupBy(patients, mapper: { $0.age })
        let title = "福岡県COVID19データ(\(patients.isEmpty ? "" : patients.last(where: { _ in true })!.release_date.to_str())更新)"
        VStack {
            GeometryReader { s in
                switch mode {
                case .ByAge:
                    GraphView(data: groupByAge.map {(c, p) in (c, p.count)}, title: "年代別", size: s.size)
                case .ByArea:
                    GraphView(data: groupByArea.map {(c, p) in (c, p.count)}, title: "地域別", size: s.size)
                case .ByDate:
                    GraphView(data: groupByDate.map {(c, p) in (c, p.count)}, title: "詳細", size: s.size)
                }
            }
            .padding(.vertical, 2)
            Picker(selection: $mode, label: EmptyView(), content: {
                Text("月別詳細").tag(Mode.ByDate)
                Text("地域別詳細").tag(Mode.ByArea)
                Text("年代別詳細").tag(Mode.ByAge)
            })
            .pickerStyle(SegmentedPickerStyle())
            .padding(.horizontal, 10)
            //.background(.regularMaterial)
            switch mode {
            case .ByAge:
                GroupView(patients: groupByAge, title: title)
            case .ByArea:
                GroupView(patients: groupByArea, title: title)
            case .ByDate:
                GroupView(patients: groupByMonth, title: title)
            }
        }
        .alert(isPresented: .constant(patients.isEmpty)) {
            Alert(title: Text("No dataset found"), message: Text("Run tomorrow"), dismissButton: .default(Text("OK")))
        }
    }
}

struct ErrorView: View {
    var body: some View {
        VStack {
            Spacer()
            Text("Can't load data") 
            Spacer()
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView(patients: covidData)
        // if covidData.isEmpty {
        // Alert(title: "No Data", message: "please run next day", dismissButton: .default(Text("OK")))
        // ErrorView()
        // }
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
                        NavigationLink(destination: PatientsView(patients: g.1.reversed())) {
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
    var size: CGSize
    var body: some View {
        BarChartView(data: ChartData(values: data), title: title,
                     form: CGSize(width: size.width - 8, height: size.height - 8), dropShadow: true, valueSpecifier: "%.0f人"
        )
        .padding(.leading, 4)
    }
}

func groupBy(_ list: [Patient], mapper: (Patient) -> String, order: ((String, [Patient]), (String, [Patient])) -> Bool = {$0.0 < $1.0 }) -> [(String, [Patient])] {
    var result: [(String, [Patient])] = []
    if list.isEmpty {
        return result
    }
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

    for i in dict {
        result.append((i.key, i.value))
    }
    result.sort(by: order)
    if 0 < unkonwn.count {
        result.append(("不明", unkonwn))
    }
    return result
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

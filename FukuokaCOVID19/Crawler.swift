//
//  Crawler.swift
//  FukuokaCOVID19
//
//  Created by 楢崎修二 on 2021/07/10.
//

import Foundation

// Input your parameters here
private var the_csv: URL?
private let startUrl = URL(string: "https://ckan.open-governmentdata.org/dataset/401000_pref_fukuoka_covid19_patients")!
private let maximumPagesToVisit = 10

// Crawler Parameters
private let semaphore = DispatchSemaphore(value: 0)
private var visitedPages: Set<URL> = []
private var pagesToVisit: Set<URL> = [startUrl]

// Crawler Core
func crawl() {
    guard visitedPages.count <= maximumPagesToVisit else {
        print("🏁 Reached max number of pages to visit")
        semaphore.signal()
        return
    }
    guard let pageToVisit = pagesToVisit.popFirst() else {
        print("🏁 No more pages to visit")
        semaphore.signal()
        return
    }
    if pageToVisit.absoluteString.contains(".csv") {
        the_csv = pageToVisit
        semaphore.signal()
        return
    }
    if visitedPages.contains(pageToVisit) {
        crawl()
    } else {
        visit(page: pageToVisit)
    }
}

private func visit(page url: URL) {
    visitedPages.insert(url)
    let task = URLSession.shared.dataTask(with: url) { data, response, error in
        defer { crawl() }
        guard
            let data = data,
            error == nil,
            let document = String(data: data, encoding: .utf8) else { return }
        parse(document: document, url: url)
    }
    print("🔎 Visiting page: \(url)")
    task.resume()
}

private func parse(document: String, url: URL) {
    func collectLinks() -> [URL] {
        let regex = try! NSRegularExpression(pattern: "https://ckan.open-governmentdata.org/dataset[^\"]*", options: [])
        let matches = regex.matches(in: document, options: [], range: NSRange(document.startIndex..<document.endIndex, in: document))
        return matches.compactMap { m in URL(string: String(document[Range(m.range, in: document)!])) }
    }
    print(collectLinks())
    collectLinks().forEach { pagesToVisit.insert($0) }
}

func find_csv() -> URL? {
    crawl()
    semaphore.wait()
    return the_csv
}

//
//  searchViewModel.swift
//  ppCalculator
//
//  Created by Jonathan Jia on 1/23/25.
//

import Foundation
import SwiftUI
import Combine

class SearchViewModel: ObservableObject {
    @Published var query: String = ""
    @Published var mode: Int = 0
    @Published var hasSearched: Bool = false
    
    @Published var mapsByMode: [Int: [Map]] = [:]
    @Published var isLoadingByMode: [Int: Bool] = [:]
    
    @Published var savedRowForMode: [Int: Int] = [:]
    
    @Published var isAuthorized: Bool = false
    
    private var currentPages: [Int: Int] = [:]
    private var canLoadMoreByMode: [Int: Bool] = [:]
    
    private let api = ApiRequests()
    
    private var cancellables = Set<AnyCancellable>()
    
    let availableModes = [0, 1, 2, 3]
    
    init() {
        api.$isAuthorized
            .receive(on: RunLoop.main)
            .sink { [weak self] auth in
                self?.isAuthorized = auth
            }
            .store(in: &cancellables)
    }
    
    func searchAllModes() {
        for mode in availableModes {
            mapsByMode[mode] = []
            currentPages[mode] = 1
            canLoadMoreByMode[mode] = true
            loadPage(for: mode)
        }
    }
    
    func loadMore(for mode: Int) {
        guard isLoadingByMode[mode] != true,
              canLoadMoreByMode[mode] == true else { return }
        
        currentPages[mode, default: 1] += 1
        loadPage(for: mode)
    }
    
    private func loadPage(for mode: Int) {
        let page = currentPages[mode] ?? 1
        isLoadingByMode[mode] = true
        
        api.getMaps(query: query, page: page, mode: mode) { [weak self] newMaps in
            guard let self = self else { return }
            if newMaps.isEmpty {
                self.canLoadMoreByMode[mode] = false
            }
            self.mapsByMode[mode, default: []].append(contentsOf: newMaps)
            self.isLoadingByMode[mode] = false
            
            self.prefetchImages(for: newMaps)
        }
    }

    
    private func prefetchImages(for maps: [Map]) {
        for map in maps {
            guard let imageURL = map.mapImageURL else { continue }
            let key = NSString(string: imageURL.absoluteString)
            
            if ImageCache.shared.object(forKey: key) != nil { continue }
            
            URLSession.shared.dataTask(with: imageURL) { data, _, _ in
                if let data = data, let image = UIImage(data: data) {
                    ImageCache.shared.setObject(image, forKey: key)
                }
            }.resume()
        }
    }
}




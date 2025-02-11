//
//  searchViewModel.swift
//  ppCalculator
//
//  Created by Jonathan Jia on 1/23/25.
//

import Foundation
import SwiftUI

class SearchViewModel: ObservableObject {
    @Published var query: String = ""
    @Published var maps: [Map] = []
    @Published var isLoading: Bool = false
    @Published var mode: Int = 0

    private var currentPage = 1
    private var canLoadMore = true
    private let api = ApiRequests()
    
    func search() {
        currentPage = 1
        canLoadMore = true
        maps.removeAll()
        loadPage()
    }
    
    func loadMore() {
        guard !isLoading, canLoadMore else { return }
        currentPage += 1
        loadPage()
    }
    
    private func loadPage() {
        isLoading = true
        
        api.getMaps(query: query, page: currentPage, mode: mode) { [weak self] in
            DispatchQueue.main.async {
                guard let self = self else { return }
                let newMaps = self.api.data
                if newMaps.isEmpty {
                    self.canLoadMore = false
                }
                self.maps.append(contentsOf: newMaps)
                self.isLoading = false
            }
        }
    }
}

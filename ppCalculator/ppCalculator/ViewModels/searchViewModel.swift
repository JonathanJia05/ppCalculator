//
//  searchViewModel.swift
//  ppCalculator
//
//  Created by Jonathan Jia on 1/23/25.
//

import Foundation
import SwiftUI

class SearchViewModel: ObservableObject {
    private let api = ApiRequests()
    
    @Published var query: String = ""
    @Published var maps: [Map] = []
    @Published var isLoading: Bool = false
    
    private var currentPage = 1
    private let baseURL = "http://127.0.0.1:8000/searchdb"
    private var canLoadMore = true
    
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
        
        let encodedQuery = query
            .lowercased()
            .addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? ""
        
        let urlString = "\(baseURL)?query=\(encodedQuery)&page=\(currentPage)"
        guard let url = URL(string: urlString) else {
            print("Invalid URL: \(urlString)")
            self.isLoading = false
            return
        }
        
        api.getMaps(from: url) {
            DispatchQueue.main.async {
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

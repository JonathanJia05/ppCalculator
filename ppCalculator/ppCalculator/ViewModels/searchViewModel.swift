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
    
    func search() {
        let baseURL = "http://127.0.0.1:8000/searchdb"
        let encodedQuery = query
            .lowercased()
            .addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? ""
        let urlString = "\(baseURL)?query=\(encodedQuery)&page=1"
        
        guard let url = URL(string: urlString) else {
            print("Invalid URL: \(urlString)")
            return
        }
        api.getMaps(from: url) {
            DispatchQueue.main.async{
                self.maps = self.api.data
            }
        }
    }
    
}

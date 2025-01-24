//
//  searchView.swift
//  ppCalculator
//
//  Created by Jonathan Jia on 1/23/25.
//

import Foundation
import SwiftUI

struct SearchView: View {
    @State private var query = ""
    @StateObject private var api = ApiRequests()
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 0) {
                    ForEach(api.data, id: \.map_id) { map in
                        mapRowView(map: map)
                    }
                }
            }
            .background(Color(red: 34/255, green: 40/255, blue: 42/255))
            .toolbarBackground(Color(red: 34/255, green: 40/255, blue: 42/255), for: .navigationBar)
            .toolbarBackground(.visible, for: .navigationBar)
            .navigationTitle("Search for a map")
            .searchable(text: $query)
            .onSubmit(of: .search) {
                guard !query.isEmpty else {
                    api.data = []
                    return
                }
                let baseURL = "http://127.0.0.1:8000/search"
                let queryString = query.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? ""
                let urlString = "\(baseURL)?query=\(queryString.lowercased())&pages=1"
                
                if let url = URL(string: urlString) {
                    api.getMaps(from: url)
                } else {
                    print("Invalid URL")
                }
            }
        }
        .environment(\.colorScheme, .dark)
    }
}


struct SearchView_Previews: PreviewProvider {
    static var previews: some View {
        SearchView()
    }
}

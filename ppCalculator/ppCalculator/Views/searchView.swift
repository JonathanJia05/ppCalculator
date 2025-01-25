//
//  SearchView.swift
//  ppCalculator
//
//  Created by Jonathan Jia on 1/23/25.
//

import SwiftUI

struct SearchView: View {
    @State private var query = ""
    @StateObject private var api = ApiRequests()
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 0) {
                    ForEach(api.data, id: \.map_id) { map in
                        NavigationLink(destination: MapView(map: map)){
                            mapRowView(map: map)
                        }
                        .buttonStyle(PlainButtonStyle())
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
                    api.data.removeAll()
                    return
                }
                
                let baseURL = "http://127.0.0.1:8000/search"
                let encodedQuery = query
                    .lowercased()
                    .addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? ""
                let urlString = "\(baseURL)?query=\(encodedQuery)&pages=1"
                
                guard let url = URL(string: urlString) else {
                    print("Invalid URL: \(urlString)")
                    return
                }
                
                api.getMaps(from: url)
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

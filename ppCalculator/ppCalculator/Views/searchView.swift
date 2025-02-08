//
//  SearchView.swift
//  ppCalculator
//
//  Created by Jonathan Jia on 1/23/25.
//

import SwiftUI

struct SearchView: View {
    @StateObject private var viewModel = SearchViewModel()
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 0) {
                    ForEach(viewModel.maps, id: \.map_id) { map in
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
            .searchable(text: $viewModel.query)

            .onSubmit(of: .search) {
                viewModel.search()
            }
            .onAppear{
                viewModel.search()
            }
        }
        .environment(\.colorScheme, .dark)
        .background(Color(red: 34/255, green: 40/255, blue: 42/255))
    }
}

struct SearchView_Previews: PreviewProvider {
    static var previews: some View {
        SearchView()
    }
}

//
//  searchView.swift
//  ppCalculator
//
//  Created by Jonathan Jia on 1/23/25.
//

import Foundation
import SwiftUI


struct searchView: View {

    @State private var searchQuery: String = ""

    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 0) {
                    ForEach(MockMapData.maps, id: \.map_id) { map in
                        mapRowView(map: map)
                    }
                }
            }
            .background(Color(red: 34/255, green: 40/255, blue: 42/255))
            .searchable(text: $searchQuery)
            .toolbarBackground(Color(red: 34/255, green: 40/255, blue: 42/255), for: .navigationBar)
            .toolbarBackground(.visible, for: .navigationBar)
            .navigationTitle("Search for a map")
        }
        .environment(\.colorScheme, .dark)
    }
}

struct SearchView_Previews: PreviewProvider {
    static var previews: some View {
        searchView()
    }
}

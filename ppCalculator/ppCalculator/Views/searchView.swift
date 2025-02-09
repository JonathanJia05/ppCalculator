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
            ZStack {
                Color(red: 34/255, green: 40/255, blue: 42/255)
                    .ignoresSafeArea()
                
                if viewModel.isLoading && viewModel.maps.isEmpty {
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle(tint: .white))
                        .scaleEffect(1.5)
                } else {
                    ScrollView {
                        LazyVStack(spacing: 0) {
                            ForEach(viewModel.maps, id: \.map_id) { map in
                                NavigationLink(destination: MapView(map: map)) {
                                    mapRowView(map: map)
                                }
                                .buttonStyle(PlainButtonStyle())
                                .onAppear {
                                    if viewModel.maps.last == map {
                                        viewModel.loadMore()
                                    }
                                }
                            }
                            if viewModel.isLoading {
                                ProgressView()
                                    .padding()
                            }
                        }
                    }
                    .scrollContentBackground(.hidden)
                }
            }
            .toolbarBackground(Color(red: 34/255, green: 40/255, blue: 42/255), for: .navigationBar)
            .toolbarBackground(.visible, for: .navigationBar)
            .navigationTitle("Search for a map")
            .searchable(text: $viewModel.query)
            .onSubmit(of: .search) {
                viewModel.search()
            }
            .onAppear {
                viewModel.search()
            }
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    HStack{
                        Button(action: {
                            viewModel.search()
                        }) {
                            Image(systemName: "house.fill")
                                .foregroundColor(.white)
                        }
                        
                        Button(action: {
                            viewModel.search()
                        }) {
                            Image(systemName: "bubble.left.fill")
                                .foregroundColor(.white)
                        }
                    }
                }
                ToolbarItemGroup(placement: .bottomBar) {
                    HStack{
                        ToggleButton(mode: 0, label: "mode-osu-small", viewModel: viewModel)
                        ToggleButton(mode: 1, label: "mode-taiko-small", viewModel: viewModel)
                        ToggleButton(mode: 2, label: "mode-fruits-small", viewModel: viewModel)
                        ToggleButton(mode: 3, label: "mode-mania-small", viewModel: viewModel)
                    }
                    .padding(.top, 31)
                }
            }
        }
        .environment(\.colorScheme, .dark)
    }
    
    struct ToggleButton: View {
        let mode: Int
        let label: String
        @ObservedObject var viewModel: SearchViewModel
        
        var body: some View {
            Button(action: {
                viewModel.mode = mode
                viewModel.search()
            }) {
                Image(label)
                    .frame(width: 50, height: 50)
                    .background(viewModel.mode == mode ? Color(red: 255/255, green: 143/255, blue: 171/255) : Color.gray)
                    .foregroundColor(.white)
                    .cornerRadius(10)
                    .animation(.easeInOut(duration: 0.1), value: viewModel.mode)
            }
        }
    }
}

struct SearchView_Previews: PreviewProvider {
    static var previews: some View {
        SearchView()
    }
}


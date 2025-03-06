//
//  SearchView.swift
//  ppCalculator
//
//  Created by Jonathan Jia on 1/23/25.
//

import SwiftUI

struct SearchView: View {
    @StateObject private var viewModel = SearchViewModel()
    @FocusState private var searchFocused: Bool
    
    @State private var scrollPosition: Int? = nil
    
    var body: some View {
        NavigationView {
            ZStack {
                Color(red: 34/255, green: 40/255, blue: 42/255)
                    .ignoresSafeArea()
                if !viewModel.isAuthorized {
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle(tint: .white))
                        .scaleEffect(1.5)
                } else {
                    
                    if (viewModel.isLoadingByMode[viewModel.mode] ?? false) &&
                        (viewModel.mapsByMode[viewModel.mode] ?? []).isEmpty {
                        ProgressView()
                            .progressViewStyle(CircularProgressViewStyle(tint: .white))
                            .scaleEffect(1.5)
                    } else {
                        ScrollView {
                            LazyVStack(spacing: 0) {
                                ForEach(viewModel.mapsByMode[viewModel.mode] ?? [], id: \.map_id) { map in
                                    NavigationLink(destination: MapView(map: map)) {
                                        mapRowView(map: map)
                                    }
                                    .buttonStyle(PlainButtonStyle())
                                    .id(map.map_id)
                                    .scrollTargetLayout()
                                    .onAppear {
                                        if let maps = viewModel.mapsByMode[viewModel.mode],
                                           map == maps.last {
                                            viewModel.loadMore(for: viewModel.mode)
                                        }
                                    }
                                }
                                if (viewModel.isLoadingByMode[viewModel.mode] ?? false) {
                                    ProgressView().padding()
                                }
                            }
                        }
                        .scrollTargetLayout()
                        .scrollPosition(id: $scrollPosition, anchor: .top)
                        
                        .onChange(of: scrollPosition) { oldValue, newValue in
                            guard let newValue = newValue else { return }
                            viewModel.savedRowForMode[viewModel.mode] = newValue
                        }
                        
                        .onChange(of: viewModel.mode) { oldMode, newMode in
                            DispatchQueue.main.async {
                                if let savedID = viewModel.savedRowForMode[newMode] {
                                    scrollPosition = savedID
                                } else {
                                    scrollPosition = viewModel.mapsByMode[newMode]?.first?.map_id
                                }
                            }
                        }
                    }
                }
            }
            .navigationTitle("Search for a map")
            .searchable(text: $viewModel.query)
            .focused($searchFocused)
            .onSubmit(of: .search) {
                searchFocused = false
                viewModel.searchAllModes()
                viewModel.hasSearched = true
            }
            .toolbar {
                toolbarTopItems
                toolbarBottomItems
            }
            .toolbarBackground(Color(red: 34/255, green: 40/255, blue: 42/255), for: .navigationBar)
            .toolbarBackground(.visible, for: .navigationBar)
            .onAppear {
                if let existingMaps = viewModel.mapsByMode[viewModel.mode],
                   !existingMaps.isEmpty {
                    if let savedId = viewModel.savedRowForMode[viewModel.mode] {
                        scrollPosition = savedId
                    } else {
                        scrollPosition = existingMaps.first?.map_id
                    }
                } else {
                    viewModel.searchAllModes()
                }
            }
        }
        .navigationViewStyle(StackNavigationViewStyle())
        .environment(\.colorScheme, .dark)
    }
        
    private var toolbarTopItems: some ToolbarContent {
        ToolbarItem(placement: .navigationBarTrailing) {
            HStack(spacing: 4) {
                Button(action: {
                    if viewModel.hasSearched {
                        viewModel.query = ""
                        viewModel.hasSearched = false
                        viewModel.searchAllModes()
                        if let firstID = viewModel.mapsByMode[viewModel.mode]?.first?.map_id {
                            scrollPosition = firstID
                        }
                    }
                }) {
                    Image(systemName: "house.fill")
                        .foregroundColor(viewModel.hasSearched ? .white : .gray)
                }
                .disabled(!viewModel.hasSearched)
                
                NavigationLink(destination: feedbackView()) {
                    Image(systemName: "bubble.left.fill")
                        .foregroundColor(.white)
                }
            }
            .padding(.trailing, 8)
        }
    }
    
    private var toolbarBottomItems: some ToolbarContent {
        ToolbarItemGroup(placement: .bottomBar) {
            HStack {
                ToggleButton(mode: 0, label: "mode-osu-small", viewModel: viewModel)
                ToggleButton(mode: 1, label: "mode-taiko-small", viewModel: viewModel)
                ToggleButton(mode: 2, label: "mode-fruits-small", viewModel: viewModel)
                ToggleButton(mode: 3, label: "mode-mania-small", viewModel: viewModel)
            }
            .padding(.top, 31)
            .padding(.bottom, 10)
        }
    }
        
    struct ToggleButton: View {
        let mode: Int
        let label: String
        @ObservedObject var viewModel: SearchViewModel
        
        var body: some View {
            Button(action: {
                viewModel.mode = mode
            }) {
                Image(label)
                    .frame(width: 50, height: 50)
                    .background(
                        viewModel.mode == mode
                        ? Color(red: 255/255, green: 143/255, blue: 171/255)
                        : Color.gray
                    )
                    .foregroundColor(.white)
                    .cornerRadius(10)
                    .animation(.easeInOut(duration: 0.1), value: viewModel.mode)
            }
        }
    }
}



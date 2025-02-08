//
//  mapView.swift
//  ppCalculator
//
//  Created by Jonathan Jia on 1/23/25.
//

import Foundation
import SwiftUI

struct MapView: View {
    
    @StateObject private var viewModel: PPViewModel
    private let map: Map
    init(map: Map) {
        self.map = map
        _viewModel = StateObject(wrappedValue: PPViewModel(map: map))
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            
            HStack{
                AsyncImage(url: viewModel.mapImageURL) { phase in
                    if let image = phase.image {
                        image
                            .resizable()
                            .frame(width: 360, height: 140)
                            .cornerRadius(8)
                    } else {
                        ProgressView()
                    }
                }
            }
            .frame(maxWidth: .infinity)
            .padding(.top, 8)
            
            HStack {
                VStack(alignment: .leading) {
                    Text(map.title)
                        .font(.headline)
                        .foregroundColor(.white)
                    Text(map.version)
                        .font(.subheadline)
                        .foregroundColor(.white)
                    Text(map.mapper)
                        .font(.caption)
                        .foregroundColor(.white)
                    Text("\(String(format: "%.2f", map.star_rating)) ⭐")
                        .font(.caption)
                        .foregroundColor(.white)
                }
                .frame(height: 80)
                Spacer()
            }
            .padding(.horizontal, 22)
            .padding(.vertical, 3)
            
            VStack{
                HStack {
                    Text("Accuracy: ")
                        .frame(width: 100, alignment: .leading)
                    TextField("100%", value: $viewModel.accuracy, format: .percent)
                        .keyboardType(.decimalPad)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .frame(width: 100)
                }
                
                HStack {
                    Text("Misses: ")
                        .frame(width: 100, alignment: .leading)
                    TextField("0", value: $viewModel.misses, format: .number)
                        .keyboardType(.numberPad)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .frame(width: 100)
                }
                
                HStack {
                    Text("Combo: ")
                        .frame(width: 100, alignment: .leading)
                    TextField("\(map.max_combo)", value: $viewModel.combo, format: .number)
                        .keyboardType(.numberPad)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .frame(width: 100)
                }
                
                HStack {
                    ToggleButton(mod: "dt", label: "DT", viewModel: viewModel)
                    ToggleButton(mod: "hr", label: "HR", viewModel: viewModel)
                    ToggleButton(mod: "hd", label: "HD", viewModel: viewModel)
                }
                .frame(maxWidth: .infinity, alignment: .center)
                .padding(.top, 10)
                
            }
            .padding()
            
            VStack{
                Button(action: {
                    viewModel.calculatePP()
                }) {
                    Text("Calculate")
                        .padding(8)
                        .background(Color.blue.opacity(0.2))
                        .cornerRadius(8)
                }
                
                if let pp = viewModel.pp {
                    Text("\(String(format: "%.2f", pp))pp")
                        .font(.title)
                        .padding(.top, 8)
                } else {
                    Text("Enter data then press Calculate!")
                        .font(.subheadline)
                        .foregroundColor(.gray)
                        .padding(.top, 8)
                }
            }
            .frame(maxWidth: .infinity, maxHeight: 100, alignment: .center)
            Spacer()
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
        .background(Color(red: 34/255, green: 40/255, blue: 42/255))
    }
    
    struct ToggleButton: View {
        let mod: String
        let label: String
        @ObservedObject var viewModel: PPViewModel
        
        var body: some View {
            Button(action: {
                viewModel.toggleMod(mod: mod)
            }) {
                Text(label)
                    .frame(width: 80, height: 50)
                    .background(viewModel.activeMods.contains(mod) ? Color(red: 255/255, green: 143/255, blue: 171/255) : Color.gray)
                    .foregroundColor(.white)
                    .cornerRadius(10)
                    .animation(.easeInOut(duration: 0.1), value: viewModel.activeMods)
            }
        }
    }

}

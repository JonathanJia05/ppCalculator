//
//  mapView.swift
//  ppCalculator
//
//  Created by Jonathan Jia on 1/23/25.
//

import Foundation
import SwiftUI

struct MapView: View {
    let map: Map
    
    @State private var accuracy: Double = 1.0
    @State private var misses: Int? = 0
    @State private var combo: Int? = nil
    @State private var mods: Int = 0
    @StateObject private var api = ApiRequests()
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            
            AsyncImage(url: URL(string: map.map_image)) { phase in
                if let image = phase.image {
                    image
                        .resizable()
                        .frame(width: 380, height: 140)
                        .cornerRadius(8)
                        .padding()
                } else {
                    ProgressView()
                }
            }
            .padding(.top, 16)
            
            VStack{
                HStack {
                    Text("Accuracy: ")
                    TextField("Accuracy", value: $accuracy, format: .percent)
                        .keyboardType(.decimalPad)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .frame(width: 100)
                }
                
                HStack {
                    Text("Misses: ")
                    TextField("Misses", value: $misses, format: .number)
                        .keyboardType(.numberPad)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .frame(width: 100)
                }
                
                HStack {
                    Text("Combo: ")
                    TextField("Combo", value: $combo, format: .number)
                        .keyboardType(.numberPad)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .frame(width: 100)
                }
                
                HStack {
                    Text("Mods: ")
                    TextField("Mods", value: $mods, format: .number)
                        .keyboardType(.numberPad)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .frame(width: 100)
                }
            }
            .padding()
            
            VStack{
                Button(action: {
                    guard let missVal = misses,
                          let comboVal = combo else {
                        print("Field empty")
                        return
                    }
                    
                    let ppRequest = PPRequest(
                        beatmap_id: map.map_id,
                        accuracy: accuracy * 100,
                        misses: missVal,
                        combo: comboVal,
                        mods: mods
                    )
                    api.getPP(with: ppRequest)
                }) {
                    Text("Calculate")
                        .padding(8)
                        .background(Color.blue.opacity(0.2))
                        .cornerRadius(8)
                }
                
                if let pp = api.pp {
                    Text("Calculated PP: \(pp)")
                        .font(.headline)
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
}

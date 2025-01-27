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
    
    @State private var accuracy: Double? = nil
    @State private var misses: Int? = nil
    @State private var combo: Int? = nil
    @State private var activeMods: Set<String> = []
    @State private var modsString: String = ""
    @StateObject private var api = ApiRequests()
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            
            HStack{
                AsyncImage(url: URL(string: map.map_image)) { phase in
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
            
            VStack{
                HStack {
                    Text("Accuracy: ")
                        .frame(width: 100, alignment: .leading)
                    TextField("100%", value: $accuracy, format: .percent)
                        .keyboardType(.decimalPad)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .frame(width: 100)
                }
                
                HStack {
                    Text("Misses: ")
                        .frame(width: 100, alignment: .leading)
                    TextField("0", value: $misses, format: .number)
                        .keyboardType(.numberPad)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .frame(width: 100)
                }
                
                HStack {
                    Text("Combo: ")
                        .frame(width: 100, alignment: .leading)
                    TextField("Max", value: $combo, format: .number)
                        .keyboardType(.numberPad)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .frame(width: 100)
                }
                
                HStack {
                    ToggleButton(mod: "dt", label: "DT", activeMods: $activeMods, modsString: $modsString)
                    ToggleButton(mod: "hr", label: "HR", activeMods: $activeMods, modsString: $modsString)
                    ToggleButton(mod: "hd", label: "HD", activeMods: $activeMods, modsString: $modsString)
                }
                .frame(maxWidth: .infinity, alignment: .center)
                .padding(.top, 10)


            }
            .padding()
            
            VStack{
                Button(action: {
                    let ppRequest = PPRequest(
                        beatmap_id: map.map_id,
                        accuracy: (accuracy ?? 1.0) * 100,
                        misses: misses ?? 0,
                        combo: combo ?? 0,
                        mods: modsString
                    )
                    api.getPP(with: ppRequest)
                }) {
                    Text("Calculate")
                        .padding(8)
                        .background(Color.blue.opacity(0.2))
                        .cornerRadius(8)
                }
                
                if let pp = api.pp {
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
}

struct ToggleButton: View {
    let mod: String
    let label: String
    @Binding var activeMods: Set<String>
    @Binding var modsString: String
    
    var body: some View {
        Button(action: {
            toggleMod()
        }) {
            Text(label)
                .frame(width: 80, height: 50)
                .background(activeMods.contains(mod) ? Color(red: 255/255, green: 143/255, blue: 171/255) : Color.gray)
                .foregroundColor(.white)
                .cornerRadius(10)
                .animation(.easeInOut(duration: 0.1), value: activeMods)
        }
    }
    
    private func toggleMod(){
        if activeMods.contains(mod) {
            activeMods.remove(mod)
        } else {
            activeMods.insert(mod)
        }
        
        modsString = activeMods.sorted().joined()
    }
}

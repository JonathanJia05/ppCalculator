//
//  ppViewModel.swift
//  ppCalculator
//
//  Created by Jonathan Jia on 1/23/25.
//

import Foundation
import SwiftUI

class PPViewModel: ObservableObject{
    @Published var accuracy: Double? = nil
    @Published var misses: Int? = nil
    @Published var combo: Int? = nil
    @Published var activeMods: Set<String> = []
    @Published var modsString: String = ""
    @Published var pp: Double? = nil
    private let api = ApiRequests()
    private let map: Map
    
    init(map: Map) {
        self.map = map
    }
    
    func calculatePP() {
        let ppRequest = PPRequest(
            beatmap_id: map.map_id,
            accuracy: (accuracy ?? 1.0) * 100,
            misses: misses ?? 0,
            combo: combo ?? 0,
            mods: modsString
        )
        api.getPP(with: ppRequest) {
            DispatchQueue.main.async{
                self.pp = self.api.pp
            }
        }
    }
    
    func toggleMod(mod: String){
        if activeMods.contains(mod) {
            activeMods.remove(mod)
        } else {
            activeMods.insert(mod)
        }
        modsString = activeMods.sorted().joined()
    }
    
    var mapImageURL: URL? {
            URL(string: map.map_image)
        }
}



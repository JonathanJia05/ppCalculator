//
//  Map.swift
//  ppCalculator
//
//  Created by Jonathan Jia on 1/23/25.
//

import Foundation
import SwiftUI

struct Map: Hashable, Codable {
    var title: String
    var version: String
    var mapper: String
    var star_rating: Double
    var map_id: Int
    var map_image: String
    var artist: String
    var max_combo: Int
    var plays: Int
}

extension Map {
    var mapImageURL: URL? {
        URL(string: map_image)
    }
}


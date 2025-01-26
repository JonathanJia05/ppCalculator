//
//  PPRequest.swift
//  ppCalculator
//
//  Created by Jonathan Jia on 1/25/25.
//

import Foundation
import SwiftUI

struct PPRequest: Hashable, Codable {
    var beatmap_id: Int
    var accuracy: Double
    var misses: Int
    var combo: Int
    var mods: Int
}

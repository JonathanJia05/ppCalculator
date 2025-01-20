//
//  Beatmap.swift
//  ppCalculator
//
//  Created by Jonathan Jia on 1/20/25.
//

import Foundation

import Foundation

struct Beatmap: Identifiable, Codable {
    let id: Int
    let title: String
    let artist: String
    let difficulty: String
    let starRating: Double
}

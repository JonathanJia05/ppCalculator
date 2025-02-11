//
//  AuthRequest.swift
//  ppCalculator
//
//  Created by Jonathan Jia on 2/11/25.
//

import Foundation
import SwiftUI

struct AuthRequest: Hashable, Codable {
    var client_id: String
    var client_secret: String
}

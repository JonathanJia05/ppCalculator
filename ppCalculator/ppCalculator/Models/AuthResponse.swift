//
//  AuthResponse.swift
//  ppCalculator
//
//  Created by Jonathan Jia on 2/11/25.
//

import Foundation
import SwiftUI

struct AuthResponse: Codable {
    var access_token: String
    var token_type: String
}

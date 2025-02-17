//
//  TokenRequest.swift
//  ppCalculator
//
//  Created by Jonathan Jia on 2/16/25.
//

import Foundation
import SwiftUI

struct TokenRequest: Hashable, Codable {
    var client_id: String
    var auth_code: String
    var code_verifier: String
}

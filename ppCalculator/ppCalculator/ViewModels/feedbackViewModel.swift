//
//  feedbackViewModel.swift
//  ppCalculator
//
//  Created by Jonathan Jia on 2/9/25.
//

import Foundation
import SwiftUI

class FeedbackViewModel: ObservableObject {
    @Published var userFeedback: String = ""
    @Published var feedbackResponse: String = ""
    private let api = ApiRequests()
    
    func feedback() {
        if self.userFeedback.isEmpty {
            self.feedbackResponse = "Field empty"
        }
        else {
            let feedbackRequest = Feedback(message: userFeedback)
            api.sendFeedback(with: feedbackRequest) {
                DispatchQueue.main.async{
                    self.feedbackResponse = self.api.feedbackResponse
                }
            }
        }
    }
}

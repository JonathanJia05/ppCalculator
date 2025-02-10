//
//  feedbackView.swift
//  ppCalculator
//
//  Created by Jonathan Jia on 2/9/25.
//

import Foundation
import SwiftUI

struct feedbackView: View {
    @StateObject private var viewModel: FeedbackViewModel
    
    init() {
            _viewModel = StateObject(wrappedValue: FeedbackViewModel())
    }
    
    var body: some View {
        VStack{
            Text("Do you have a problem or a suggestion, please let us know!")
            TextField("Write your feedback here!", text: $viewModel.userFeedback)
                .keyboardType(.numberPad)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .frame(width: 300)
            Button(action: {
                viewModel.feedback()
            }) {
                Text("Send")
                    .padding(8)
                    .background(Color.blue.opacity(0.2))
                    .cornerRadius(8)
            }

            if !viewModel.feedbackResponse.isEmpty {
                Text(viewModel.feedbackResponse)
            }

        }
    }
}

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
        ZStack{
            Color(red: 34/255, green: 40/255, blue: 42/255)
                .ignoresSafeArea()
            VStack{
                Text("Let us know if you have a problem or suggestion!")
                    .padding()
                    .font(.headline)
                
                TextEditor(text: $viewModel.userFeedback)
                    .frame(width: 300, height: 150)
                    .padding(4)
                    .overlay(
                        RoundedRectangle(cornerRadius: 8)
                            .stroke(Color.gray, lineWidth: 1)
                    )
                    .padding(.bottom, 8)
                
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
}

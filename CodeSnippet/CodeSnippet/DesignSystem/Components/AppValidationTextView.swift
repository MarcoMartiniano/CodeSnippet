//
//  AppValidationTextView.swift
//  Code Snippets
//
//  Created by Marco Antonio Martiniano on 25.03.26.
//

import SwiftUI

struct AppValidationTextView: View {
    var text: String
    var state: ValidationState
    
    enum ValidationState {
        case neutral, valid, invalid
    }
    
    var body: some View {
        Text(text)
            .font(.caption)
            .foregroundColor(color(for: state))
    }
    
    private func color(for state: ValidationState) -> Color {
        switch state {
        case .neutral: return .gray
        case .valid: return .green
        case .invalid: return .red
        }
    }
}

#Preview {
    AppValidationTextView(
        text: "",
        state: .invalid)
}

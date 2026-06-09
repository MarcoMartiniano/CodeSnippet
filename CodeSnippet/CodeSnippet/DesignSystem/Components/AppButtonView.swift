//
//  AppButtonView.swift
//  Code Snippets
//
//  Created by Marco Antonio Martiniano on 25.03.26.
//

import SwiftUI

struct AppButtonView: View {
    
    var title: String
    var backgroundColor: Color = .blue
    var isDisabled: Bool = false
    var action: () -> Void
    
    var body: some View {
        Button(title, action: action)
            .disabled(isDisabled)
            .padding()
            .frame(maxWidth: .infinity)
            .background(isDisabled ? Color.gray : backgroundColor)
            .foregroundColor(.white)
            .cornerRadius(10)
            .animation(.easeInOut, value: isDisabled)
    }
}

#Preview {
    AppButtonView(
        title: "Einloggen",
        action: {})
}

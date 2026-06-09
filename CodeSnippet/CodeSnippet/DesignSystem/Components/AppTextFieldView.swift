//
//  AppTextFieldView.swift
//  Code Snippets
//
//  Created by Marco Antonio Martiniano on 25.03.26.
//

import SwiftUI

// Custom input field style
struct CustomTextField: View {
    
    var placeholder: String
    @Binding var text: String
    
    var body: some View {
        TextField(placeholder, text: $text)
            .padding()
            .background(Color(.systemGray6))
            .cornerRadius(12)
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(Color.gray.opacity(0.2), lineWidth: 1)
            )
            .autocapitalization(.none)
    }
}

// Custom secure field with show/hide password
struct CustomSecureField: View {
    
    var placeholder: String
    @Binding var text: String
    
    @State private var isSecure: Bool = true
    
    var body: some View {
        HStack {
            
            Group {
                if isSecure {
                    SecureField(placeholder, text: $text)
                } else {
                    TextField(placeholder, text: $text)
                }
            }
            
            // Eye button
            Button(action: {
                isSecure.toggle()
            }) {
                Image(systemName: isSecure ? AppIcons.eyeSlash : AppIcons.eye)
                    .foregroundColor(.gray)
            }
        }
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(12)
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(Color.gray.opacity(0.2), lineWidth: 1)
        )
    }
}

#Preview {
    VStack {
        CustomTextField(
            placeholder: "E-Mail",
            text: .constant("")
        )
        CustomSecureField(
            placeholder: "Passwort",
            text: .constant("")
        )
    }
}

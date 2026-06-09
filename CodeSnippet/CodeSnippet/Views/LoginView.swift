//
//  LoginView.swift
//  Code Snippets
//
//  Created by Marco Antonio Martiniano on 24.03.26.
//

import SwiftUI

struct LoginView: View {

    @Environment(UserViewModel.self) private var userViewModel

    @State private var email = ""
    @State private var password = ""

    private var isFormValid: Bool {
        email.isValidEmail && !password.isEmpty
    }

    private var isShowingError: Binding<Bool> {
        Binding(
            get: {
                userViewModel.errorMessage != nil
            },
            set: { newValue in
                if !newValue {
                    userViewModel.errorMessage = nil
                }
            }
        )
    }

    var body: some View {
        NavigationStack {
            VStack(spacing: 20) {

                Text("Anmeldung")
                    .font(.largeTitle)
                    .bold()
                    .padding(.top, 50)

                CustomTextField(
                    placeholder: "E-Mail",
                    text: $email
                )

                CustomSecureField(
                    placeholder: "Passwort",
                    text: $password
                )

                AppButtonView(
                    title: "Einloggen",
                    backgroundColor: .blue,
                    isDisabled: !isFormValid
                ) {
                    userViewModel.loginWithEmail(
                        email: email,
                        password: password
                    )
                }

                DividerWithText()

                AppButtonView(
                    title: "Anonym fortfahren",
                    backgroundColor: .green
                ) {
                    userViewModel.loginAnonymously()
                }

                NavigationLink {
                    RegisterView()
                } label: {
                    Text("Noch kein Konto? Registrieren")
                        .foregroundStyle(.blue)
                        .underline()
                }
                .padding(.top, 10)

                Spacer()
            }
            .padding()
            .alert(
                "Fehler",
                isPresented: isShowingError
            ) {
                Button("OK") {
                    userViewModel.errorMessage = nil
                }
            } message: {
                Text(userViewModel.errorMessage ?? "")
            }
        }
    }
}

struct DividerWithText: View {
    
    var text: String = "oder"
    
    var body: some View {
        HStack {
            Rectangle()
                .frame(height: 1)
                .foregroundColor(.gray.opacity(0.3))
            
            Text(text)
                .font(.caption)
                .foregroundColor(.gray)
            
            Rectangle()
                .frame(height: 1)
                .foregroundColor(.gray.opacity(0.3))
        }
    }
}

#Preview {
    LoginView()
        .environment(UserViewModel())
}

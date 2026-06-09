//
//  RegisterView.swift
//  Code Snippets
//
//  Created by Marco Antonio Martiniano on 24.03.26.
//

import SwiftUI

struct RegisterView: View {

    @Environment(UserViewModel.self) private var userViewModel

    @State private var email = ""
    @State private var password = ""
    @State private var name = ""
    @State private var birthDate = Date()
    @State private var gender: Gender = .male
    @State private var profession: Profession = .student

    private var isFormValid: Bool {
        email.isValidEmail &&
        password.count >= 6 &&
        !name.isEmpty
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

    private let genders = Gender.allCases
    private let professions = Profession.allCases

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 30) {

                Text("Registrieren")
                    .font(.largeTitle)
                    .bold()
                    .padding(.bottom, 40)

                VStack {
                    CustomTextField(
                        placeholder: "Name",
                        text: $name
                    )

                    EmailPasswordSection(
                        email: $email,
                        password: $password
                    )
                }

                PersonalInfoSection(
                    birthDate: $birthDate,
                    gender: $gender,
                    profession: $profession,
                    genders: genders,
                    professions: professions
                )

                AppButtonView(
                    title: "Konto erstellen",
                    backgroundColor: .green,
                    isDisabled: !isFormValid
                ) {
                    userViewModel.registerWithEmail(
                        email: email,
                        password: password,
                        name: name,
                        birthDate: birthDate,
                        gender: gender,
                        profession: profession
                    )
                }

                Spacer()
            }
            .padding()
        }
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

// MARK: - Subview: Email & Password
struct EmailPasswordSection: View {
    
    @Binding var email: String
    @Binding var password: String
    
    var body: some View {
        VStack(alignment: .center, spacing: 15) {
            CustomTextField(placeholder: "E-Mail", text: $email)
            CustomSecureField(placeholder: "Passwort", text: $password)
            Text("Das Passwort muss mindestens 6 Zeichen lang sein.")
                .font(.footnote)
                .foregroundColor(.gray)
        }
    }
}

// MARK: - Subview: Personal Information
struct PersonalInfoSection: View {
    @Binding var birthDate: Date
    @Binding var gender: Gender
    @Binding var profession: Profession
    
    let genders: [Gender]
    let professions: [Profession]
    
    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            
            // Birth Date Picker
            DatePicker("Geburtsdatum", selection: $birthDate, displayedComponents: .date)
                .environment(\.locale, Locale(identifier: "en_US"))
            
            // Profession Picker
            HStack {
                Text("Beruf")
                Spacer()
                Picker("Beruf", selection: $profession) {
                    ForEach(professions, id: \.self) { p in
                        Text(p.rawValue.capitalized)
                    }
                }
                .pickerStyle(MenuPickerStyle())
            }
            
            // Gender Picker
            Picker("Geschlecht", selection: $gender) {
                ForEach(genders, id: \.self) { g in
                    Text(g.rawValue.capitalized)
                }
            }
            .pickerStyle(SegmentedPickerStyle())
        }
    }
}

// MARK: - Preview
#Preview {
    RegisterView()
        .environment(UserViewModel())
}

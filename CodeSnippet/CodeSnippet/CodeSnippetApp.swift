//
//  CodeSnippetApp.swift
//  CodeSnippet
//
//  Created by Marco Antonio Martiniano on 09.06.26.
//

import SwiftUI
import FirebaseCore

@main
struct CodeSnippetApp: App {

    @State private var userViewModel: UserViewModel

    init() {
        FirebaseApp.configure()
        _userViewModel = State(wrappedValue: UserViewModel())
    }

    var body: some Scene {
        WindowGroup {
            if userViewModel.isLoggedIn {
                SnippetListView()
                    .environment(userViewModel)
            } else {
                LoginView()
                    .environment(userViewModel)
            }
        }
    }
}


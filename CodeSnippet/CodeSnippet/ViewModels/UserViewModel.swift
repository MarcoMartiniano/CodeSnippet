//
//  UserViewModel.swift
//  Code Snippets
//
//  Created by Marco Antonio Martiniano on 24.03.26.
//

import Foundation
import FirebaseAuth
import SwiftUI

@Observable
// MARK: - UserViewModel
class UserViewModel {
    
    // Published Firestore user
   var user: FireUser?
    
    // Error messages for UI display
    var errorMessage: String?
    
    // MARK: - Init
    init() {
        checkCurrentUser()
    }
    
    // MARK: - Check Current User
    /// Checks if a user is already logged in and fetches FireUser from Firestore
    func checkCurrentUser() {
        guard let currentUser = FirebaseManager.shared.auth.currentUser else { return }
        fetchUser(id: currentUser.uid)
        print("Existing user found:", currentUser.uid)
    }
    
    // MARK: - Anonymous Login
    /// Logs in anonymously and creates a FireUser document
    func loginAnonymously() {
        FirebaseManager.shared.loginAnonymously { [weak self] result in
            switch result {
            case .success(let authUser):
                let fireUser = FireUser(id: authUser.uid, registeredOn: Date())
                
                // Save using the dedicated createUserDocument method
                FirebaseManager.shared.createUserDocument(fireUser) { res in
                    DispatchQueue.main.async {
                        switch res {
                        case .success():
                            self?.user = fireUser
                        case .failure(let error):
                            self?.errorMessage = error.localizedDescription
                        }
                    }
                }
                
            case .failure(let error):
                DispatchQueue.main.async {
                    self?.errorMessage = error.localizedDescription
                }
            }
        }
    }
    
    // MARK: - Register with Email
    /// Registers a new user with email/password and saves additional information
    func registerWithEmail(email: String,
                           password: String,
                           name: String,
                           birthDate: Date,
                           gender: Gender,
                           profession: Profession) {
        
        FirebaseManager.shared.registerWithEmail(email: email, password: password) { [weak self] result in
            switch result {
            case .success(let authUser):
                let fireUser = FireUser(
                    id: authUser.uid,
                    registeredOn: Date(),
                    name: name,
                    birthDate: birthDate,
                    gender: gender,
                    profession: profession
                )
                
                // Save using the dedicated createUserDocument method
                FirebaseManager.shared.createUserDocument(fireUser) { res in
                    DispatchQueue.main.async {
                        switch res {
                        case .success():
                            self?.user = fireUser
                        case .failure(let error):
                            self?.errorMessage = error.localizedDescription
                        }
                    }
                }
                
            case .failure(let error):
                DispatchQueue.main.async {
                    self?.errorMessage = error.localizedDescription
                }
            }
        }
    }
    
    // MARK: - Login with Email
    /// Logs in with email/password and fetches FireUser from Firestore
    func loginWithEmail(email: String, password: String) {
        FirebaseManager.shared.loginWithEmail(email: email, password: password) { [weak self] result in
            switch result {
            case .success(let authUser):
                self?.fetchUser(id: authUser.uid)
            case .failure(let error):
                DispatchQueue.main.async {
                    self?.errorMessage = error.localizedDescription
                }
            }
        }
    }
    
    // MARK: - Fetch User from Firestore
    /// Fetches a FireUser document by user ID
    func fetchUser(id: String) {
        FirebaseManager.shared.fetchUserDocument(userId: id) { [weak self] result in
            DispatchQueue.main.async {
                switch result {
                case .success(let fireUser):
                    self?.user = fireUser
                case .failure(let error):
                    self?.errorMessage = error.localizedDescription
                }
            }
        }
    }
    
    // MARK: - Logout
    /// Logs out the current user
    func logout() {
        do {
            try FirebaseManager.shared.auth.signOut()
            DispatchQueue.main.async {
                self.user = nil
            }
            print("User has logged out")
        } catch {
            DispatchQueue.main.async {
                self.errorMessage = error.localizedDescription
            }
            print("Logout error:", error.localizedDescription)
        }
    }
    
    // MARK: - Computed Property
    /// Returns whether a user is currently logged in
    var isLoggedIn: Bool {
        return user != nil
    }
}

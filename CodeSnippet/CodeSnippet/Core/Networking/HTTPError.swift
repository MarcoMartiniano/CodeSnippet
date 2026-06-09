//
//  HTTPError.swift
//  Code Snippets
//
//  Created by Marco Antonio Martiniano on 24.03.26.
//

import Foundation
import FirebaseAuth

enum HTTPError: LocalizedError {
    
    case networkError
    case userDisabled
    case invalidCredentials
    case emailAlreadyInUse
    case weakPassword
    case invalidEmail
    
    case unknownError(description: String)
    
    init(error: Error) {
        if let errCode = AuthErrorCode(rawValue: (error as NSError).code) {
            switch errCode {
            case .networkError:
                self = .networkError
            case .userDisabled:
                self = .userDisabled
            case .wrongPassword, .invalidCredential:
                self = .invalidCredentials
            case .emailAlreadyInUse:
                self = .emailAlreadyInUse
            case .weakPassword:
                self = .weakPassword
            case .invalidEmail:
                self = .invalidEmail
                
            default:
                self = .unknownError(description: error.localizedDescription)
            }
        } else {
            self = .unknownError(description: error.localizedDescription)
        }
    }
    
    var errorDescription: String? {
        switch self {
        case .networkError:
            return "Netzwerkfehler. Bitte überprüfe deine Internetverbindung."
        case .userDisabled:
            return "Dieser Benutzer wurde deaktiviert."
        case .invalidCredentials:
            return "Ungültige Anmeldedaten."
        case .emailAlreadyInUse:
            return "Diese E-Mail wird bereits verwendet."
        case .weakPassword:
            return "Das Passwort ist zu schwach (mindestens 6 Zeichen)."
        case .invalidEmail:
            return "Ungültige E-Mail-Adresse."
            
        case .unknownError(let description):
            return "Unbekannter Fehler: \(description)"
        }
    }
}

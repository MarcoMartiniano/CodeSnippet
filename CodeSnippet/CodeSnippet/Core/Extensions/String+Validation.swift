//
//  String+Validation.swift
//  Code Snippets
//
//  Created by Marco Antonio Martiniano on 25.03.26.
//

import Foundation

extension String {
    /// Check if the string is a valid email address
    var isValidEmail: Bool {
        let emailRegEx = "^[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,}$"
        return NSPredicate(format: "SELF MATCHES %@", emailRegEx).evaluate(with: self)
    }
}

//
//  DateFormatter.swift
//  Code Snippets
//
//  Created by Marco Antonio Martiniano on 25.03.26.
//

import Foundation

// Global formatter in German
let germanDateFormatter: DateFormatter = {
    let formatter = DateFormatter()
    formatter.dateStyle = .medium
    formatter.timeStyle = .none
    formatter.locale = Locale(identifier: "de_DE")
    return formatter
}()

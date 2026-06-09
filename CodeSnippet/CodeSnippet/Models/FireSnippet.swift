//
//  FireSnippet.swift
//  Code Snippets
//
//  Created by Marco Antonio Martiniano on 26.03.26.
//

import Foundation
import FirebaseFirestore

struct FireSnippet: Codable, Identifiable {
    @DocumentID var id: String?       // Firestore document ID
    var userId: String                // Owner of the snippet
    var title: String                 // Title of the snippet
    var code: String                  // Code content of the snippet
    var createdOn: Date = Date()      // Date the snippet was created
    
    // Initializer for creating a new snippet
    init(userId: String, title: String, code: String) {
        self.userId = userId
        self.title = title
        self.code = code
    }
}

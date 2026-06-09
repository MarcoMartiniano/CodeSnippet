//
//  FirestoreDesign.swift
//  IOSSyntaxInstitut
//
//  Created by Marco Antonio Martiniano on 09.06.26.
//

enum FirestoreDesign: String, CaseIterable, Identifiable {
    case topLevel = "Top-Level"
    case nested = "Nested"
    var id: String { self.rawValue }
}

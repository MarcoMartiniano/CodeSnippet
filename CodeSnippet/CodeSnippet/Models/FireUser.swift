//
//  FireUser.swift
//  Code Snippets
//
//  Created by Marco Antonio Martiniano on 25.03.26.
//

import Foundation

// MARK: - Gender Enum
enum Gender: String, Codable, CaseIterable, Identifiable {
    case male = "Male"
    case female = "Female"
    case other = "Other"
    
    var id: String { self.rawValue }
}

// MARK: - Profession Enum
enum Profession: String, Codable, CaseIterable, Identifiable {
    case student = "Student"
    case engineer = "Engineer"
    case teacher = "Teacher"
    case doctor = "Doctor"
    case other = "Other"
    
    var id: String { self.rawValue }
}

// MARK: - FireUser Model
struct FireUser: Codable, Identifiable {
    var id: String?
    var registeredOn: Date
    var name: String
    var birthDate: Date
    var gender: Gender
    var profession: Profession
    
    init(id: String? = nil,
         registeredOn: Date = Date(),
         name: String = "",
         birthDate: Date = Date(),
         gender: Gender = .male,
         profession: Profession = .student) {
        self.id = id
        self.registeredOn = registeredOn
        self.name = name
        self.birthDate = birthDate
        self.gender = gender
        self.profession = profession
    }
}

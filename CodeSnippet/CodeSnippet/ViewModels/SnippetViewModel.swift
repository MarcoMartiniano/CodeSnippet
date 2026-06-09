//
//  SnippetViewModel.swift
//  Code Snippets
//
//  Created by Marco Antonio Martiniano on 26.03.26.
//

import Foundation
import FirebaseFirestore

@Observable
class SnippetViewModel {
    var snippets: [FireSnippet] = []
    var errorMessage: String?
    var successMessage: String?
    
    // MARK: - Firestore References
    private let topLevelCollection = FirestoreCollections.snippets
    private let nestedSubcollection = "snippets"
    
    private var listenerTopLevel: ListenerRegistration?
    private var listenerNested: ListenerRegistration?
    
    // MARK: - Add Snippet
    
    func addSnippetTopLevel(title: String, code: String, userId: String) {
        let snippet = FireSnippet(userId: userId, title: title, code: code)
        FirebaseManager.shared.createTopLevelDocument(snippet, collection: topLevelCollection) { [weak self] result in
            DispatchQueue.main.async {
                switch result {
                case .success:
                    self?.successMessage = "Snippet erfolgreich hinzugefügt"
                case .failure(let error):
                    self?.errorMessage = "Fehler beim Speichern: \(error.localizedDescription)"
                }
            }
        }
    }
    
    func addSnippetNested(title: String, code: String, userId: String) {
        let snippet = FireSnippet(userId: userId, title: title, code: code)
        FirebaseManager.shared.createNestedDocument(snippet, userId: userId, subcollection: nestedSubcollection) { [weak self] result in
            DispatchQueue.main.async {
                switch result {
                case .success:
                    self?.successMessage = "Snippet erfolgreich hinzugefügt"
                case .failure(let error):
                    self?.errorMessage = "Fehler beim Speichern: \(error.localizedDescription)"
                }
            }
        }
    }
    
    // MARK: - Listen to Snippets
    
    func listenToSnippetsTopLevel(userId: String) {
        listenerTopLevel?.remove()
        listenerTopLevel = FirebaseManager.shared.listenToTopLevelDocuments(
            collection: topLevelCollection,
            whereField: "userId",
            isEqualTo: userId,
            orderBy: "createdOn"
        ) { [weak self] (result: Result<[FireSnippet], Error>) in
            DispatchQueue.main.async {
                switch result {
                case .success(let snippets):
                    self?.snippets = snippets
                case .failure(let error):
                    self?.errorMessage = "Fehler beim Laden: \(error.localizedDescription)"
                }
            }
        }
    }
    
    func listenToSnippets(userId: String) {
        listenerNested?.remove()
        listenerNested = FirebaseManager.shared.listenToNestedDocuments(
            userId: userId,
            subcollection: nestedSubcollection,
            orderBy: "createdOn"
        ) { [weak self] (result: Result<[FireSnippet], Error>) in
            DispatchQueue.main.async {
                switch result {
                case .success(let snippets):
                    self?.snippets = snippets
                case .failure(let error):
                    self?.errorMessage = "Fehler beim Laden: \(error.localizedDescription)"
                }
            }
        }
    }
    
    // MARK: - Delete Snippet
    
    func deleteTopLevelSnippet(snippetId: String) {
        FirebaseManager.shared.deleteTopLevelDocument(collection: topLevelCollection, documentId: snippetId) { [weak self] result in
            DispatchQueue.main.async {
                switch result {
                case .success:
                    self?.snippets.removeAll { $0.id == snippetId }
                    self?.successMessage = "Snippet erfolgreich gelöscht"
                case .failure(let error):
                    self?.errorMessage = "Fehler beim Löschen: \(error.localizedDescription)"
                }
            }
        }
    }
    
    func deleteNestedSnippet(snippetId: String, userId: String) {
        FirebaseManager.shared.deleteNestedDocument(userId: userId, subcollection: nestedSubcollection, documentId: snippetId) { [weak self] result in
            DispatchQueue.main.async {
                switch result {
                case .success:
                    self?.successMessage = "Snippet erfolgreich gelöscht"
                case .failure(let error):
                    self?.errorMessage = "Fehler beim Löschen: \(error.localizedDescription)"
                }
            }
        }
    }
    
    // MARK: - Stop Listeners
    
    func stopListeningTopLevel() {
        listenerTopLevel?.remove()
        listenerTopLevel = nil
    }
    
    func stopListeningNested() {
        listenerNested?.remove()
        listenerNested = nil
    }
}

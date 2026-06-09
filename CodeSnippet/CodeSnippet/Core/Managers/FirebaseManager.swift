//
//  FirebaseManager.swift
//  Code Snippets
//
//  Created by Marco Antonio Martiniano on 25.03.26.
//

import Foundation
import FirebaseAuth
import FirebaseFirestore

// MARK: - FirebaseManager
class FirebaseManager {
    static let shared = FirebaseManager()
    private init() {}

    // Firebase services
    let auth = Auth.auth()
    let db = Firestore.firestore()

    // MARK: - Authentication

    /// Log in anonymously
    func loginAnonymously(completion: @escaping (Result<User, Error>) -> Void) {
        auth.signInAnonymously { authResult, error in
            if let error = error { completion(.failure(error)) }
            else if let user = authResult?.user { completion(.success(user)) }
        }
    }

    /// Register a user with email and password
    func registerWithEmail(email: String, password: String, completion: @escaping (Result<User, Error>) -> Void) {
        auth.createUser(withEmail: email, password: password) { authResult, error in
            if let error = error { completion(.failure(error)) }
            else if let user = authResult?.user { completion(.success(user)) }
        }
    }

    /// Log in a user with email and password
    func loginWithEmail(email: String, password: String, completion: @escaping (Result<User, Error>) -> Void) {
        auth.signIn(withEmail: email, password: password) { authResult, error in
            if let error = error { completion(.failure(error)) }
            else if let user = authResult?.user { completion(.success(user)) }
        }
    }

    /// Log out the current user
    func logout() throws {
        try auth.signOut()
    }

    // MARK: - Snippets Nested Design (users/{userId}/snippets/{snippetId})

    /// Create a FireUser document in "users/{userId}"
    func createUserDocument(_ fireUser: FireUser, completion: @escaping (Result<Void, Error>) -> Void) {
        guard let id = fireUser.id else {
            completion(.failure(NSError(domain: "FirebaseManager", code: -1, userInfo: [NSLocalizedDescriptionKey: "User ID is nil"])))
            return
        }
        do {
            try db.collection(FirestoreCollections.users).document(id).setData(from: fireUser)
            completion(.success(()))
        } catch {
            completion(.failure(error))
        }
    }
    
    // MARK: - Top-Level Design (snippets/{snippetId})

    /// Fetch a user document by ID

    func fetchUserDocument(
        userId: String,
        completion: @escaping (Result<FireUser, Error>) -> Void
    ) {
        db.collection(FirestoreCollections.users)
            .document(userId)
            .getDocument { document, error in

                if let error = error {
                    completion(.failure(error))
                    return
                }

                guard let document = document else { return }

                Task { @MainActor in
                    do {
                        let user = try document.data(as: FireUser.self)
                        completion(.success(user))
                    } catch {
                        completion(.failure(error))
                    }
                }
            }
    }
    
    // MARK: - Nested Documents (users/{userId}/subcollection/{docId})

    /// Create a document in a subcollection for a specific user
    func createNestedDocument<T: Codable>(
        _ object: T,
        userId: String,
        subcollection: String,
        docId: String? = nil,
        completion: @escaping (Result<Void, Error>) -> Void
    ) {
        let ref: DocumentReference
        if let docId = docId {
            ref = db.collection(FirestoreCollections.users).document(userId)
                     .collection(subcollection)
                     .document(docId)
        } else {
            // Let Firestore generate the document ID automatically
            ref = db.collection(FirestoreCollections.users).document(userId)
                     .collection(subcollection)
                     .document()
        }

        do {
            try ref.setData(from: object)
            completion(.success(()))
        } catch {
            completion(.failure(error))
        }
    }

    /// Fetch documents from a subcollection for a specific user, with optional ordering
    func fetchNestedDocuments<T: Codable>(
        userId: String,
        subcollection: String,
        orderBy: String? = nil,
        descending: Bool = true,
        completion: @escaping (Result<[T], Error>) -> Void
    ) {
        var query: Query = db.collection(FirestoreCollections.users).document(userId).collection(subcollection)
        if let orderBy = orderBy {
            query = query.order(by: orderBy, descending: descending)
        }

        query.getDocuments { snapshot, error in
            if let error = error {
                completion(.failure(error))
                return
            }
            guard let documents = snapshot?.documents else {
                completion(.success([]))
                return
            }
            do {
                let items = try documents.compactMap { try $0.data(as: T.self) }
                completion(.success(items))
            } catch {
                completion(.failure(error))
            }
        }
    }
    
    /// Listen to documents from a Nested collection in real-time, with optional filtering and ordering
    func listenToNestedDocuments<T: Codable>(
        userId: String,
        subcollection: String,
        orderBy: String? = nil,
        descending: Bool = true,
        completion: @escaping (Result<[T], Error>) -> Void
    ) -> ListenerRegistration {
        
        var query: Query = db.collection(FirestoreCollections.users)
            .document(userId)
            .collection(subcollection)
        
        if let orderBy = orderBy {
            query = query.order(by: orderBy, descending: descending)
        }
        
        return query.addSnapshotListener { snapshot, error in
            
            if let error = error {
                completion(.failure(error))
                return
            }
            
            guard let documents = snapshot?.documents else {
                completion(.success([]))
                return
            }
            
            do {
                let items = try documents.compactMap {
                    try $0.data(as: T.self)
                }
                completion(.success(items))
            } catch {
                completion(.failure(error))
            }
        }
    }
    
    // MARK: - Delete Nested Document (users/{userId}/subcollection/{docId})

    /// Deletes a document inside a user subcollection
    func deleteNestedDocument(
        userId: String,
        subcollection: String,
        documentId: String,
        completion: @escaping (Result<Void, Error>) -> Void
    ) {
        db.collection(FirestoreCollections.users)
            .document(userId)
            .collection(subcollection)
            .document(documentId)
            .delete { error in
                if let error = error {
                    completion(.failure(error))
                } else {
                    completion(.success(()))
                }
            }
    }

    // MARK: - Snippets Helpers (Nested)

    /// Create a snippet document under "users/{userId}/snippets"
    func createSnippetForUser(_ snippet: FireSnippet, userId: String, completion: @escaping (Result<Void, Error>) -> Void) {
        createNestedDocument(snippet, userId: userId, subcollection: FirestoreCollections.snippets, docId: snippet.id, completion: completion)
    }

    /// Fetch all snippets for a specific user
    func fetchSnippetsForUser(userId: String, completion: @escaping (Result<[FireSnippet], Error>) -> Void) {
        fetchNestedDocuments(userId: userId, subcollection: FirestoreCollections.snippets, orderBy: "createdOn", completion: completion)
    }
}


// MARK: - Top-Level Documents (snippets/{snippetId})
extension FirebaseManager {
    
    /// Create a document directly in a top-level collection (not under "users/{userId}")
    func createTopLevelDocument<T: Codable>(
        _ object: T,
        collection: String,
        docId: String? = nil,
        completion: @escaping (Result<Void, Error>) -> Void
    ) {
        let ref: DocumentReference
        if let docId = docId {
            ref = db.collection(collection).document(docId)
        } else {
            // Let Firestore generate the document ID automatically
            ref = db.collection(collection).document()
        }

        do {
            try ref.setData(from: object)
            completion(.success(()))
        } catch {
            completion(.failure(error))
        }
    }

    /// Fetch documents from a top-level collection, with optional ordering
    func fetchTopLevelDocuments<T: Codable>(
        collection: String,
        orderBy: String? = nil,
        descending: Bool = true,
        completion: @escaping (Result<[T], Error>) -> Void
    ) {
        var query: Query = db.collection(collection)
        if let orderBy = orderBy {
            query = query.order(by: orderBy, descending: descending)
        }

        query.getDocuments { snapshot, error in
            if let error = error {
                completion(.failure(error))
                return
            }
            guard let documents = snapshot?.documents else {
                completion(.success([]))
                return
            }
            do {
                let items = try documents.compactMap { try $0.data(as: T.self) }
                completion(.success(items))
            } catch {
                completion(.failure(error))
            }
        }
    }
    
    // MARK: - Top-Level Realtime Listener
    func listenToTopLevelDocuments<T: Codable>(
        collection: String,
        whereField: String? = nil,
        isEqualTo: Any? = nil,
        orderBy: String? = nil,
        descending: Bool = true,
        completion: @escaping (Result<[T], Error>) -> Void
    ) -> ListenerRegistration {

        var query: Query = db.collection(collection)

        if let whereField = whereField, let isEqualTo = isEqualTo {
            query = query.whereField(whereField, isEqualTo: isEqualTo)
        }

        if let orderBy = orderBy {
            query = query.order(by: orderBy, descending: descending)
        }

        let listener = query.addSnapshotListener { snapshot, error in
            if let error = error {
                completion(.failure(error))
                return
            }

            guard let documents = snapshot?.documents else {
                completion(.success([]))
                return
            }

            do {
                let items = try documents.compactMap { try $0.data(as: T.self) }
                completion(.success(items))
            } catch {
                completion(.failure(error))
            }
        }

        return listener
    }
    
    /// /// Deletes a document from a top-level collection
    // MARK: - Delete Top-Level Document
    func deleteTopLevelDocument(
        collection: String,
        documentId: String,
        completion: @escaping (Result<Void, Error>) -> Void
    ) {
        db.collection(collection).document(documentId).delete { error in
            if let error = error {
                completion(.failure(error))
            } else {
                completion(.success(()))
            }
        }
    }
}

//
//  AddSnippetSheet.swift
//  Code Snippets
//
//  Created by Marco Antonio Martiniano on 27.03.26.
//

import SwiftUI

struct AddSnippetSheet: View {
    @Binding var selectedDesign: FirestoreDesign
    
    var onSave: (String, String, FirestoreDesign) -> Void
    
    @Environment(\.dismiss) var dismiss
    
    @State private var title: String = ""
    @State private var code: String = ""

    var isFormValid: Bool {
        !title.isEmpty && !code.isEmpty
    }
    
    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                
                // MARK: - Picker (TopLevel / Nested)
                Picker("Speicherort", selection: $selectedDesign) {
                    ForEach(FirestoreDesign.allCases, id: \.self) { design in
                        Text(design.rawValue).tag(design)
                    }
                }
                .pickerStyle(.segmented)
                
                // MARK: - Inputs
                CustomTextField(placeholder: "Titel", text: $title)
                
                CodeEditorView(text: $code)
                
                // MARK: - Save Button
                AppButtonView(
                    title: "Speichern",
                    backgroundColor: .blue,
                    isDisabled: !isFormValid
                ) {
                    onSave(title, code, selectedDesign)
                    dismiss()
                }
                
                Spacer()
            }
            .padding()
            .navigationTitle("Neues Snippet")
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Abbrechen") {
                        dismiss()
                    }
                }
            }
        }
    }
}

// MARK: - Code Editor Component
struct CodeEditorView: View {
    @Binding var text: String
    var body: some View {
        TextEditor(text: $text)
            .frame(height: 150)
            .padding(10)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color(.systemGray6))
                    .shadow(color: Color.black.opacity(0.08), radius: 5, x: 0, y: 2)
            )
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(Color.gray.opacity(0.3), lineWidth: 1)
            )
    }
}

#Preview {
    
    AddSnippetSheet(
        selectedDesign: .constant(.topLevel),
        onSave: { _, _, _ in }
        )
    
}

//
//  ContentView.swift
//  Code Snippets
//
//  Created by Marco Antonio Martiniano on 24.03.26.
//

import SwiftUI

struct SnippetListView: View {
    
    @Environment(UserViewModel.self) private var userViewModel
    
    @State private var viewModel = SnippetViewModel()
    
    @State private var selectedDesign: FirestoreDesign = .topLevel
    @State private var showAddSheet = false
    
    @State private var showDeleteAlert = false
    @State private var selectedSnippet: FireSnippet?
    
    private var currentMessage: String? {
        viewModel.errorMessage ?? viewModel.successMessage
    }
    
    private var isShowingMessage: Binding<Bool> {
        Binding(
            get: {
                currentMessage != nil
            },
            set: { newValue in
                if !newValue {
                    viewModel.errorMessage = nil
                    viewModel.successMessage = nil
                }
            }
        )
    }
    
    var body: some View {
        NavigationStack {
            VStack(alignment: .leading, spacing: 20) {
                
                Picker("Design", selection: $selectedDesign) {
                    ForEach(FirestoreDesign.allCases, id: \.self) { design in
                        Text(design.rawValue)
                            .tag(design)
                    }
                }
                .pickerStyle(.segmented)
                .padding(.vertical)
                
                SnippetListSection(
                    snippets: viewModel.snippets,
                    onDelete: { snippet in
                        selectedSnippet = snippet
                        showDeleteAlert = true
                    }
                )
            }
            .padding()
            .navigationTitle("Snippets")
            
            .toolbar {
                ToolbarItemGroup(placement: .topBarTrailing) {
                    
                    Button {
                        showAddSheet = true
                    } label: {
                        Image(systemName: AppIcons.plus)
                    }
                    
                    Menu {
                        Button("Logout") {
                            userViewModel.logout()
                        }
                    } label: {
                        Image(systemName: AppIcons.personCropCircle)
                    }
                }
            }
            
            .sheet(isPresented: $showAddSheet) {
                AddSnippetSheet(
                    selectedDesign: $selectedDesign)
                { title, code, design in
                    addSnippet(
                        title: title,
                        code: code,
                        design: design
                    )
                }
            }
            
            .alert(
                "Hinweis",
                isPresented: isShowingMessage
            ) {
                Button("OK") {
                    viewModel.errorMessage = nil
                    viewModel.successMessage = nil
                }
            } message: {
                Text(currentMessage ?? "")
            }
            
            .alert("Snippet löschen?", isPresented: $showDeleteAlert) {
                Button("Löschen", role: .destructive) {
                    confirmDelete()
                }
                
                Button("Abbrechen", role: .cancel) { }
                
            } message: {
                Text("Möchtest du dieses Snippet wirklich löschen?")
            }
            
            .task(id: selectedDesign) {
                guard let userId = userViewModel.user?.id else {
                    return
                }
                
                viewModel.stopListeningTopLevel()
                viewModel.stopListeningNested()
                
                switch selectedDesign {
                case .topLevel:
                    viewModel.listenToSnippetsTopLevel(userId: userId)
                    
                case .nested:
                    viewModel.listenToSnippets(userId: userId)
                }
            }
            
            .onDisappear {
                viewModel.stopListeningTopLevel()
                viewModel.stopListeningNested()
            }
        }
    }
    // MARK: - Add Snippet
    private func addSnippet(title: String, code: String, design: FirestoreDesign) {
        guard let userId = userViewModel.user?.id else { return }
        
        switch design {
        case .topLevel:
            viewModel.addSnippetTopLevel(title: title, code: code, userId: userId)
        case .nested:
            viewModel.addSnippetNested(title: title, code: code, userId: userId)
        }
    }
    
    // MARK: - Delete Snippet
    private func confirmDelete() {
        guard let userId = userViewModel.user?.id,
              let snippetId = selectedSnippet?.id else { return }
        
        switch selectedDesign {
        case .topLevel:
            viewModel.deleteTopLevelSnippet(snippetId: snippetId)
        case .nested:
            viewModel.deleteNestedSnippet(snippetId: snippetId, userId: userId)
        }
    }
}

// MARK: - Snippet List Section
struct SnippetListSection: View {
    
    let snippets: [FireSnippet]
    let onDelete: (FireSnippet) -> Void
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            
            // MARK: - Snippets Header
            Text("Deine Snippets")
                .font(.title2)
                .bold()
                .foregroundColor(.primary)
                .padding(.horizontal)
            
            // MARK: - Empty State
            if snippets.isEmpty {
                VStack(spacing: 10) {
                    Spacer()
                    Image(systemName: "doc.text")
                        .font(.system(size: 40))
                        .foregroundColor(.gray.opacity(0.6))
                    
                    Text("Noch keine Snippets vorhanden")
                        .foregroundColor(.gray)
                        .font(.subheadline)
                    Spacer()
                }
                .frame(maxWidth: .infinity)
            } else {
                // MARK: - Snippet Cards with Swipe
                List {
                    ForEach(snippets) { snippet in
                        SnippetRowView(snippet: snippet)
                            .listRowBackground(Color.clear)
                            .listRowSeparator(.hidden)
                            .swipeActions {
                                Button(role: .destructive) {
                                    onDelete(snippet)
                                } label: {
                                    Label("Löschen", systemImage: AppIcons.trash)
                                }
                            }
                    }
                }
                .listStyle(.plain)
                .background(Color.clear)
            }
        }
        .padding(.top, 20)
    }
}

// MARK: - Snippet Row View
struct SnippetRowView: View {
    let snippet: FireSnippet
    
    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text(snippet.title)
                    .font(.headline)
                    .foregroundColor(.primary)
                
                Text(snippet.code)
                    .font(.system(.caption, design: .monospaced))
                    .foregroundColor(.secondary)
            }
            Spacer()
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 14)
                .fill(Color(.systemBackground))
                .shadow(color: Color.black.opacity(0.05), radius: 5, x: 0, y: 2)
        )
    }
}

// MARK: - Preview
#Preview {
    SnippetListView()
        .environment(UserViewModel())
}

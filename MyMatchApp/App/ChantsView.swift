//
//  ChantsView.swift
//  FMatchFun
//
//  Created by D K on 18.08.2025.
//

import SwiftUI
import RealmSwift

struct ChantsView: View {
    @ObservedObject var viewModel: FunMatchViewModel
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 24) {
                
                
                TitledSection(title: "AI Chant Generator") {
                    ChantGeneratorCard(viewModel: viewModel)
                }
                .padding(.horizontal)
                
                TitledSection(title: "YOUR SAVED CHANTS") {
                    if let chants = viewModel.savedChants, !chants.isEmpty {
                        ForEach(chants) { chant in
                            ChantCard(chant: chant)
                        }
                    } else {
                        Text("No saved chants yet. Generate one!")
                            .foregroundColor(.themeSecondaryText)
                            .padding(.horizontal)
                    }
                }
                .padding(.horizontal)
            }
            .padding(.bottom, 150)

        }
        .alert("Error", isPresented: .constant(viewModel.alertError != nil), actions: {
            Button("OK") { viewModel.alertError = nil }
        }, message: { Text(viewModel.alertError ?? "") })
    }
}


private struct ChantGeneratorCard: View {
    @ObservedObject var viewModel: FunMatchViewModel
    
    var body: some View {
        VStack(spacing: 16) {
            HStack {
                Image(systemName: "mic.fill")
                    .font(.title).foregroundColor(.themeAccentRed).padding(12)
                    .background(Color.themeAccentRed.opacity(0.2)).clipShape(Circle())
                
                VStack(alignment: .leading) {
                    Text("AI Chant Generator").font(.headline)
                    Text("Create custom chants for your team").font(.caption).foregroundColor(.themeSecondaryText)
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            
            HStack {
                TextField("e.g., Arsenal victory, Chelsea...", text: $viewModel.chantTopic)
                    .textFieldStyle(PlainTextFieldStyle())
                
                Button("Generate") { viewModel.generateChant() }
                    .buttonStyle(PrimaryButtonStyle())
                    .disabled(viewModel.isLoadingChant)
            }
            .padding(12)
            .background(Color.themeBackground)
            .cornerRadius(12)
            
            if viewModel.isLoadingChant {
                ProgressView().tint(.themeAccentRed)
            }
        }
        .padding()
        .background(Color.themeCardBackground)
        .cornerRadius(16)
    }
}


private struct ChantCard: View {
    @ObservedRealmObject var chant: ChantObject
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text(chant.title).font(.headline).bold()
                    .padding(.horizontal, 10).padding(.vertical, 5)
                    .background(Color.themeBackground).clipShape(Capsule())
                Spacer()
                Button(action: {
                                   try? StorageManager.shared.deleteChant(withId: chant._id)
                               }) {
                                   Image(systemName: "heart.fill").foregroundColor(.themeAccentRed)
                               }
            }
            
            Text(chant.chantText)
                .font(.body)
                .foregroundColor(.themeSecondaryText)
            
            HStack {
                Spacer()
                Button(action: { copyToClipboard(chant.chantText) }) {
                    Label("Copy", systemImage: "doc.on.doc")
                }
                Button(action: { shareText(chant.chantText) }) {
                    Label("Share", systemImage: "square.and.arrow.up")
                }
            }
            .font(.caption)
            .foregroundColor(.themeSecondaryText)
        }
        .padding()
        .background(Color.themeCardBackground)
        .cornerRadius(16)
    }
    
    private func copyToClipboard(_ text: String) {
        UIPasteboard.general.string = text
    }
    
    private func shareText(_ text: String) {
        let activityVC = UIActivityViewController(activityItems: [text], applicationActivities: nil)
        if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene {
            windowScene.windows.first?.rootViewController?.present(activityVC, animated: true, completion: nil)
        }
    }
}

private struct TitledSection<Content: View>: View {
    let title: String
    @ViewBuilder let content: Content
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(title).font(.caption).foregroundColor(.themeSecondaryText)
            content
        }
    }
}

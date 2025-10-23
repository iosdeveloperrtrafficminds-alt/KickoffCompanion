//
//  SettingsView.swift
//  FMatchFun
//
//  Created by D K on 18.08.2025.
//

import Foundation
import SwiftUI
import RealmSwift
import StoreKit


@MainActor
class SettingsViewModel: ObservableObject {
    @Published var isDeleteAlertPresented = false
    
    var appVersion: String {
        Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "1.0.0"
    }
    
    func rateApp() {
        if let scene = UIApplication.shared.connectedScenes.first(where: { $0.activationState == .foregroundActive }) as? UIWindowScene {
            SKStoreReviewController.requestReview(in: scene)
        }
    }
    
    func shareApp() {
        guard let url = URL(string: "https://apps.apple.com/app/idYOUR_APP_ID") else { return }
        let text = "Check out this great app for football fans!"
        
        let activityVC = UIActivityViewController(activityItems: [text, url], applicationActivities: nil)
        
        if let windowScene = UIApplication.shared.connectedScenes.first(where: { $0.activationState == .foregroundActive }) as? UIWindowScene {
            windowScene.windows.first?.rootViewController?.present(activityVC, animated: true, completion: nil)
        }
    }
    
    func deleteAllData() {
        try? StorageManager.shared.deleteAllData()
        NotificationCenter.default.post(name: .didDeleteAllData, object: nil)
    }
}

extension Notification.Name {
    static let didDeleteAllData = Notification.Name("didDeleteAllData")
}



struct SettingsView: View {
    @StateObject private var viewModel = SettingsViewModel()
    @Environment(\.presentationMode) var presentationMode
    
    var body: some View {
        NavigationView {
            ZStack {
                Color.themeBackground.ignoresSafeArea()
                
                VStack {
                    List {
                        Section(header: Text("Feedback & Support")) {
                            SettingsRow(icon: "star.fill", title: "Rate App", action: {})
                            SettingsRow(icon: "square.and.arrow.up", title: "Share App", action: {})
                        }
                        
                        Section(header: Text("Danger Zone")) {
                            SettingsRow(icon: "trash.fill", title: "Delete All Data", isDestructive: true) {
                                viewModel.isDeleteAlertPresented = true
                            }
                        }
                    }
                    .listStyle(InsetGroupedListStyle())
                    .scrollContentBackground(.hidden)
                    
                    Spacer()
                    
                    Text("Version \(viewModel.appVersion)")
                        .font(.caption)
                        .foregroundColor(.themeSecondaryText)
                        .padding()
                }
            }
            .navigationTitle("Settings")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Done") {
                        presentationMode.wrappedValue.dismiss()
                    }
                }
            }
            .alert("Delete All Data", isPresented: $viewModel.isDeleteAlertPresented) {
                Button("Cancel", role: .cancel) {}
                Button("Delete", role: .destructive) {
                    viewModel.deleteAllData()
                    presentationMode.wrappedValue.dismiss()
                }
            } message: {
                Text("Are you sure you want to permanently delete all your matches, checklist items, and memories? This action cannot be undone.")
            }
        }
        .tint(.white)
    }
}


private struct SettingsRow: View {
    let icon: String
    let title: String
    var isDestructive: Bool = false
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack {
                Image(systemName: icon)
                Text(title)
                Spacer()
                Image(systemName: "chevron.right")
                    .foregroundColor(.themeSecondaryText.opacity(0.5))
            }
        }
        .listRowBackground(Color.themeCardBackground)
        .foregroundColor(isDestructive ? .themeAccentRed : .themePrimaryText)
    }
}

#Preview {
    SettingsView()
}

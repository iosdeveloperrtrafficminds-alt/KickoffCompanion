//
//  FunMatchViewModel.swift
//  FMatchFun
//
//  Created by D K on 18.08.2025.
//


import SwiftUI
import RealmSwift
import Combine

enum FunMatchMode: String, CaseIterable {
    case bingo = "Bingo", quiz = "Big Text", chants = "Chants"
}

struct BingoItem: Identifiable {
    let id = UUID()
    var text: String
    var isComplete = false
}

@MainActor
class FunMatchViewModel: ObservableObject {
    @Published var selectedMode: FunMatchMode = .bingo
    
    // Bingo
    @Published var selectedMatch: MatchObject?
    @Published var bingoItems: [BingoItem] = []
    @Published var isCustomizing = false
    @Published var customizationItems: [BingoItem] = []
    @Published var isMatchSelectionPresented = false
    
    // Chants
    @Published var chantTopic = ""
    @Published var savedChants: Results<ChantObject>?
    @Published var isLoadingChant = false
    @Published var alertError: String?
    
    // Big Text
    @Published var bigText = "COME ON YOU REDS!"
        @Published var selectedBackgroundColor: Color = .themeAccentRed
        @Published var selectedTextColor: Color = .white
        @Published var fontSize: CGFloat = 72.0
    
    private let geminiService = GeminiService()
    private var matches: Results<MatchObject>?
    private var matchesToken: NotificationToken?
    private var chantsToken: NotificationToken?
    
    init() {
        setupObservers()
        generateBingo()
    }
    
    deinit {
        matchesToken?.invalidate()
        chantsToken?.invalidate()
    }
    
    private func setupObservers() {
        matches = StorageManager.shared.fetchMatches()
        selectedMatch = matches?.first
        matchesToken = matches?.observe { [weak self] _ in
            self?.objectWillChange.send()
        }
        
        savedChants = StorageManager.shared.fetchChants()
        chantsToken = savedChants?.observe { [weak self] _ in
            self?.objectWillChange.send()
        }
    }
    
    func generateBingo() {
        bingoItems = [
            BingoItem(text: "Goal in the first half"),
            BingoItem(text: "Red card"),
            BingoItem(text: "Penalty kick"),
            BingoItem(text: "Corner goal"),
            BingoItem(text: "VAR decision"),
            BingoItem(text: "Yellow card"),
            BingoItem(text: "Substitution before 60'"),
            BingoItem(text: "Goal from outside the box"),
            BingoItem(text: "Injury time goal")
        ]
    }
    
    func startCustomizing() {
        customizationItems = bingoItems
        isCustomizing = true
    }
    
    func saveCustomization() {
        bingoItems = customizationItems.filter { !$0.text.isEmpty }
        isCustomizing = false
    }
    
    func addNewCustomItem() {
        customizationItems.append(BingoItem(text: ""))
    }
    
    func deleteCustomItem(at offsets: IndexSet) {
        customizationItems.remove(atOffsets: offsets)
    }
    
    func generateChant() {
        isLoadingChant = true
        let topic = chantTopic.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !topic.isEmpty else {
            isLoadingChant = false
            return
        }
        
        Task {
            let result = await geminiService.generateChant(topic: topic)
            isLoadingChant = false
            switch result {
            case .success(let chant):
                try? StorageManager.shared.saveChant(title: chant.title, chantText: chant.chant)
                chantTopic = ""
            case .failure(let error):
                alertError = error.localizedDescription
            }
        }
    }
}

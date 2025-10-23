//
//  MatchesViewModel.swift
//  FMatchFun
//
//  Created by D K on 18.08.2025.
//

import Foundation
import RealmSwift
import Combine

@MainActor
class MatchesViewModel: ObservableObject {
    @Published var matches: Results<MatchObject>?
    @Published var isAddMatchSheetPresented = false
    @Published var selectedTicketPhotoData: Data?
    
    private var token: NotificationToken?
    
    init() {
        setupObserver()
    }
    
    deinit {
        token?.invalidate()
    }
    
    
    private func setupObserver() {
        let results = StorageManager.shared.fetchMatches()
        token = results.observe { [weak self] _ in
            self?.matches = results
        }
    }
}

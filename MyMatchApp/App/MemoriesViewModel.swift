//
//  MemoriesViewModel.swift
//  FMatchFun
//
//  Created by D K on 18.08.2025.
//

import Foundation
import RealmSwift

@MainActor
class MemoriesViewModel: ObservableObject {
    @Published var memories: Results<MemoryObject>?
    @Published var isAddSheetPresented = false
    
    private var token: NotificationToken?
    
    init() {
        setupObserver()
    }
    
    deinit { token?.invalidate() }
    
     func setupObserver() {
        memories = StorageManager.shared.fetchMemories()
        token = memories?.observe { [weak self] _ in
            self?.objectWillChange.send()
        }
    }
}

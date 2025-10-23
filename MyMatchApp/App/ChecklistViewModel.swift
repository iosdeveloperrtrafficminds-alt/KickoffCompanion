//
//  ChecklistViewModel.swift
//  FMatchFun
//
//  Created by D K on 18.08.2025.
//

import Foundation
import RealmSwift
import Combine

@MainActor
class ChecklistViewModel: ObservableObject {
    @Published var essentialItems: Results<ChecklistItemObject>?
    @Published var personalItems: Results<ChecklistItemObject>?
    
    @Published var newItemName = ""
    @Published var newItemDescription = ""
    @Published var isAddingItem = false
    
    private var essentialToken: NotificationToken?
    private var personalToken: NotificationToken?
    
    init() {
        addBaseChecklistItemsIfNeeded()
        setupObservers()
    }
    
    deinit {
        essentialToken?.invalidate()
        personalToken?.invalidate()
    }
    
    private func setupObservers() {
        essentialItems = StorageManager.shared.fetchChecklistItems(isEssential: true)
        personalItems = StorageManager.shared.fetchChecklistItems(isEssential: false)
        
        essentialToken = essentialItems?.observe { [weak self] _ in self?.objectWillChange.send() }
        personalToken = personalItems?.observe { [weak self] _ in self?.objectWillChange.send() }
    }
    
    func addItem() {
        guard !newItemName.isEmpty else { return }
        StorageManager.shared.addChecklistItem(name: newItemName, description: newItemDescription)
        newItemName = ""
        newItemDescription = ""
        isAddingItem = false
    }
    
    func toggleItem(_ item: ChecklistItemObject) {
        try? StorageManager.shared.toggleChecklistItemCompletion(item._id)
    }

    func deletePersonalItem(_ item: ChecklistItemObject) {
        try? StorageManager.shared.deleteChecklistItem(item._id)
    }
    
    private func addBaseChecklistItemsIfNeeded() {
        let realm = try! Realm()
        if realm.objects(ChecklistItemObject.self).isEmpty {
            let baseItems = [
                ("Ticket", "Digital ticket in your wallet app"),
                ("Scarf", "Your lucky red and white scarf"),
                ("Snacks", "Avoid high stadium prices"),
                ("Power Bank", "For all those match photos"),
                ("Jersey", "Show your team colors")
            ]
            
            for (name, desc) in baseItems {
                let item = ChecklistItemObject()
                item.name = name
                item.itemDescription = desc
                try? realm.write { realm.add(item) }
            }
        }
    }
}

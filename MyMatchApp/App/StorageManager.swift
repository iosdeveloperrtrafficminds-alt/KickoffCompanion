//
//  StorageManager.swift
//  FMatchFun
//
//  Created by D K on 18.08.2025.
//

import Foundation
import RealmSwift

final class StorageManager {
    static let shared = StorageManager()
    private let realm: Realm
    
    private init() {
        do {
            realm = try Realm()
        } catch {
            fatalError("Failed to initialize Realm: \(error)")
        }
    }
    
    private func write(_ block: () -> Void) throws {
        try realm.write { block() }
    }
    
    func addMatch(match: MatchObject) throws {
        try write { realm.add(match) }
    }
    
    func fetchMatches() -> Results<MatchObject> {
        realm.objects(MatchObject.self).sorted(byKeyPath: "date")
    }
    
    func deleteMatch(withId id: ObjectId) throws {
        guard let match = realm.object(ofType: MatchObject.self, forPrimaryKey: id) else { return }
        try write { realm.delete(match) }
    }
    
    func fetchChecklistItems(isEssential: Bool) -> Results<ChecklistItemObject> {
        realm.objects(ChecklistItemObject.self).filter("isEssential == %@", isEssential)
    }
    
    func addChecklistItem(name: String, description: String?) {
        let item = ChecklistItemObject()
        item.name = name
        item.itemDescription = description
        item.isEssential = false
        try? write { realm.add(item) }
    }
    
    func toggleChecklistItemCompletion(_ itemID: ObjectId) throws {
        guard let item = realm.object(ofType: ChecklistItemObject.self, forPrimaryKey: itemID) else { return }
        try write { item.isCompleted.toggle() }
    }
    
    func deleteChecklistItem(_ itemID: ObjectId) throws {
        guard let item = realm.object(ofType: ChecklistItemObject.self, forPrimaryKey: itemID) else { return }
        try write { realm.delete(item) }
    }
    
    func addBaseChecklistItemsIfNeeded() {
        if realm.objects(ChecklistItemObject.self).isEmpty {
            let baseItems = [
                ("Ticket", "Digital ticket in your wallet app"),
                ("Scarf", "Your lucky red and white scarf"),
                ("Snacks", "Avoid high stadium prices"),
                ("Power Bank", "For all those match photos"),
                ("Jersey", "Show your team colors")
            ]
            
            try? write {
                for (name, desc) in baseItems {
                    let item = ChecklistItemObject()
                    item.name = name
                    item.itemDescription = desc
                    realm.add(item)
                }
            }
        }
    }
    
    func addMemory(match: MatchObject, description: String, tags: [String], location: String?, photos: [Data]) throws {
        let memory = MemoryObject()
        memory.match = match
        memory.memoryDescription = description
        memory.location = location
        memory.tags.append(objectsIn: tags)
        
        for data in photos {
            let photo = PhotoObject()
            photo.photoData = data
            memory.photos.append(photo)
        }
        
        try write { realm.add(memory) }
    }

    func fetchMemories() -> Results<MemoryObject> {
        realm.objects(MemoryObject.self).sorted(byKeyPath: "createdAt", ascending: false)
    }

    func deleteMemory(_ memory: MemoryObject) throws {
        try write { realm.delete(memory) }
    }
    
    func saveChant(title: String, chantText: String) throws {
        let chant = ChantObject()
        chant.title = title
        chant.chantText = chantText
        try write { realm.add(chant) }
    }

    func fetchChants() -> Results<ChantObject> {
        realm.objects(ChantObject.self)
    }

    func deleteChant(withId id: ObjectId) throws {
        guard let chant = realm.object(ofType: ChantObject.self, forPrimaryKey: id) else { return }
        try write { realm.delete(chant) }
    }
    
    func deleteAllData() throws {
            try write {
                realm.deleteAll()
            }
        }
}

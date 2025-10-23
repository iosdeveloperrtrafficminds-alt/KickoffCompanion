//
//  RealmModels.swift
//  FMatchFun
//
//  Created by D K on 18.08.2025.
//

import Foundation
import RealmSwift

class MatchObject: Object, ObjectKeyIdentifiable {
    @Persisted(primaryKey: true) var _id: ObjectId
    @Persisted var league: String?
    @Persisted var homeTeam: String
    @Persisted var awayTeam: String
    @Persisted var homeTeamShort: String
    @Persisted var awayTeamShort: String
    @Persisted var date: Date
    @Persisted var stadium: String?
    @Persisted var isAttending: Bool = true
    @Persisted var ticketSection: String?
    @Persisted var ticketRow: String?
    @Persisted var ticketSeat: String?
    @Persisted var ticketPhotoData: Data?
    @Persisted var notes: String?
}

class ChecklistItemObject: Object, ObjectKeyIdentifiable {
    @Persisted(primaryKey: true) var _id: ObjectId
    @Persisted var name: String
    @Persisted var itemDescription: String?
    @Persisted var isCompleted: Bool = false
    @Persisted var isEssential: Bool = true
}

class MemoryObject: Object, ObjectKeyIdentifiable {
    @Persisted(primaryKey: true) var _id: ObjectId
    @Persisted var match: MatchObject?
    @Persisted var memoryDescription: String
    @Persisted var tags: List<String>
    @Persisted var location: String?
    @Persisted var photos: List<PhotoObject>
    @Persisted var createdAt: Date = Date()
}

class PhotoObject: EmbeddedObject, ObjectKeyIdentifiable {
    @Persisted var photoData: Data
}

class ChantObject: Object, ObjectKeyIdentifiable {
    @Persisted(primaryKey: true) var _id: ObjectId
    @Persisted var title: String
    @Persisted var chantText: String
}

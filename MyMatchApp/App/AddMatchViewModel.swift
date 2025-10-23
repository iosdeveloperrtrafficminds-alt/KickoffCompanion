//
//  AddMatchViewModel.swift
//  FMatchFun
//
//  Created by D K on 18.08.2025.
//

import Foundation
import SwiftUI
import PhotosUI

@MainActor
class AddMatchViewModel: ObservableObject {
    @Published var league = ""
    @Published var homeTeam = ""
    @Published var awayTeam = ""
    @Published var date = Date()
    @Published var time = Date()
    @Published var stadium = ""
    @Published var isAttending = true
    
    @Published var ticketSection = ""
    @Published var ticketRow = ""
    @Published var ticketSeat = ""
    @Published var ticketPhoto: UIImage?
    
    @Published var notes = ""
    
    @Published var selectedPhotoPickerItem: PhotosPickerItem? {
        didSet {
            Task { await loadImage(from: selectedPhotoPickerItem) }
        }
    }
    
    var isSaveEnabled: Bool {
        !homeTeam.isEmpty && !awayTeam.isEmpty
    }
    
    func switchTeams() {
        let temp = homeTeam
        homeTeam = awayTeam
        awayTeam = temp
    }
    
    func saveMatch() throws {
        let calendar = Calendar.current
        let dateComponents = calendar.dateComponents([.year, .month, .day], from: date)
        let timeComponents = calendar.dateComponents([.hour, .minute], from: time)
        
        var combinedComponents = DateComponents()
        combinedComponents.year = dateComponents.year
        combinedComponents.month = dateComponents.month
        combinedComponents.day = dateComponents.day
        combinedComponents.hour = timeComponents.hour
        combinedComponents.minute = timeComponents.minute
        
        let matchDate = calendar.date(from: combinedComponents) ?? Date()
        
        let match = MatchObject()
        match.league = league.isEmpty ? nil : league
        match.homeTeam = homeTeam
        match.awayTeam = awayTeam
        match.homeTeamShort = String(homeTeam.prefix(3)).uppercased()
        match.awayTeamShort = String(awayTeam.prefix(3)).uppercased()
        match.date = matchDate
        match.stadium = stadium.isEmpty ? nil : stadium
        match.isAttending = isAttending
        match.ticketSection = ticketSection.isEmpty ? nil : ticketSection
        match.ticketRow = ticketRow.isEmpty ? nil : ticketRow
        match.ticketSeat = ticketSeat.isEmpty ? nil : ticketSeat
        match.ticketPhotoData = ticketPhoto?.jpegData(compressionQuality: 0.8)
        match.notes = notes.isEmpty ? nil : notes
        
        try StorageManager.shared.addMatch(match: match)
    }
    
    private func loadImage(from item: PhotosPickerItem?) async {
        guard let item = item else { return }
        if let data = try? await item.loadTransferable(type: Data.self) {
            if let uiImage = UIImage(data: data) {
                ticketPhoto = uiImage
            }
        }
    }
}

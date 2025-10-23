//
//  AddMemoryViewModel.swift
//  FMatchFun
//
//  Created by D K on 18.08.2025.
//

import Foundation
import SwiftUI
import PhotosUI
import RealmSwift

@MainActor
class AddMemoryViewModel: ObservableObject {
    @Published var availableMatches: Results<MatchObject>?
    @Published var selectedMatch: MatchObject?
    
    @Published var selectedPhotoItems: [PhotosPickerItem] = [] {
        didSet {
            loadImages()
        }
    }
    @Published var loadedImages: [UIImage] = []
    
    @Published var description = ""
    @Published var tagsString = ""
    @Published var location = ""
    
    @Published var isUploading = false
    
    var isPostButtonEnabled: Bool {
        selectedMatch != nil && !loadedImages.isEmpty && !description.isEmpty
    }
    
    init() {
        availableMatches = StorageManager.shared.fetchMatches()
        selectedMatch = availableMatches?.first
    }
    
    private func loadImages() {
        isUploading = true
        Task {
            var images: [UIImage] = []
            for item in selectedPhotoItems {
                if let data = try? await item.loadTransferable(type: Data.self),
                   let image = UIImage(data: data) {
                    images.append(image)
                }
            }
            loadedImages = images
            isUploading = false
        }
    }
    
    func postMemory() throws {
        guard let match = selectedMatch else { return }
        
        let tags = tagsString.components(separatedBy: ",").map { $0.trimmingCharacters(in: .whitespaces) }.filter { !$0.isEmpty }
        let photoData = loadedImages.compactMap { $0.jpegData(compressionQuality: 0.8) }
        
        try StorageManager.shared.addMemory(
            match: match,
            description: description,
            tags: tags,
            location: location.isEmpty ? nil : location,
            photos: photoData
        )
    }
}

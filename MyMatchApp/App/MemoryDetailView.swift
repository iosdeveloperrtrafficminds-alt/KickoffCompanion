//
//  MemoryDetailView.swift
//  FMatchFun
//
//  Created by D K on 18.08.2025.
//

import SwiftUI
import RealmSwift

struct MemoryDetailView: View {
    @ObservedRealmObject var memory: MemoryObject
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading) {
                TabView {
                    ForEach(memory.photos) { photo in
                        if let uiImage = UIImage(data: photo.photoData) {
                            Image(uiImage: uiImage)
                                .resizable().scaledToFill()
                        }
                    }
                }
                .tabViewStyle(PageTabViewStyle())
                .frame(height: 350)
                
                VStack(alignment: .leading, spacing: 16) {
                    if let match = memory.match {
                        Text("\(match.homeTeam) vs \(match.awayTeam)")
                            .font(.largeTitle).bold()
                        Text(match.date.formatted(dateStyle: .long, timeStyle: .short))
                                    .foregroundColor(.themeSecondaryText)
                    }
                    
                    Text(memory.memoryDescription).font(.body)
                    
                    HStack {
                        ForEach(memory.tags, id: \.self) { tag in
                            Text("#\(tag)").font(.caption).bold()
                                .padding(8).background(Color.themeCardBackground).clipShape(Capsule())
                        }
                    }
                }
                .padding()
            }
        }
        .background(Color.themeBackground.ignoresSafeArea())
        .navigationTitle("Memory")
    }
}

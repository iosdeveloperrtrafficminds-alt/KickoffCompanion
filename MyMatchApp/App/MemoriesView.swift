//
//  MemoriesView.swift
//  FMatchFun
//
//  Created by D K on 18.08.2025.
//

import SwiftUI
import RealmSwift


struct MemoriesView: View {
    @StateObject private var viewModel = MemoriesViewModel()
    
    var body: some View {
            ZStack(alignment: .bottomTrailing) {
                Color.themeBackground.ignoresSafeArea()
                
                VStack(spacing: 0) {
                    HStack {
                        Text("Memories")
                            .font(.largeTitle).bold()
                        Spacer()
                    }
                    .padding()
                    
                    if let memories = viewModel.memories, !memories.isEmpty {
                        ScrollView {
                            VStack(spacing: 16) {
                                ForEach(memories) { memory in
                                    NavigationLink(destination: MemoryDetailView(memory: memory)) {
                                        MemoryCell(memory: memory)
                                    }
                                }
                            }
                            .padding(.bottom, 150)
                            .padding(.horizontal)
                        }
                    } else {
                        EmptyStateView(
                            icon: "photo.on.rectangle.angled",
                            title: "No memories yet",
                            message: "Tap + to add your first one!",
                            buttonTitle: nil,
                            action: {}
                        )
                    }
                }
                .foregroundColor(.themePrimaryText)
                
                FloatingActionButton { viewModel.isAddSheetPresented = true }
                    .padding(.bottom, 70)

            }
            .tint(.white)
            .navigationBarHidden(true)
            .sheet(isPresented: $viewModel.isAddSheetPresented) {
                AddMemoryView()
                    .onDisappear {
                        viewModel.setupObserver()
                    }
            }
        }
    }


private struct MemoryCell: View {
    @ObservedRealmObject var memory: MemoryObject
    
    var body: some View {
        ZStack(alignment: .bottomLeading) {
            if let photoData = memory.photos.first?.photoData, let uiImage = UIImage(data: photoData) {
                Image(uiImage: uiImage)
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(height: 200)
            } else {
                Rectangle()
                    .fill(Color.themeCardBackground)
                    .frame(height: 200)
            }
            
            LinearGradient(
                colors: [.clear, .black.opacity(0.8)],
                startPoint: .center,
                endPoint: .bottom
            )
            
            VStack(alignment: .leading, spacing: 4) {
                if let match = memory.match {
                    Text("\(match.homeTeam) vs \(match.awayTeam)")
                        .font(.headline).bold()
                }
                
                Text(memory.createdAt.formattedRelative())
                    .font(.caption)
                    .foregroundColor(.white.opacity(0.8))
                
                Text(memory.memoryDescription)
                    .font(.subheadline)
                    .foregroundColor(.white.opacity(0.9))
                    .lineLimit(2)
                    .padding(.top, 4)
            }
            .padding()
            .foregroundColor(.white)
        }
        .frame(height: 200)
        .cornerRadius(16)
    }
}

private struct EmptyStateView: View {
    let icon: String
    let title: String
    let message: String
    let buttonTitle: String?
    let action: () -> Void
    
    var body: some View {
        VStack(spacing: 16) {
            Spacer()
            
            Image(systemName: icon)
                .renderingMode(.template)
                .font(.system(size: 40))
                .foregroundColor(.themeSecondaryText)
                .padding(24)
                .background(Color.themeCardBackground)
                .clipShape(Circle())
            
            Text(title)
                .font(.title3).bold()
            
            Text(message)
                .font(.subheadline)
                .foregroundColor(.themeSecondaryText)
                .multilineTextAlignment(.center)
            
            if let buttonTitle = buttonTitle {
                Button(action: action) {
                    Label(buttonTitle, systemImage: "plus")
                }
                .buttonStyle(NewPrimaryButtonStyle())
                .padding(.top)
            }
            
            Spacer()
        }
        .frame(maxWidth: .infinity)
        .padding()
        .foregroundColor(.themePrimaryText)
    }
}


private struct NewPrimaryButtonStyle: ButtonStyle {
    @Environment(\.isEnabled) private var isEnabled
    
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.headline.bold())
            .padding()
            .frame(maxWidth: .infinity)
            .background(isEnabled ? Color.themeAccentRed : Color.themeSecondaryText)
            .foregroundColor(.white)
            .clipShape(Capsule())
            .scaleEffect(configuration.isPressed ? 0.98 : 1.0)
            .animation(.easeOut(duration: 0.2), value: configuration.isPressed)
    }
}



extension Date {
    func formatted(dateStyle: DateFormatter.Style, timeStyle: DateFormatter.Style) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = dateStyle
        formatter.timeStyle = timeStyle
        return formatter.string(from: self)
    }
    
    func formattedRelative() -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .none
        formatter.doesRelativeDateFormatting = true
        return formatter.string(from: self)
    }
}

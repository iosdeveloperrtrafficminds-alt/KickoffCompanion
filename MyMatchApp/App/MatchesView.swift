//
//  MatchesView.swift
//  FMatchFun
//
//  Created by D K on 18.08.2025.
//

import SwiftUI
import RealmSwift

#Preview {
    MatchesView()
}

struct MatchesView: View {
    @StateObject private var viewModel = MatchesViewModel()
    @State private var isSettingsShown = false
    
    var body: some View {
        NavigationView {
            ZStack(alignment: .bottomTrailing) {
                Color.themeBackground.ignoresSafeArea()
                
                VStack(alignment: .leading) {
                    Text("My Matches")
                        .font(.largeTitle).bold()
                        .padding([.horizontal, .top])
                        
                    
                    if let matches = viewModel.matches, !matches.isEmpty {
                        MatchesCarouselView(onTicketTap: { data in
                               viewModel.selectedTicketPhotoData = data
                           })
                    } else {
                        EmptyStateView()
                            .padding(.top, 100)
                    }
                    
                    Spacer()
                }
                .foregroundColor(.themePrimaryText)
                .overlay(alignment: .topTrailing) {
                    Button {
                        isSettingsShown.toggle()
                    } label: {
                        Image(systemName: "gear")
                            .foregroundStyle(.white)
                    }
                    .padding(.top, 25)
                    .padding(.trailing, 20)
                }
                
                FloatingActionButton {
                    viewModel.isAddMatchSheetPresented = true
                }
                .padding(.bottom, 70)
            }
          
            .navigationBarHidden(true)
            .sheet(isPresented: $viewModel.isAddMatchSheetPresented) {
                AddMatchView()
            }
            .fullScreenCover(item: $viewModel.selectedTicketPhotoData) { data in
                TicketDetailView(photoData: data)
            }
        }
      
        .fullScreenCover(isPresented: $isSettingsShown) {
            SettingsView()
        }
    }
}



private struct MatchesCarouselView: View {
    @ObservedResults(MatchObject.self, sortDescriptor: SortDescriptor(keyPath: "date")) var matches
    @State private var currentIndex = 0
    let onTicketTap: (Data) -> Void
    
    var body: some View {
        VStack {
            TabView(selection: $currentIndex) {
                ForEach(matches.indices, id: \.self) { index in
                    NavigationLink(destination: MatchDetailView(match: matches[index])) {
                        MatchCard(match: matches[index], onTicketTap: onTicketTap)
                    }
                    .tag(index)
                }
            }
            .tabViewStyle(PageTabViewStyle(indexDisplayMode: .never))
            .frame(height: 450)
            
            PageIndicator(pageCount: matches.count, currentIndex: $currentIndex)
        }
    }
}



private struct MatchCard: View {
    @ObservedRealmObject var match: MatchObject
    let onTicketTap: (Data) -> Void
    
    var body: some View {
        ZStack(alignment: .bottom) {
            Image("stadium_background")
                .resizable().aspectRatio(contentMode: .fill)
                .frame(height: 424)
            
            LinearGradient(colors: [.clear, .black.opacity(0.8)], startPoint: .center, endPoint: .bottom)
            
            VStack(alignment: .leading, spacing: 12) {
                HStack {
                    Text(match.date.formatted(.relative(presentation: .named)))
                    Text("· \(match.date.formatted(date: .omitted, time: .shortened))")
                }
                .font(.caption.bold())
                .padding(.horizontal, 12).padding(.vertical, 6)
                .background(.thinMaterial).clipShape(Capsule())
                
                Text("\(match.homeTeam) vs \(match.awayTeam)")
                    .font(.title).bold()
                
                Label(match.stadium ?? "Stadium unknown", systemImage: "mappin.and.ellipse")
                
                Spacer()
                
                if let ticketPhoto = match.ticketPhotoData {
                    TicketPreview(match: match)
                        .onTapGesture { onTicketTap(ticketPhoto) }
                } else {
                    HStack {
                        VStack(alignment: .leading) {
                            Text("Ticket not added").bold()
                        }
                        Spacer()
                        
                    }
                    .font(.caption)
                    .padding(12)
                    .background(.ultraThinMaterial)
                    .cornerRadius(16)
                }
            }
            .padding(24)
            .foregroundColor(.white)
        }
        .frame(height: 424)
        .cornerRadius(24)
        .padding(.horizontal)
    }
}

private struct TicketPreview: View {
    @ObservedRealmObject var match: MatchObject
    var body: some View {
        HStack {
            VStack(alignment: .leading) {
                Text("Season Ticket").bold()
                Text("Section \(match.ticketSection ?? "-"), Row \(match.ticketRow ?? "-"), Seat \(match.ticketSeat ?? "-")")
            }
            Spacer()
            HStack {
                Text(match.homeTeamShort).bold()
                Text("vs")
                Text(match.awayTeamShort).bold()
            }
            .padding(8).background(Color.black.opacity(0.3)).clipShape(Capsule())
        }
        .font(.caption)
        .padding(12)
        .background(.ultraThinMaterial)
        .cornerRadius(16)
    }
}

private struct PageIndicator: View {
    let pageCount: Int
    @Binding var currentIndex: Int
    
    var body: some View {
        HStack(spacing: 8) {
            ForEach(0..<pageCount, id: \.self) { index in
                Circle()
                    .fill(index == currentIndex ? Color.themeAccentRed : Color.themeCardBackground)
                    .frame(width: 8, height: 8)
            }
        }
    }
}

private struct EmptyStateView: View {
    var body: some View {
        VStack(spacing: 16) {
            Image(systemName: "soccerball.inverse")
                .renderingMode(.template)
                .foregroundColor(.themeSecondaryText)
                .font(.system(size: 40))
                .padding(24)
                .background(Color.themeCardBackground)
                .clipShape(Circle())
            
            Text("No matches added yet")
                .font(.title3).bold()
            
            Text("Tap + to add your first one!")
                .font(.subheadline)
                .foregroundColor(.themeSecondaryText)
        }
        .frame(maxWidth: .infinity)
    }
}

 struct FloatingActionButton: View {
    var action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Image(systemName: "plus")
                .font(.title.weight(.semibold))
                .foregroundColor(.white)
                .padding(20)
                .background(Color.themeAccentRed)
                .clipShape(Circle())
                .shadow(color: .themeAccentRed.opacity(0.5), radius: 10, y: 5)
        }
        .padding()
    }
}

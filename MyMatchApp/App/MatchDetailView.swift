//
//  MatchDetailView.swift
//  FMatchFun
//
//  Created by D K on 18.08.2025.
//

import SwiftUI
import RealmSwift

struct MatchDetailView: View {
    @ObservedRealmObject var match: MatchObject
    @Environment(\.presentationMode) var presentationMode
    @State private var isDeleteAlertPresented = false
    @State private var isTicketPresented = false
    
    var body: some View {
        ZStack {
            Color.themeBackground.ignoresSafeArea()
            
            ScrollView {
                VStack(alignment: .leading, spacing: 24) {
                    MatchHeader(match: match)
                    
                    InfoRow(icon: "mappin.circle.fill", text: match.stadium ?? "Unknown Stadium")
                    
                    InfoRow(icon: "calendar", text: match.date.formatted(date: .complete, time: .shortened))
                    
                    if match.ticketPhotoData != nil {
                        Button(action: { isTicketPresented = true }) {
                            InfoRow(icon: "ticket.fill", text: "Section \(match.ticketSection ?? "-"), Row \(match.ticketRow ?? "-"), Seat \(match.ticketSeat ?? "-")")
                        }
                    } else if let section = match.ticketSection {
                        InfoRow(icon: "ticket.fill", text: "Section \(section), Row \(match.ticketRow ?? "-"), Seat \(match.ticketSeat ?? "-")")
                    }
                    
                    if let notes = match.notes, !notes.isEmpty {
                        NotesSection(text: notes)
                    }
                }
                .padding(.horizontal, 20)
                .fullScreenCover(isPresented: $isTicketPresented) {
                    if let photoData = match.ticketPhotoData {
                        TicketDetailView(photoData: photoData)
                    }
                }
            }
        }
        .foregroundColor(.white)
        .navigationBarBackButtonHidden(true)
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                Button(action: { presentationMode.wrappedValue.dismiss() }) { Image(systemName: "arrow.left").foregroundStyle(.white) }
            }
            ToolbarItem(placement: .principal) {
                Text("Match Details")
            }
            ToolbarItem(placement: .navigationBarTrailing) {
                Button("Delete") { isDeleteAlertPresented = true }.tint(.themeAccentRed)
            }
        }
        .alert("Delete Match", isPresented: $isDeleteAlertPresented) {
            Button("Cancel", role: .cancel) {}
            Button("Delete", role: .destructive) {
                try? StorageManager.shared.deleteMatch(withId: match._id)
                presentationMode.wrappedValue.dismiss()
            }
        } message: {
            Text("Are you sure you want to delete this match? This action cannot be undone.")
        }
    }
}

private struct MatchHeader: View {
    @ObservedRealmObject var match: MatchObject
    var body: some View {
        VStack {
            Text(match.date.formatted(.relative(presentation: .named)) + " · " + match.date.formatted(date: .omitted, time: .shortened))
                .font(.caption).padding(.horizontal, 10).padding(.vertical, 5)
                .background(Color.themeCardBackground).clipShape(Capsule())
            
            HStack {
                TeamLogo(text: match.homeTeamShort, name: match.homeTeam)
                Spacer()
                VStack {
                    Text(match.league ?? "").font(.subheadline)
                    Text("VS").font(.title2.bold())
                    if match.isAttending {
                        Text("You're going!").font(.caption).bold().foregroundColor(.green)
                    }
                }
                Spacer()
                TeamLogo(text: match.awayTeamShort, name: match.awayTeam)
            }
        }
    }
}

private struct TeamLogo: View {
    let text: String
    let name: String
    var body: some View {
        VStack {
            Text(text).font(.title.bold())
                .frame(width: 80, height: 80).background(Color.white).foregroundColor(.black).clipShape(Circle())
            Text(name).font(.headline)
        }
    }
}

private struct InfoRow: View {
    let icon: String
    let text: String
    var body: some View {
        HStack {
            Image(systemName: icon).foregroundColor(.themeSecondaryText).frame(width: 24)
            Text(text)
        }
        .padding()
        .background(Color.themeCardBackground).cornerRadius(12)
    }
}

private struct NotesSection: View {
    let text: String
    var body: some View {
        VStack(alignment: .leading) {
            Text("NOTES")
                .font(.caption)
                .foregroundColor(.themeSecondaryText)
            
            Text(text)
                .padding()
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(Color.themeCardBackground)
                .cornerRadius(12)
        }
    }
}

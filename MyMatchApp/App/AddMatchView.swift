//
//  AddMatchView.swift
//  FMatchFun
//
//  Created by D K on 18.08.2025.
//

import SwiftUI
import PhotosUI

#Preview {
    AddMatchView()
}

struct AddMatchView: View {
    @StateObject private var viewModel = AddMatchViewModel()
    @Environment(\.presentationMode) var presentationMode
    
    var body: some View {
        ZStack {
            Color.themeBackground.ignoresSafeArea()
            
            VStack(spacing: 0) {
                HeaderView { presentationMode.wrappedValue.dismiss() }
                
                ScrollView {
                    VStack(alignment: .leading, spacing: 24) {
                        TitledSection(title: "LEAGUE") {
                            CustomTextField(placeholder: "Premier League", text: $viewModel.league)
                        }
                        
                        TitledSection(title: "TEAMS") {
                            TeamsSelectionView(homeTeam: $viewModel.homeTeam, awayTeam: $viewModel.awayTeam, onSwitch: viewModel.switchTeams)
                        }
                        
                        TitledSection(title: "DATE & TIME") {
                            HStack {
                                DatePickerButton(date: $viewModel.date)
                                    .tint(.themeAccentRed)
                                TimePickerButton(time: $viewModel.time)
                                    .tint(.themeAccentRed)

                            }
                        }
                        
                        TitledSection(title: "STADIUM") {
                            CustomTextField(placeholder: "Emirates Stadium", icon: "mappin.and.ellipse", text: $viewModel.stadium)
                        }
                        
                        TitledSection(title: "ARE YOU ATTENDING?") {
                            AttendanceToggle(isAttending: $viewModel.isAttending)
                        }
                        
                        if viewModel.isAttending {
                            TitledSection(title: "TICKET DETAILS (OPTIONAL)") {
                                TicketDetailsView(
                                    section: $viewModel.ticketSection,
                                    row: $viewModel.ticketRow,
                                    seat: $viewModel.ticketSeat,
                                    photo: $viewModel.ticketPhoto,
                                    selectedItem: $viewModel.selectedPhotoPickerItem
                                )
                            }
                        }
                        
                        TitledSection(title: "NOTES (OPTIONAL)") {
                            CustomTextEditor(placeholder: "Add any additional notes...", text: $viewModel.notes)
                        }
                    }
                    .padding()
                }
                
                Button("Save Match") {
                    try? viewModel.saveMatch()
                    presentationMode.wrappedValue.dismiss()
                }
                .buttonStyle(PrimaryButtonStyle())
                .disabled(!viewModel.isSaveEnabled)
                .padding()
            }
            .foregroundColor(.themePrimaryText)
        }
    }
}


private struct HeaderView: View {
    let onDismiss: () -> Void
    var body: some View {
        HStack {
            Button(action: onDismiss) {
                Image(systemName: "arrow.left")
                    .font(.title3.weight(.bold))
            }
            Spacer()
            Text("Add New Match")
            Spacer()
            Image(systemName: "arrow.left").opacity(0)
        }
        .padding()
    }
}

private struct TitledSection<Content: View>: View {
    let title: String
    @ViewBuilder let content: Content
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(title).font(.caption).foregroundColor(.themeSecondaryText)
            content
        }
    }
}

private struct TeamsSelectionView: View {
    @Binding var homeTeam: String
    @Binding var awayTeam: String
    let onSwitch: () -> Void
    
    var body: some View {
        VStack(spacing: 16) {
            HStack(spacing: 16) {
                Spacer()
                TeamLogo(text: String(homeTeam.prefix(3)).uppercased())
                Spacer()
                Text("VS").font(.headline)
                Spacer()
                TeamLogo(text: String(awayTeam.prefix(3)).uppercased())
                Spacer()
            }
            
            HStack {
                CustomTextField(placeholder: "1 Team", text: $homeTeam)
                    .shadow(color: .white, radius: 0.4)
                    .multilineTextAlignment(.center)

                CustomTextField(placeholder: "2 Team", text: $awayTeam)
                    .shadow(color: .white, radius: 0.4)
                    .multilineTextAlignment(.center)

            }
            
            Button(action: onSwitch) {
                Label("Switch Teams", systemImage: "arrow.left.arrow.right")
                    .font(.caption.bold())
                    .foregroundColor(.themeAccentRed)
            }
        }
        .padding()
        .background(Color.themeCardBackground)
        .cornerRadius(16)
    }
}


private struct TicketDetailsView: View {
    @Binding var section: String
    @Binding var row: String
    @Binding var seat: String
    @Binding var photo: UIImage?
    @Binding var selectedItem: PhotosPickerItem?
    
    var body: some View {
        VStack(spacing: 12) {
            CustomTextField(placeholder: "Section", text: $section)
            CustomTextField(placeholder: "Row", text: $row)
            CustomTextField(placeholder: "Seat", text: $seat)
            
            PhotosPicker(selection: $selectedItem, matching: .images) {
                if let photo = photo {
                    Image(uiImage: photo)
                        .resizable().scaledToFit().cornerRadius(8)
                } else {
                    Label("Add Ticket Photo", systemImage: "plus.circle.fill")
                        .font(.caption.bold())
                        .foregroundColor(.themeAccentRed)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(.top, 8)
                }
            }
        }
    }
}


 struct PrimaryButtonStyle: ButtonStyle {
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


 struct CustomTextField: View {
    let placeholder: String
    var icon: String? = nil
    @Binding var text: String
    
    var body: some View {
        HStack {
            if let icon = icon {
                Image(systemName: icon)
                    .foregroundColor(.themeSecondaryText)
            }
            TextField(placeholder, text: $text)
                .tint(.red)
                .colorMultiply(.white)
                
        }
        .padding()
        .background(Color.themeCardBackground)
        .cornerRadius(12)
        .foregroundColor(.themePrimaryText)
    }
}

 struct CustomTextEditor: View {
    let placeholder: String
    @Binding var text: String
    
    var body: some View {
        ZStack(alignment: .topLeading) {
            TextEditor(text: $text)
                .scrollContentBackground(.hidden)
                .padding(12)
                .frame(minHeight: 100)
                .background(Color.themeCardBackground)
                .cornerRadius(12)
                .foregroundColor(.themePrimaryText)
            
            if text.isEmpty {
                Text(placeholder)
                    .foregroundColor(.themeSecondaryText)
                    .padding()
                    .allowsHitTesting(false)
            }
        }
    }
}


private struct DatePickerButton: View {
    @Binding var date: Date
    
    var body: some View {
        DatePicker(
            "",
            selection: $date,
            displayedComponents: .date
        )
        .labelsHidden()
        .padding()
        .frame(maxWidth: .infinity)
        .background(Color.themeCardBackground)
        .cornerRadius(12)
        .colorScheme(.dark)
    }
}

private struct TimePickerButton: View {
    @Binding var time: Date
    
    var body: some View {
        DatePicker(
            "",
            selection: $time,
            displayedComponents: .hourAndMinute
        )
        .labelsHidden()
        .padding()
        .background(Color.themeCardBackground)
        .cornerRadius(12)
        .colorScheme(.dark)
    }
}


private struct AttendanceToggle: View {
    @Binding var isAttending: Bool
    
    var body: some View {
        HStack(spacing: 0) {
            Button(action: { isAttending = true }) {
                Text("Yes")
                    .bold()
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(isAttending ? Color.themeAccentRed : Color.clear)
                    .foregroundColor(.white)
            }
            
            Button(action: { isAttending = false }) {
                Text("No")
                    .bold()
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(!isAttending ? Color.themeAccentRed : Color.clear)
                    .foregroundColor(.white)
            }
        }
        .background(Color.themeCardBackground)
        .cornerRadius(12)
    }
}

private struct TeamLogo: View {
    let text: String
    
    var body: some View {
        Text(text.isEmpty ? "?" : text)
            .font(.headline).bold()
            .frame(width: 50, height: 50)
            .background(Color.white)
            .foregroundColor(.black)
            .clipShape(Circle())
    }
}

//
//  BingoView.swift
//  FMatchFun
//
//  Created by D K on 18.08.2025.
//

import SwiftUI
import RealmSwift

struct BingoView: View {
    @ObservedObject var viewModel: FunMatchViewModel
    
    private let columns = [GridItem(.flexible()), GridItem(.flexible()), GridItem(.flexible())]
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 24) {
                TitledSection(title: "Select Match") {
                    if let match = viewModel.selectedMatch {
                                            SelectedMatchCard(match: match) {
                                                viewModel.isMatchSelectionPresented = true
                                            }
                                        } else {
                        Text("No matches added yet.").foregroundColor(.themeSecondaryText)
                    }
                }
                .padding(.horizontal)
                
                TitledSection(title: "Match Bingo") {
                    LazyVGrid(columns: columns, spacing: 8) {
                        ForEach($viewModel.bingoItems) { $item in
                            BingoCell(item: $item)
                        }
                    }
                }
                .padding(.horizontal)
                
                Button("Customize Bingo Card") {
                    viewModel.startCustomizing()
                }
                .font(.headline).foregroundColor(.themeAccentRed)
                .frame(maxWidth: .infinity)
            }
            .padding(.bottom, 150)
        }
        .sheet(isPresented: $viewModel.isCustomizing) {
            CustomizeBingoView(viewModel: viewModel)
        }
        .sheet(isPresented: $viewModel.isMatchSelectionPresented) {
                    MatchSelectionView(selectedMatch: $viewModel.selectedMatch)
                }
    }
}

private struct SelectedMatchCard: View {
    @ObservedRealmObject var match: MatchObject
    var onChangeTapped: () -> Void
    var body: some View {
        HStack {
            Text(match.homeTeamShort).bold()
            VStack {
                Text(match.date.formattedRelative()).font(.caption)
                Text("VS").bold()
                Text(match.stadium ?? "").font(.caption)
            }
            Text(match.awayTeamShort).bold()
            Spacer()
            Button("Change", action: onChangeTapped)
        }
        .padding().background(Color.themeCardBackground).cornerRadius(12)
    }
}

private struct BingoCell: View {
    @Binding var item: BingoItem
    
    var body: some View {
        Button(action: { item.isComplete.toggle() }) {
            Text(item.text)
                .font(.caption).bold()
                .multilineTextAlignment(.center)
                .frame(minHeight: 80)
                .padding(4)
                .frame(maxWidth: .infinity)
                .background(item.isComplete ? Color.themeAccentRed.opacity(0.5) : Color.themeCardBackground)
                .cornerRadius(12)
                .overlay(RoundedRectangle(cornerRadius: 12).stroke(item.isComplete ? Color.themeAccentRed : Color.clear, lineWidth: 2))
        }
    }
}

struct CustomizeBingoView: View {
    @ObservedObject var viewModel: FunMatchViewModel
    @Environment(\.presentationMode) var presentationMode
    
    var body: some View {
        NavigationView {
            List {
                ForEach($viewModel.customizationItems) { $item in
                    HStack {
                        Button(action: {}) { Image(systemName: "line.3.horizontal") }
                            .foregroundColor(.themeSecondaryText)
                        
                        TextField("Event name", text: $item.text)
                    }
                }
                .onDelete(perform: viewModel.deleteCustomItem)
                
                Button(action: viewModel.addNewCustomItem) {
                    Label("Add new event...", systemImage: "plus")
                }
            }
            .listStyle(InsetGroupedListStyle())
            .navigationTitle("Customize Bingo")
            .navigationBarItems(
                leading: Button(action: { presentationMode.wrappedValue.dismiss() }) { Image(systemName: "xmark") },
                trailing: Button("Save") { viewModel.saveCustomization() }
            )
        
        }
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


struct MatchSelectionView: View {
    
    @ObservedResults(MatchObject.self, sortDescriptor: SortDescriptor(keyPath: "date")) var matches
    @Binding var selectedMatch: MatchObject?
    @Environment(\.presentationMode) var presentationMode
    
    var body: some View {
        NavigationView {
            List(matches) { match in
                Button(action: {
                    selectedMatch = match
                    presentationMode.wrappedValue.dismiss()
                }) {
                    HStack {
                        VStack(alignment: .leading) {
                            Text("\(match.homeTeam) vs \(match.awayTeam)")
                                .font(.headline)
                            Text(match.date, style: .date)
                                .font(.subheadline)
                                .foregroundColor(.themeSecondaryText)
                        }
                        
                        Spacer()
                        
                        if selectedMatch?._id == match._id {
                            Image(systemName: "checkmark.circle.fill")
                                .foregroundColor(.themeAccentRed)
                        }
                    }
                }
                .foregroundColor(.themePrimaryText)
            }
            .listStyle(InsetGroupedListStyle())
            .navigationTitle("Select a Match")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        presentationMode.wrappedValue.dismiss()
                    }
                }
            }
        }
    }
}

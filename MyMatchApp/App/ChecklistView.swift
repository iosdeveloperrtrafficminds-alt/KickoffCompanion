//
//  ChecklistView.swift
//  FMatchFun
//
//  Created by D K on 18.08.2025.
//

import SwiftUI
import RealmSwift

#Preview {
    ChecklistView()
}


struct ChecklistView: View {
    @StateObject private var viewModel = ChecklistViewModel()
    
    var body: some View {
        NavigationView {
            ZStack {
                Color.themeBackground.ignoresSafeArea()
                
                VStack {
                    if let essential = viewModel.essentialItems, let personal = viewModel.personalItems {
                        if essential.isEmpty && personal.isEmpty && !viewModel.isAddingItem {
                            EmptyStateView { viewModel.isAddingItem = true }
                        } else {
                            ScrollView {
                                VStack(alignment: .leading, spacing: 24) {
                                    
                                    
                                    ChecklistSection(
                                        title: "Personal Items",
                                        items: personal,
                                        viewModel: viewModel,
                                        canDelete: true
                                    )
                                    
                                    if viewModel.isAddingItem {
                                        AddItemView(
                                            name: $viewModel.newItemName,
                                            description: $viewModel.newItemDescription,
                                            onSave: viewModel.addItem,
                                            onCancel: { viewModel.isAddingItem = false }
                                        )
                                        .transition(.opacity)
                                    } else {
                                        AddCustomItemButton {
                                            withAnimation {
                                                viewModel.isAddingItem = true
                                            }
                                        }
                                    }
                                }
                                .padding()
                                .padding(.bottom, 150)
                            }
                        }
                    } else {
                        ProgressView()
                    }
                }
                
                if let essential = viewModel.essentialItems, let personal = viewModel.personalItems {
                    if essential.isEmpty && personal.isEmpty && !viewModel.isAddingItem {
                        if !viewModel.isAddingItem {
                            FloatingActionButton {
                                withAnimation {
                                    viewModel.isAddingItem = true
                                }
                            }
                            .padding(.bottom, 60)
                        }
                    }
                }
               
            }
            .navigationTitle("Matchday Checklist")
        }
    }
}


private struct ChecklistSection: View {
    let title: String
    let items: Results<ChecklistItemObject>
    @ObservedObject var viewModel: ChecklistViewModel
    let canDelete: Bool
    
    var body: some View {
        VStack(alignment: .leading) {
            Text(title).font(.headline).foregroundColor(.themeSecondaryText)
            
            VStack(spacing: 12) {
                ForEach(items) { item in
                    ChecklistItemCell(item: item, canDelete: canDelete) {
                        viewModel.deletePersonalItem(item)
                    }
                    .onTapGesture {
                        viewModel.toggleItem(item)
                    }
                }
            }
        }
    }
}


private struct ChecklistItemCell: View {
    @ObservedRealmObject var item: ChecklistItemObject
    let canDelete: Bool
    let onDelete: () -> Void
    
    var body: some View {
        HStack(spacing: 16) {
            Image(systemName: item.isCompleted ? "checkmark.square.fill" : "square")
                .font(.title2)
                .foregroundColor(item.isCompleted ? .themeAccentRed : .themeSecondaryText)
            
            VStack(alignment: .leading) {
                Text(item.name).bold()
                    .strikethrough(item.isCompleted)
                if let desc = item.itemDescription, !desc.isEmpty {
                    Text(desc).font(.caption).foregroundColor(.themeSecondaryText)
                }
            }
            
            Spacer()
            
            if canDelete {
                Button(action: onDelete) {
                    Image(systemName: "trash")
                        .foregroundColor(.themeSecondaryText)
                }
            }
        }
        .padding()
        .background(Color.themeCardBackground)
        .cornerRadius(12)
        .foregroundColor(.themePrimaryText)
    }
}

private struct AddItemView: View {
    @Binding var name: String
    @Binding var description: String
    let onSave: () -> Void
    let onCancel: () -> Void
    
    var body: some View {
        VStack(spacing: 12) {
            CustomTextField(placeholder: "Name item", text: $name)
            CustomTextField(placeholder: "Description", text: $description)
            HStack {
                Button("Cancel", action: onCancel)
                    .buttonStyle(SecondaryButtonStyle())
                
                Button("Save", action: onSave)
                    .buttonStyle(NewPrimaryButtonStyle())
                    .disabled(name.isEmpty)
            }
        }
        .padding()
        .background(Color.themeCardBackground)
        .cornerRadius(12)
    }
}

private struct AddCustomItemButton: View {
    let action: () -> Void
    var body: some View {
        Button(action: action) {
            Label("Add custom item", systemImage: "plus")
                .font(.headline)
                .foregroundColor(.themeAccentRed)
                .padding()
                .frame(maxWidth: .infinity)
                .background(Color.clear)
                .overlay(RoundedRectangle(cornerRadius: 12).strokeBorder(style: StrokeStyle(lineWidth: 2, dash: [5])).foregroundStyle(Color.themeAccentRed))
        }
    }
}

private struct EmptyStateView: View {
    let action: () -> Void
    var body: some View {
        VStack {
            Spacer()
            Image("icon_ball").renderingMode(.template)
                .font(.system(size: 40)).foregroundColor(.themeSecondaryText)
                .padding(24).background(Color.themeCardBackground).clipShape(Circle())
            
            Text("No Items yet").font(.title3).bold().padding(.top)
            Text("Tap + to add your first one!").font(.subheadline).foregroundColor(.themeSecondaryText)
            Spacer()
        }
    }
}

private struct NewPrimaryButtonStyle: ButtonStyle {
    @Environment(\.isEnabled) private var isEnabled
    func makeBody(configuration: Configuration) -> some View {
        configuration.label.font(.headline.bold()).padding()
            .frame(maxWidth: .infinity)
            .background(isEnabled ? Color.themeAccentRed : Color.themeSecondaryText)
            .foregroundColor(.white).clipShape(Capsule())
    }
}

private struct SecondaryButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label.font(.headline.bold()).padding()
            .frame(maxWidth: .infinity)
            .background(Color.themeSecondaryText.opacity(0.2))
            .foregroundColor(.white).clipShape(Capsule())
    }
}

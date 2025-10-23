//
//  View + Extension.swift
//  FMatchFun
//
//  Created by D K on 18.08.2025.
//

import SwiftUI

enum Tab: Int {
    case matches, checklist, fun, memories
}

struct MainView: View {
    
    @State private var selectedTab: Tab = .matches
    
    init() {
        UITabBar.appearance().isHidden = true
    }
    
    var body: some View {
        NavigationStack {
            ZStack {
                VStack(spacing: 0) {
                    switch selectedTab {
                    case .matches:
                        MatchesView()
                    case .checklist:
                        ChecklistView()
                    case .fun:
                        FunMatchView()
                    case .memories:
                        MemoriesView()
                    }
                }
                
                VStack {
                    Spacer()
                    CustomTabBar(selectedTab: $selectedTab)
                }
            }
            .ignoresSafeArea(.keyboard)
        }
        .tint(.white)

    }
}

private struct CustomTabBar: View {
    @Binding var selectedTab: Tab
    
    var body: some View {
        HStack {
            TabItem(iconName: "icon_matches", title: "My Matches", tab: .matches, selectedTab: $selectedTab)
            TabItem(iconName: "icon_checklist", title: "Checklist", tab: .checklist, selectedTab: $selectedTab)
            TabItem(iconName: "icon_fun", title: "Fun Match", tab: .fun, selectedTab: $selectedTab)
            TabItem(iconName: "icon_memories", title: "Memories", tab: .memories, selectedTab: $selectedTab)
        }
        .padding(.top, 12)
        .frame(height: 80)
        .background(Color.themeCardBackground)
    }
}

private struct TabItem: View {
    let iconName: String
    let title: String
    let tab: Tab
    @Binding var selectedTab: Tab
    
    var isSelected: Bool {
        selectedTab == tab
    }
    
    var body: some View {
        Button(action: {
            selectedTab = tab
        }) {
            VStack(spacing: 4) {
                Image(iconName)
                    .resizable()
                    .renderingMode(.template)
                    .scaledToFill()
                    .frame(width: 20, height: 20)
                    .foregroundColor(isSelected ? .themeAccentRed : .themeSecondaryText)
                
                Text(title)
                    .font(.caption)
                    .bold()
                    .foregroundColor(isSelected ? .white : .themeSecondaryText)
                    .padding(.top, 10)
            }
            .frame(maxWidth: .infinity)
        }
    }
}

#Preview {
    MainView()
}

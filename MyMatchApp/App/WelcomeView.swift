//
//  OnboardingView.swift
//  FMatchFun
//
//  Created by D K on 18.08.2025.
//

import SwiftUI

private struct OnboardingPage: Identifiable {
    let id = UUID()
    let iconName: String
    let title: String
    let description: String
}

struct WelcomeView: View {
    @AppStorage("hasCompletedOnboarding") private var hasCompletedOnboarding = false
    @State private var currentPageIndex = 0
    
    private let pages: [OnboardingPage] = [
        OnboardingPage(
            iconName: "soccerball",
            title: "Welcome!",
            description: "Your ultimate companion for the perfect match day experience."
        ),
        OnboardingPage(
            iconName: "list.bullet.clipboard.fill",
            title: "Plan Your Matchday",
            description: "Never forget a thing. Add matches to your calendar and use the checklist to prepare."
        ),
        OnboardingPage(
            iconName: "gamecontroller.fill",
            title: "Have Fun!",
            description: "Play match bingo, generate chants with AI, and show your colors with Big Text Mode."
        ),
        OnboardingPage(
            iconName: "photo.on.rectangle.angled",
            title: "Capture the Moment",
            description: "Save your best photos and notes from every match and build your personal fan history."
        )
    ]

    var body: some View {
        ZStack {
            Color.themeBackground.ignoresSafeArea()
            
            VStack {
                TabView(selection: $currentPageIndex.animation(.easeInOut)) {
                    ForEach(pages.indices, id: \.self) { index in
                        OnboardingPageView(page: pages[index])
                            .tag(index)
                    }
                }
                .tabViewStyle(.page(indexDisplayMode: .never))
                
                VStack(spacing: 20) {
                    PageIndicator(pageCount: pages.count, currentIndex: $currentPageIndex)
                    
                    Button(action: {
                        if currentPageIndex < pages.count - 1 {
                            currentPageIndex += 1
                        } else {
                            hasCompletedOnboarding = true

                        }
                    }) {
                        Text(currentPageIndex == pages.count - 1 ? "Start" : "Next")
                    }
                    .buttonStyle(PrimaryButtonStyle())
                }
                .padding(30)
            }
        }
    }
}


private struct OnboardingPageView: View {
    let page: OnboardingPage
    @State private var isAnimating: Bool = false
    
    var body: some View {
        VStack(spacing: 32) {
            Image(systemName: page.iconName)
                .font(.system(size: 100, weight: .bold))
                .foregroundColor(.themeAccentRed)
                .shadow(color: .themeAccentRed.opacity(0.5), radius: 20)
                .scaleEffect(isAnimating ? 1.0 : 0.8)
                .opacity(isAnimating ? 1.0 : 0.0)
            
            VStack(spacing: 12) {
                Text(page.title)
                    .font(.largeTitle).bold()
                
                Text(page.description)
                    .font(.title3)
                    .foregroundColor(.themeSecondaryText)
            }
            .multilineTextAlignment(.center)
            .opacity(isAnimating ? 1.0 : 0.0)
            .offset(y: isAnimating ? 0 : 30)
            
            Spacer()
        }
        .padding(40)
        .foregroundColor(.themePrimaryText)
        .onAppear {
            withAnimation(.spring(response: 0.6, dampingFraction: 0.7)) {
                isAnimating = true
            }
        }
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

#Preview {
    WelcomeView()
}

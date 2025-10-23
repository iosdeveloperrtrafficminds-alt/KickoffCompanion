//
//  AppEntryView.swift
//  MyMatchApp
//
//  Created by D K on 18.10.2025.
//

import SwiftUI

struct InitView: View {
    @AppStorage("hasCompletedOnboarding") private var hasCompletedOnboarding: Bool = false
    
    var body: some View {
        ZStack {
            if hasCompletedOnboarding {
                MainView()
            } else {
                WelcomeView()
            }
        }
        .animation(.easeInOut, value: hasCompletedOnboarding)
        .onAppear(perform: UIApplication.shared.addTapGestureRecognizer)
        
    }
}

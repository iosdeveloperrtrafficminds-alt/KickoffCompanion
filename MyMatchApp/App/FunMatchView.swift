//
//  FunMatchView.swift
//  FMatchFun
//
//  Created by D K on 18.08.2025.
//


import SwiftUI

struct FunMatchView: View {
    @StateObject private var viewModel = FunMatchViewModel()
    
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                Picker("Mode", selection: $viewModel.selectedMode.animation()) {
                    ForEach(FunMatchMode.allCases, id: \.self) {
                        Text($0.rawValue).tag($0)
                    }
                }
                .pickerStyle(SegmentedPickerStyle())
                .padding()
                
                switch viewModel.selectedMode {
                case .bingo:
                    BingoView(viewModel: viewModel)
                case .quiz:
                    BigTextView(viewModel: viewModel)
                        .padding(.horizontal)
                case .chants:
                    ChantsView(viewModel: viewModel)
                }
                
                Spacer()
            }
            .background(Color.themeBackground.ignoresSafeArea())
            .foregroundColor(.themePrimaryText)
            .navigationTitle("Fun Match")
        }
    }
}

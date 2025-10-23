//
//  BigTextView.swift
//  FMatchFun
//
//  Created by D K on 18.08.2025.
//

import SwiftUI

struct BigTextFullScreenView: View {
    let text: String
    let backgroundColor: Color
    let textColor: Color
    let fontSize: CGFloat
    
    @Environment(\.presentationMode) var presentationMode
    
    var body: some View {
        ZStack(alignment: .topTrailing) {
            backgroundColor.ignoresSafeArea()
            
            GeometryReader { geometry in
                VStack {
                    Text(text)
                        .font(.system(size: fontSize, weight: .bold))
                        .foregroundColor(textColor)
                        .multilineTextAlignment(.center)
                        .minimumScaleFactor(0.1)
                }
                .frame(width: geometry.size.height, height: geometry.size.width)
                .rotationEffect(.degrees(90))
                .position(x: geometry.size.width / 2, y: geometry.size.height / 2)
            }
            
            Button(action: { presentationMode.wrappedValue.dismiss() }) {
                Image(systemName: "xmark.circle.fill")
                    .font(.largeTitle)
                    .foregroundColor(.white.opacity(0.5))
            }
            .padding()
        }
    }
}

struct BigTextView: View {
    @ObservedObject var viewModel: FunMatchViewModel
    @State private var isFullScreen = false
    
    let backgroundColors: [Color] = [.themeAccentRed, .white, .gray, .purple, .black, .orange]
    let textColors: [Color] = [.white, .red, .yellow, .cyan, .black, .green]
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 24) {
                
                TitledSection(title: "Big Text Mode") {
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Display text in full screen mode. Perfect for showing chants, messages, or team slogans during matches.")
                            .font(.subheadline)
                            .foregroundColor(.themeSecondaryText)
                        
                        Button("Start Big Text Mode") { isFullScreen = true }
                            .buttonStyle(PrimaryButtonStyle())
                    }
                    .padding()
                    .background(Color.themeCardBackground)
                    .cornerRadius(16)
                }
                
                NewCustomTextField(text: $viewModel.bigText)
                
                ColorPickerView(title: "BACKGROUND COLOR", colors: backgroundColors, selection: $viewModel.selectedBackgroundColor)
                
                ColorPickerView(title: "TEXT COLOR", colors: textColors, selection: $viewModel.selectedTextColor)
                
                FontSizeSlider(fontSize: $viewModel.fontSize)
                
                TitledSection(title: "PREVIEW") {
                    Text(viewModel.bigText)
                        .font(.system(size: viewModel.fontSize, weight: .bold))
                        .foregroundColor(viewModel.selectedTextColor)
                        .frame(maxWidth: .infinity, minHeight: 150)
                        .background(viewModel.selectedBackgroundColor)
                        .cornerRadius(16)
                }
                
                Button("Show Full Screen") { isFullScreen = true }
                    .buttonStyle(PrimaryButtonStyle())
            }
            .padding()
            .padding(.bottom, 150)

        }
        .fullScreenCover(isPresented: $isFullScreen) {
            BigTextFullScreenView(
                text: viewModel.bigText,
                backgroundColor: viewModel.selectedBackgroundColor,
                textColor: viewModel.selectedTextColor,
                fontSize: viewModel.fontSize
            )
        }
    }
}


private struct NewCustomTextField: View {
    @Binding var text: String
    
    var body: some View {
        HStack {
            TextField("Enter your text", text: $text)
            if !text.isEmpty {
                Button(action: { text = "" }) {
                    Image(systemName: "xmark.circle.fill")
                        .foregroundColor(.themeSecondaryText)
                }
            }
        }
        .padding()
        .background(Color.themeCardBackground)
        .cornerRadius(12)
    }
}


private struct ColorPickerView: View {
    let title: String
    let colors: [Color]
    @Binding var selection: Color
    
    var body: some View {
        VStack(alignment: .leading) {
            Text(title).font(.caption).foregroundColor(.themeSecondaryText)
            HStack {
                ForEach(colors, id: \.self) { color in
                    Circle()
                        .fill(color)
                        .frame(width: 40, height: 40)
                        .overlay(
                            Circle()
                                .stroke(Color.themeAccentRed, lineWidth: selection == color ? 3 : 0)
                                .padding(-4)
                        )
                        .onTapGesture {
                            selection = color
                        }
                }
            }
        }
    }
}

private struct FontSizeSlider: View {
    @Binding var fontSize: CGFloat
    
    var body: some View {
        VStack(alignment: .leading) {
            HStack {
                Text("FONT SIZE").font(.caption).foregroundColor(.themeSecondaryText)
                Spacer()
                Text("\(Int(fontSize))px").font(.caption)
            }
            
            Slider(value: $fontSize, in: 24...150, step: 1)
                .tint(.blue)
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

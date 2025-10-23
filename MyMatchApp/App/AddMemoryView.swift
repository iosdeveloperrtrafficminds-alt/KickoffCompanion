import SwiftUI
import PhotosUI
import RealmSwift

struct AddMemoryView: View {
    @StateObject private var viewModel = AddMemoryViewModel()
    @Environment(\.presentationMode) var presentationMode
    
    private let photoGridColumns = [GridItem(.adaptive(minimum: 100))]
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(alignment: .leading, spacing: 24) {
                    TitledSection(title: "SELECT MATCH") {
                        MatchPicker(
                            matches: viewModel.availableMatches,
                            selection: $viewModel.selectedMatch
                        )
                    }
                    
                    TitledSection(title: "PHOTOS") {
                        PhotoGrid(
                            images: viewModel.loadedImages,
                            selectedItems: $viewModel.selectedPhotoItems
                        )
                       // .offset(x: viewModel.selectedPhotoItems.isEmpty ? -15 : 0)
                        
                        if viewModel.isUploading {
                            ProgressView()
                                .tint(.themeAccentRed)
                                .frame(maxWidth: .infinity)
                        }
                    }
                    
                    TitledSection(title: "DESCRIPTION") {
                        CustomTextEditor(
                            placeholder: "Great atmosphere at the stadium today!",
                            text: $viewModel.description
                        )
                    }
                    
                    TitledSection(title: "TAGS") {
                        CustomTextField(
                            placeholder: "victory, away game, friends",
                            icon: "tag.fill",
                            text: $viewModel.tagsString
                        )

                    }
                    
                    TitledSection(title: "LOCATION") {
                        CustomTextField(
                            placeholder: "Old Trafford",
                            icon: "mappin.and.ellipse",
                            text: $viewModel.location
                        )
                    }
                }
                .padding()
            }
            .background(Color.themeBackground.ignoresSafeArea())
            .navigationTitle("Add Memory")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { presentationMode.wrappedValue.dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Post") {
                        try? viewModel.postMemory()
                        presentationMode.wrappedValue.dismiss()
                    }
                    .disabled(!viewModel.isPostButtonEnabled)
                }
            }
        }
        .accentColor(.themeAccentRed)
    }
}


private struct TitledSection<Content: View>: View {
    let title: String
    @ViewBuilder let content: Content
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(title).font(.caption).bold().foregroundColor(.themeSecondaryText)
            content
        }
    }
}

private struct MatchPicker: View {
    let matches: Results<MatchObject>?
    @Binding var selection: MatchObject?
    
    var body: some View {
        if let matches = matches, !matches.isEmpty {
            Picker("Select Match", selection: $selection) {
                Text("Select a match...").tag(nil as MatchObject?)
                ForEach(matches) { match in
                    Text("\(match.homeTeam) vs \(match.awayTeam) (\(match.date.formatted(dateStyle: .short, timeStyle: .none)))")
                        .tag(match as MatchObject?)
                }
            }
            .padding()
            .frame(maxWidth: .infinity)
            .background(Color.themeCardBackground)
            .cornerRadius(12)
            .accentColor(.themePrimaryText)
        } else {
            Text("No matches found. Add a match first.")
                .foregroundColor(.themeSecondaryText)
                .padding()
                .frame(maxWidth: .infinity)
                .background(Color.themeCardBackground)
                .cornerRadius(12)
        }
    }
}

private struct PhotoGrid: View {
    let images: [UIImage]
    @Binding var selectedItems: [PhotosPickerItem]
    private let columns = [GridItem(.adaptive(minimum: 100))]
    
    var body: some View {
        LazyVGrid(columns: columns) {
            ForEach(images, id: \.self) { image in
                Image(uiImage: image)
                    .resizable().scaledToFill()
                    .frame(width: 100, height: 100).clipped().cornerRadius(12)
                    .overlay(CheckmarkView())
            }
            
            PhotosPicker(selection: $selectedItems, maxSelectionCount: 10, matching: .images) {
                ZStack {
                    RoundedRectangle(cornerRadius: 12).fill(Color.themeCardBackground)
                    Image(systemName: "plus")
                        .font(.title)
                        .foregroundColor(.themeSecondaryText)
                }
                .frame(width: 100, height: 100)
            }
        }
    }
}

private struct CheckmarkView: View {
    var body: some View {
        ZStack {
            Circle()
                .fill(Color.themeAccentRed)
                .frame(width: 24, height: 24)
            Image(systemName: "checkmark")
                .foregroundColor(.white)
                .font(.caption.bold())
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topTrailing)
        .padding(4)
    }
}

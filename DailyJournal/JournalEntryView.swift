//
//  JournalEntryView.swift
//  DailyJournal
//
//  Created by Elyse Q on 4/15/26.
//

import SwiftUI
import SwiftData
import PhotosUI

// MARK: - Photo Layout Configuration
// Tweak these to change how photos appear

struct PhotoLayoutStyle {
    var cornerRadius: CGFloat = 16
    var photoHeight: CGFloat = 220
    var photoSpacing: CGFloat = 12
    var shadowRadius: CGFloat = 4
    var shadowColor: Color = .black.opacity(0.15)
    var overlayOnHover: Bool = true
}

struct JournalEntryView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss

    let date: Date
    var entry: JournalEntry?

    @State private var text: String = ""
    @State private var photoDataItems: [Data] = []
    @State private var selectedPhotos: [PhotosPickerItem] = []
    @State private var isLoadingPhotos = false

    // Customize photo appearance here
    var photoStyle = PhotoLayoutStyle()

    private var dateTitle: String {
        date.formatted(.dateTime.weekday(.wide).month(.wide).day().year())
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    // Date header
                    Text(dateTitle)
                        .font(.title2.weight(.semibold))
                        .foregroundStyle(.secondary)
                        .padding(.horizontal)

                    // Text editor
                    textEditor

                    // Photo section
                    photoSection

                    // Add photos button
                    addPhotosButton
                }
                .padding(.vertical)
            }
            .scrollDismissesKeyboard(.interactively)
            .background(Color.secondary.opacity(0.1))
            .navigationTitle("Journal Entry")
            #if os(iOS)
            .navigationBarTitleDisplayMode(.inline)
            #endif
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") { saveEntry() }
                        .fontWeight(.semibold)
                }
                #if os(iOS)
                ToolbarItemGroup(placement: .keyboard) {
                    Spacer()
                    Button("Done") {
                        UIApplication.shared.sendAction(
                            #selector(UIResponder.resignFirstResponder),
                            to: nil, from: nil, for: nil
                        )
                    }
                }
                #endif
            }
            .onAppear { loadExistingEntry() }
            .onChange(of: selectedPhotos) { _, newItems in
                Task { await loadPhotos(from: newItems) }
            }
        }
    }

    // MARK: - Text Editor

    private var textEditor: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("How was your day?")
                .font(.headline)
                .padding(.horizontal)

            TextEditor(text: $text)
                .frame(minHeight: 180)
                .scrollContentBackground(.hidden)
                .padding(12)
                .background(
                    RoundedRectangle(cornerRadius: 14)
                        .fill(.background)
                        .shadow(color: .black.opacity(0.06), radius: 2, y: 1)
                )
                .padding(.horizontal)
        }
    }

    // MARK: - Photo Grid

    private var photoSection: some View {
        Group {
            if !photoDataItems.isEmpty {
                VStack(alignment: .leading, spacing: 10) {
                    Text("Photos")
                        .font(.headline)
                        .padding(.horizontal)

                    // Staggered/masonry-ish layout for aesthetic presentation
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: photoStyle.photoSpacing) {
                            ForEach(photoDataItems.indices, id: \.self) { index in
                                photoCard(data: photoDataItems[index], index: index)
                            }
                        }
                        .padding(.horizontal)
                    }
                }
            }
        }
    }

    private func photoCard(data: Data, index: Int) -> some View {
        Group {
            if let image = platformImage(from: data) {
                image
                    .resizable()
                    .scaledToFill()
                    .frame(width: photoStyle.photoHeight * 0.8, height: photoStyle.photoHeight)
                    .clipShape(RoundedRectangle(cornerRadius: photoStyle.cornerRadius))
                    .shadow(color: photoStyle.shadowColor, radius: photoStyle.shadowRadius, y: 2)
                    .overlay(alignment: .topTrailing) {
                        Button {
                            withAnimation(.easeOut(duration: 0.25)) {
                                let _ = photoDataItems.remove(at: index)
                            }
                        } label: {
                            Image(systemName: "xmark.circle.fill")
                                .font(.title3)
                                .symbolRenderingMode(.palette)
                                .foregroundStyle(.white, .black.opacity(0.5))
                                .padding(8)
                        }
                    }
            }
        }
    }

    private func platformImage(from data: Data) -> Image? {
        #if canImport(UIKit)
        guard let uiImage = UIImage(data: data) else { return nil }
        return Image(uiImage: uiImage)
        #elseif canImport(AppKit)
        guard let nsImage = NSImage(data: data) else { return nil }
        return Image(nsImage: nsImage)
        #endif
    }

    // MARK: - Add Photos Button

    private var addPhotosButton: some View {
        PhotosPicker(
            selection: $selectedPhotos,
            maxSelectionCount: 10,
            matching: .images
        ) {
            Label("Add Photos", systemImage: "photo.on.rectangle.angled")
                .font(.body.weight(.medium))
                .frame(maxWidth: .infinity)
                .padding(.vertical, 14)
                .background(
                    RoundedRectangle(cornerRadius: 14)
                        .fill(.background)
                        .shadow(color: .black.opacity(0.06), radius: 2, y: 1)
                )
        }
        .padding(.horizontal)
        .disabled(isLoadingPhotos)
        .overlay {
            if isLoadingPhotos {
                ProgressView()
            }
        }
    }

    // MARK: - Data Operations

    private func loadExistingEntry() {
        if let entry {
            text = entry.text
            photoDataItems = entry.photoData
        }
    }

    private func loadPhotos(from items: [PhotosPickerItem]) async {
        isLoadingPhotos = true
        for item in items {
            if let data = try? await item.loadTransferable(type: Data.self) {
                photoDataItems.append(data)
            }
        }
        selectedPhotos.removeAll()
        isLoadingPhotos = false
    }

    private func saveEntry() {
        if let entry {
            entry.text = text
            entry.photoData = photoDataItems
        } else {
            let newEntry = JournalEntry(date: date, text: text, photoData: photoDataItems)
            modelContext.insert(newEntry)
        }
        dismiss()
    }
}

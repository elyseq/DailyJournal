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

    @State private var entryDate: Date = Date()
    @State private var text: String = ""
    @State private var photoDataItems: [Data] = []
    @State private var selectedPhotos: [PhotosPickerItem] = []
    @State private var isLoadingPhotos = false
    @State private var photoIndexToRemove: Int?
    @State private var showingDatePicker = false
    @State private var expandedPhotoData: Data?

    // Customize photo appearance here
    var photoStyle = PhotoLayoutStyle()

    private var dateTitle: String {
        entryDate.formatted(.dateTime.weekday(.wide).month(.wide).day().year())
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    // Date header with change-date button
                    HStack {
                        Text(dateTitle)
                            .font(.system(size: 18, weight: .medium, design: .serif))
                            .foregroundStyle(.secondary)

                        Spacer()

                        Button {
                            showingDatePicker = true
                        } label: {
                            Image(systemName: "calendar.badge.clock")
                                .font(.body)
                                .foregroundStyle(.purple)
                        }
                    }
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
            .onAppear {
                entryDate = date
                loadExistingEntry()
            }
            .onChange(of: selectedPhotos) { _, newItems in
                Task { await loadPhotos(from: newItems) }
            }
            .alert("Remove Photo", isPresented: Binding(
                get: { photoIndexToRemove != nil },
                set: { if !$0 { photoIndexToRemove = nil } }
            )) {
                Button("Remove", role: .destructive) {
                    if let index = photoIndexToRemove, index < photoDataItems.count {
                        withAnimation(.easeOut(duration: 0.25)) {
                            let _ = photoDataItems.remove(at: index)
                        }
                    }
                    photoIndexToRemove = nil
                }
                Button("Cancel", role: .cancel) {
                    photoIndexToRemove = nil
                }
            } message: {
                Text("Are you sure you want to remove this photo?")
            }
            .sheet(isPresented: $showingDatePicker) {
                NavigationStack {
                    DatePicker(
                        "Move entry to",
                        selection: $entryDate,
                        displayedComponents: .date
                    )
                    .datePickerStyle(.graphical)
                    .padding()
                    .navigationTitle("Change Date")
                    #if os(iOS)
                    .navigationBarTitleDisplayMode(.inline)
                    #endif
                    .toolbar {
                        ToolbarItem(placement: .confirmationAction) {
                            Button("Done") {
                                showingDatePicker = false
                            }
                        }
                    }
                }
                .presentationDetents([.medium])
            }
        }
        .photoZoomOverlay(photoData: $expandedPhotoData, platformImage: platformImage)
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
                VStack(alignment: .leading, spacing: 16) {
                    Text("Photos")
                        .font(.headline)
                        .padding(.horizontal)

                    let pairs = Array(photoDataItems.indices).chunked(into: 2)
                    VStack(spacing: 16) {
                        ForEach(pairs.indices, id: \.self) { rowIndex in
                            HStack(spacing: 12) {
                                ForEach(pairs[rowIndex], id: \.self) { index in
                                    polaroidCard(data: photoDataItems[index], index: index)
                                }
                                if pairs[rowIndex].count == 1 {
                                    Spacer().frame(maxWidth: .infinity)
                                }
                            }
                        }
                    }
                    .padding(.horizontal)
                }
            }
        }
    }

    private func polaroidCard(data: Data, index: Int) -> some View {
        Group {
            if let image = platformImage(from: data) {
                VStack(spacing: 0) {
                    GeometryReader { geo in
                        image
                            .resizable()
                            .scaledToFill()
                            .frame(width: geo.size.width, height: geo.size.height)
                            .clipped()
                    }
                    .frame(height: 180)
                    .padding(8)
                    .contentShape(Rectangle())
                    .onTapGesture {
                        expandedPhotoData = data
                    }

                    // Polaroid bottom strip
                    HStack {
                        Text(dateTitle)
                            .font(.system(size: 10, weight: .regular, design: .serif))
                            .foregroundStyle(.secondary)
                            .lineLimit(1)

                        Spacer()

                        Button {
                            photoIndexToRemove = index
                        } label: {
                            Image(systemName: "xmark.circle.fill")
                                .font(.caption)
                                .symbolRenderingMode(.palette)
                                .foregroundStyle(.gray, .gray.opacity(0.2))
                        }
                    }
                    .padding(.horizontal, 10)
                    .padding(.bottom, 10)
                }
                .background(Color.white)
                .clipShape(RoundedRectangle(cornerRadius: 4))
                .shadow(color: .black.opacity(0.12), radius: 6, y: 3)
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
            entry.date = entryDate
            entry.text = text
            entry.photoData = photoDataItems
        } else {
            let newEntry = JournalEntry(date: entryDate, text: text, photoData: photoDataItems)
            modelContext.insert(newEntry)
        }
        try? modelContext.save()
        dismiss()
    }
}

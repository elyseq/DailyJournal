//
//  JournalReadView.swift
//  DailyJournal
//
//  Created by Elyse Q on 4/16/26.
//

import SwiftUI
import SwiftData

struct JournalReadView: View {
    @Environment(\.dismiss) private var dismiss

    let entry: JournalEntry
    @State private var isEditing = false

    var photoStyle = PhotoLayoutStyle()

    private var dateTitle: String {
        entry.date.formatted(.dateTime.weekday(.wide).month(.wide).day().year())
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 24) {
                    // Date header
                    Text(dateTitle)
                        .font(.title2.weight(.semibold))
                        .foregroundStyle(.secondary)
                        .padding(.horizontal)

                    // Journal text
                    if !entry.text.isEmpty {
                        Text(entry.text)
                            .font(.body)
                            .lineSpacing(6)
                            .padding(.horizontal)
                    } else {
                        Text("No text for this entry.")
                            .font(.body)
                            .foregroundStyle(.tertiary)
                            .padding(.horizontal)
                    }

                    // Photos
                    if !entry.photoData.isEmpty {
                        photoGallery
                    }
                }
                .padding(.vertical)
            }
            .background(Color.secondary.opacity(0.1))
            .navigationTitle("Journal Entry")
            #if os(iOS)
            .navigationBarTitleDisplayMode(.inline)
            #endif
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Done") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button {
                        isEditing = true
                    } label: {
                        Label("Edit", systemImage: "pencil")
                    }
                }
            }
            .sheet(isPresented: $isEditing) {
                JournalEntryView(
                    date: entry.date,
                    entry: entry
                )
            }
        }
    }

    // MARK: - Photo Gallery

    private var photoGallery: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Photos")
                .font(.headline)
                .padding(.horizontal)

            let pairs = Array(entry.photoData.indices).chunked(into: 2)
            VStack(spacing: 16) {
                ForEach(pairs.indices, id: \.self) { rowIndex in
                    HStack(spacing: 12) {
                        ForEach(pairs[rowIndex], id: \.self) { index in
                            readOnlyPolaroid(data: entry.photoData[index])
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

    private func readOnlyPolaroid(data: Data) -> some View {
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

                    // Polaroid bottom strip
                    HStack {
                        Text(dateTitle)
                            .font(.system(size: 10, weight: .regular, design: .serif))
                            .foregroundStyle(.secondary)
                            .lineLimit(1)
                        Spacer()
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
}

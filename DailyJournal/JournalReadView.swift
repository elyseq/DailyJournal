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
        VStack(alignment: .leading, spacing: 12) {
            Text("Photos")
                .font(.headline)
                .padding(.horizontal)

            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: photoStyle.photoSpacing) {
                    ForEach(entry.photoData.indices, id: \.self) { index in
                        readOnlyPhoto(data: entry.photoData[index])
                    }
                }
                .padding(.horizontal)
            }
        }
    }

    private func readOnlyPhoto(data: Data) -> some View {
        Group {
            if let image = platformImage(from: data) {
                image
                    .resizable()
                    .scaledToFill()
                    .frame(width: photoStyle.photoHeight * 0.8, height: photoStyle.photoHeight)
                    .clipShape(RoundedRectangle(cornerRadius: photoStyle.cornerRadius))
                    .shadow(color: photoStyle.shadowColor, radius: photoStyle.shadowRadius, y: 2)
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

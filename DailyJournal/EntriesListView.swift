//
//  EntriesListView.swift
//  DailyJournal
//
//  Created by Elyse Q on 4/15/26.
//

import SwiftUI
import SwiftData

struct EntriesListView: View {
    @Query(sort: \JournalEntry.date, order: .reverse) private var entries: [JournalEntry]
    @State private var selectedDay: SelectedDay?

    var body: some View {
        NavigationStack {
            Group {
                if entries.isEmpty {
                    ContentUnavailableView(
                        "No Entries Yet",
                        systemImage: "book.closed",
                        description: Text("Tap a day on the calendar to write your first entry.")
                    )
                } else {
                    ScrollView {
                        LazyVStack(spacing: 16) {
                            ForEach(entries) { entry in
                                entryCard(for: entry)
                            }
                        }
                        .padding()
                    }
                }
            }
            .navigationTitle("All Entries")
            .sheet(item: $selectedDay) { day in
                JournalEntryView(
                    date: day.date,
                    entry: entries.first { Calendar.current.isDate($0.date, inSameDayAs: day.date) }
                )
            }
        }
    }

    private func entryCard(for entry: JournalEntry) -> some View {
        Button {
            selectedDay = SelectedDay(date: entry.date)
        } label: {
            VStack(alignment: .leading, spacing: 12) {
                // Date header
                Text(entry.date.formatted(.dateTime.weekday(.wide).month(.wide).day().year()))
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(.secondary)

                // Text preview
                if !entry.text.isEmpty {
                    Text(entry.text)
                        .font(.body)
                        .foregroundStyle(.primary)
                        .lineLimit(3)
                        .multilineTextAlignment(.leading)
                }

                // Photo thumbnails
                if !entry.photoData.isEmpty {
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 8) {
                            ForEach(entry.photoData.indices, id: \.self) { index in
                                thumbnailImage(from: entry.photoData[index])
                            }
                        }
                    }
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding()
            .background(
                RoundedRectangle(cornerRadius: 14)
                    .fill(.background)
                    .shadow(color: .black.opacity(0.08), radius: 4, y: 2)
            )
        }
        .buttonStyle(.plain)
    }

    private func thumbnailImage(from data: Data) -> some View {
        Group {
            if let image = platformImage(from: data) {
                image
                    .resizable()
                    .scaledToFill()
                    .frame(width: 60, height: 60)
                    .clipShape(RoundedRectangle(cornerRadius: 8))
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

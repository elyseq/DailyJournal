//
//  ContentView.swift
//  DailyJournal
//
//  Created by Elyse Q on 4/15/26.
//

import SwiftUI
import SwiftData

struct ContentView: View {
    var body: some View {
        TabView {
            CalendarView()
                .tabItem {
                    Label("Calendar", systemImage: "calendar")
                }

            EntriesListView()
                .tabItem {
                    Label("Entries", systemImage: "book")
                }
        }
    }
}

#Preview {
    ContentView()
        .modelContainer(for: JournalEntry.self, inMemory: true)
}

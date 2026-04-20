//
//  ContentView.swift
//  DailyJournal
//
//  Created by Elyse Q on 4/15/26.
//

import SwiftUI
import SwiftData

struct ContentView: View {
    // TODO: Re-enable when CloudKit is configured
    // @Query private var profiles: [UserProfile]
    // @State private var hasCompletedSetup = false
    //
    // private var needsSetup: Bool {
    //     profiles.isEmpty && !hasCompletedSetup
    // }

    var body: some View {
        // TODO: Re-enable profile setup gate when CloudKit is configured
        // if needsSetup {
        //     ProfileSetupView {
        //         hasCompletedSetup = true
        //     }
        // } else {
        TabView {
            CalendarView()
                .tabItem {
                    Label("Calendar", systemImage: "calendar")
                }

            EntriesListView()
                .tabItem {
                    Label("Entries", systemImage: "book")
                }

            // TODO: Re-enable when CloudKit is configured
            // FriendsView()
            //     .tabItem {
            //         Label("Friends", systemImage: "person.2")
            //     }
        }
        // }
    }
}

#Preview {
    ContentView()
        .modelContainer(for: [JournalEntry.self], inMemory: true)
}

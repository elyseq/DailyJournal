//
//  DailyJournalApp.swift
//  DailyJournal
//
//  Created by Elyse Q on 4/15/26.
//

import SwiftUI
import SwiftData

@main
struct DailyJournalApp: App {
    var sharedModelContainer: ModelContainer = {
        let schema = Schema([
            JournalEntry.self,
            // TODO: Re-enable when CloudKit is configured
            // UserProfile.self,
            // Friend.self,
        ])
        let modelConfiguration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: false)

        do {
            return try ModelContainer(for: schema, configurations: [modelConfiguration])
        } catch {
            fatalError("Could not create ModelContainer: \(error)")
        }
    }()

    var body: some Scene {
        WindowGroup {
            ContentView()
            // TODO: Re-enable when CloudKit is configured
            // .onOpenURL { url in
            //     handleIncomingURL(url)
            // }
        }
        .modelContainer(sharedModelContainer)
    }

    // TODO: Re-enable when CloudKit is configured
    // @State private var pendingFriendUsername: String?
    // @State private var pendingFriendCode: String?
    //
    // private func handleIncomingURL(_ url: URL) {
    //     guard url.scheme == "dailyjournal",
    //           url.host == "add-friend",
    //           let components = URLComponents(url: url, resolvingAgainstBaseURL: false),
    //           let queryItems = components.queryItems
    //     else { return }
    //
    //     let username = queryItems.first(where: { $0.name == "username" })?.value
    //     let code = queryItems.first(where: { $0.name == "code" })?.value
    //
    //     guard let username, let code else { return }
    //
    //     let context = sharedModelContainer.mainContext
    //     let friend = Friend(username: username, friendCode: code)
    //     context.insert(friend)
    //     try? context.save()
    // }
}

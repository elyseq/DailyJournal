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
            UserProfile.self,
            Friend.self,
        ])
        let modelConfiguration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: false)

        do {
            return try ModelContainer(
                for: schema,
                configurations: [modelConfiguration]
            )
        } catch {
            // Migration failed — back up old database and start fresh
            print("Migration failed: \(error). Backing up old store and creating new one.")
            let appSupport = FileManager.default.urls(for: .applicationSupportDirectory, in: .userDomainMask).first!
            let storeURL = appSupport.appendingPathComponent("default.store")
            for ext in ["", "-shm", "-wal"] {
                let fileURL = storeURL.appendingPathExtension(ext.isEmpty ? "" : String(ext.dropFirst()))
                let backupURL = fileURL.appendingPathExtension("backup")
                let url = ext.isEmpty ? storeURL : URL(fileURLWithPath: storeURL.path + ext)
                let backup = URL(fileURLWithPath: url.path + ".backup")
                try? FileManager.default.moveItem(at: url, to: backup)
            }
            do {
                return try ModelContainer(for: schema, configurations: [modelConfiguration])
            } catch {
                fatalError("Could not create ModelContainer after reset: \(error)")
            }
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

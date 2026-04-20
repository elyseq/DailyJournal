//
//  Item.swift
//  DailyJournal
//
//  Created by Elyse Q on 4/15/26.
//

import Foundation
import SwiftData

@Model
final class JournalEntry {
    var date: Date
    var text: String
    var photoData: [Data]

    init(date: Date, text: String = "", photoData: [Data] = []) {
        self.date = date
        self.text = text
        self.photoData = photoData
    }
}

// TODO: Re-enable when CloudKit is configured
//
// @Model
// final class UserProfile {
//     @Attribute(.unique) var username: String
//     var friendCode: String
//     var createdAt: Date
//
//     init(username: String) {
//         self.username = username
//         self.friendCode = UUID().uuidString.prefix(8).lowercased() + String(Int.random(in: 100...999))
//         self.createdAt = Date()
//     }
// }
//
// @Model
// final class Friend {
//     @Attribute(.unique) var username: String
//     var friendCode: String
//     var addedAt: Date
//
//     init(username: String, friendCode: String) {
//         self.username = username
//         self.friendCode = friendCode
//         self.addedAt = Date()
//     }
// }

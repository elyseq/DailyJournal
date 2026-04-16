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

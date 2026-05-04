//
//  Item.swift
//  DailyJournal
//
//  Created by Elyse Q on 4/15/26.
//

import Foundation
import SwiftData
#if canImport(UIKit)
import UIKit
#elseif canImport(AppKit)
import AppKit
#endif

// MARK: - Current Model

@Model
final class JournalEntry {
    var date: Date
    var text: String
    var photoData: [Data]
    var thumbnailData: [Data]

    init(date: Date, text: String = "", photoData: [Data] = [], thumbnailData: [Data] = []) {
        self.date = date
        self.text = text
        self.photoData = photoData
        self.thumbnailData = thumbnailData
    }

    static func generateThumbnail(from data: Data, maxDimension: CGFloat = 400) -> Data? {
        #if canImport(UIKit)
        guard let image = UIImage(data: data) else { return nil }
        let scale = min(maxDimension / image.size.width, maxDimension / image.size.height, 1.0)
        let newSize = CGSize(width: image.size.width * scale, height: image.size.height * scale)
        let renderer = UIGraphicsImageRenderer(size: newSize)
        let thumbnailImage = renderer.image { _ in
            image.draw(in: CGRect(origin: .zero, size: newSize))
        }
        return thumbnailImage.jpegData(compressionQuality: 0.7)
        #elseif canImport(AppKit)
        guard let image = NSImage(data: data) else { return nil }
        let scale = min(maxDimension / image.size.width, maxDimension / image.size.height, 1.0)
        let newSize = CGSize(width: image.size.width * scale, height: image.size.height * scale)
        let newImage = NSImage(size: newSize)
        newImage.lockFocus()
        image.draw(in: CGRect(origin: .zero, size: newSize))
        newImage.unlockFocus()
        guard let tiffData = newImage.tiffRepresentation,
              let rep = NSBitmapImageRep(data: tiffData) else { return nil }
        return rep.representation(using: .jpeg, properties: [.compressionFactor: 0.7])
        #endif
    }
}

// Models kept in schema so SwiftData can open the existing database.
// UI is disabled until CloudKit is configured.

@Model
final class UserProfile {
    @Attribute(.unique) var username: String
    var friendCode: String
    var createdAt: Date

    init(username: String) {
        self.username = username
        self.friendCode = UUID().uuidString.prefix(8).lowercased() + String(Int.random(in: 100...999))
        self.createdAt = Date()
    }
}

@Model
final class Friend {
    @Attribute(.unique) var username: String
    var friendCode: String
    var addedAt: Date

    init(username: String, friendCode: String) {
        self.username = username
        self.friendCode = friendCode
        self.addedAt = Date()
    }
}

//
//  PhotoZoomView.swift
//  DailyJournal
//
//  Created by Elyse Q on 4/19/26.
//

import SwiftUI

struct ExpandedPhoto: Identifiable, Equatable {
    let id = UUID()
    let data: Data

    static func == (lhs: ExpandedPhoto, rhs: ExpandedPhoto) -> Bool {
        lhs.id == rhs.id
    }
}

struct PhotoZoomOverlay: ViewModifier {
    @Binding var photoData: Data?
    let platformImage: (Data) -> Image?

    func body(content: Content) -> some View {
        content
            .overlay {
                if let data = photoData {
                    ZStack {
                        // Dimmed background — tap to dismiss
                        Color.black.opacity(0.6)
                            .ignoresSafeArea()
                            .onTapGesture {
                                withAnimation(.easeOut(duration: 0.2)) {
                                    photoData = nil
                                }
                            }

                        if let image = platformImage(data) {
                            image
                                .resizable()
                                .scaledToFit()
                                .clipShape(RoundedRectangle(cornerRadius: 8))
                                .shadow(color: .black.opacity(0.4), radius: 20, y: 10)
                                .padding(24)
                        }

                        // Close button
                        VStack {
                            HStack {
                                Spacer()
                                Button {
                                    withAnimation(.easeOut(duration: 0.2)) {
                                        photoData = nil
                                    }
                                } label: {
                                    Image(systemName: "xmark.circle.fill")
                                        .font(.title2)
                                        .symbolRenderingMode(.palette)
                                        .foregroundStyle(.white, .white.opacity(0.35))
                                        .padding()
                                }
                            }
                            Spacer()
                        }
                    }
                    .transition(.opacity)
                }
            }
            .animation(.easeInOut(duration: 0.2), value: photoData != nil)
    }
}

extension View {
    func photoZoomOverlay(photoData: Binding<Data?>, platformImage: @escaping (Data) -> Image?) -> some View {
        modifier(PhotoZoomOverlay(photoData: photoData, platformImage: platformImage))
    }
}

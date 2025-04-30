//
//  StatusTextRowView.swift
//  The Feed
//
//  Created by Dylan Gattey on 4/30/25.
//
import SwiftUI

/**
 Shows status text + optional symbols in a GridRow for the book, no sizing applied to the font yet.
 */
struct StatusTextRowView: View {
    let book: Book
    
    var body: some View {
        GridRow {
            if let readDateFinished = book.readDateFinished {
                HStack(alignment: .center, spacing: 4) {
                    Image(systemName: "checkmark.seal.fill")
                        .symbolRenderingMode(.palette)
                        .foregroundStyle(Color.accentForeground, Color.blue)
                        .imageScale(.large)
                    Text("Finished on \(readDateFinished.formatted(date: .abbreviated, time: .omitted))")
                }.frame(maxWidth: .infinity, alignment: .leading)
            } else if let readDateStarted = book.readDateStarted {
                Text("Started reading on \(readDateStarted.formatted(date: .abbreviated, time: .omitted))")
            } else if let createdAt = book.sysContent.createdAt {
                Text("Created on \(createdAt.formatted(date: .abbreviated, time: .omitted))")
            }
        }
    }
}

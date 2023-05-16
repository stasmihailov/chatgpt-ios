//
//  Buttons.swift
//  ChatGPTApp
//
//  Created by Denis Babochenko on 19/04/2023.
//

import SwiftUI

final class AppButtons {
    static func search() -> some View {
        Image(systemName: "magnifyingglass")
            .foregroundColor(AppColors.accent)
    }
    
    static func newChat() -> some View {
        NewChatButton()
    }
    
    static func chatSettings(_ action: @escaping () -> Void) -> some View {
        Button(action: action) {
            Image(systemName: "slider.horizontal.3")
                .foregroundColor(AppColors.accent)
                .padding(.leading, 8)
                .padding(.trailing, 12)
                .padding(.bottom, 12)
        }
    }
    
    static func destructive(label: String, _ action: @escaping () -> Void) -> some View {
        Button(action: action) {
            Text(label)
                .foregroundColor(AppColors.accentDestructive)
        }
    }
    
    static func action(label: String, _ action: @escaping () -> Void) -> some View {
        Button(action: action) {
            Text(label)
                .foregroundColor(AppColors.accent)
        }
    }
}

fileprivate struct NewChatButton: View {
    @EnvironmentObject var persistence: Persistence
    
    @State private var newChat: EChat? = nil
    @State private var isActive = false

    var body: some View {
        Button(action: {
            newChat = EChat.new()
            persistence.add(chat: newChat!)
            isActive = true
        }, label: {
            Image(systemName: "square.and.pencil")
                .foregroundColor(AppColors.accent)
                .padding(6)
        })
        .background(
            NewChatNavigationLink(newChat: newChat, isActive: $isActive)
        )
    }
}

fileprivate struct NewChatNavigationLink: View {
    var newChat: EChat?
    @Binding var isActive: Bool

    var body: some View {
        NavigationLink(
            destination: newChatX(),
            isActive: $isActive) {
                EmptyView()
            }
    }
    
    func newChatX() -> some View {
        guard let newChat = newChat else {
            return EmptyView()
        }
        
        return Chat(thread: newChat)
    }
}

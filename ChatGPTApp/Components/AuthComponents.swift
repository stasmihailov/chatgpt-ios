//
//  AuthComponents.swift
//  ChatGPTApp
//
//  Created by Denis Babochenko on 11/05/2023.
//

import SwiftUI
import GoogleSignIn

class GoogleAuth {
    private let user = GIDSignIn.sharedInstance.currentUser

    static func signInButton() -> any View {
        GoogleSignInButton()
    }
    
    static func username() -> any View {
        let user = GIDSignIn.sharedInstance.currentUser
        
        return Text(user?.profile?.name ?? "---")
    }
}

fileprivate struct GoogleSignInButton: View {
    @EnvironmentObject var auth: AppAuthentication

    var body: some View {
        Btn()
            .padding()
            .onTapGesture {
                auth.signIn()
            }
    }
    
    struct Btn: UIViewRepresentable {
        @Environment(\.colorScheme) var colorScheme
        
        private var button = GIDSignInButton()
        
        func makeUIView(context: Context) -> GIDSignInButton {
            button.colorScheme = colorScheme == .dark ? .dark : .light
            return button
        }
        
        func updateUIView(_ uiView: UIViewType, context: Context) {
            button.colorScheme = colorScheme == .dark ? .dark : .light
        }
    }
}

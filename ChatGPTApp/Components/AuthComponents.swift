//
//  AuthComponents.swift
//  ChatGPTApp
//
//  Created by Denis Babochenko on 11/05/2023.
//

import SwiftUI
import GoogleSignIn

struct AuthPanel: View {
    @EnvironmentObject var auth: AppAuthentication
    
    var body: some View {
        HStack {
            Text("Sign in to store your chats")
            Spacer()
            GoogleSignInButton()
        }
        .padding(.top, 20)
        .padding(.bottom, 20)
    }
}

fileprivate struct GoogleSignInButton: View {
    @EnvironmentObject var auth: AppAuthentication

    var body: some View {
        Btn()
            .frame(width: 120, height: 20)
            .onTapGesture {
                auth.signIn()
            }
    }
    
    struct Btn: UIViewRepresentable {
        @Environment(\.colorScheme) var colorScheme
        
        private var button = GIDSignInButton()
        
        func makeUIView(context: Context) -> UIView {
            button.colorScheme = colorScheme == .dark ? .dark : .light

            let view = UIStackView()
            view.axis = .horizontal
            view.alignment = .center
            view.addArrangedSubview(button)

            let wrapper = UIView()
            wrapper.addSubview(view)
            
            view.translatesAutoresizingMaskIntoConstraints = false
            NSLayoutConstraint.activate([
                view.centerXAnchor.constraint(equalTo: wrapper.centerXAnchor),
                view.centerYAnchor.constraint(equalTo: wrapper.centerYAnchor),
                view.leadingAnchor.constraint(greaterThanOrEqualTo: wrapper.leadingAnchor),
                view.trailingAnchor.constraint(lessThanOrEqualTo: wrapper.trailingAnchor)
            ])
            
            return wrapper
        }
        
        func updateUIView(_ uiView: UIViewType, context: Context) {
            if let button = uiView.subviews.first as? GIDSignInButton {
                button.colorScheme = colorScheme == .dark ? .dark : .light
            }
        }
    }
}

struct AuthComponents_Previews: PreviewProvider {
    static var previews: some View {
        VStack {
            Spacer()
            HStack {
                GoogleSignInButton()
            }
            .padding()
            .background(Color.blue)
            Spacer()
        }.background(Color.white)
        .environmentObject(AppAuthentication())
    }
}

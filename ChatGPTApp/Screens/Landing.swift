//
//  Landing.swift
//  ChatGPTApp
//
//  Created by Denis Babochenko on 18/04/2023.
//

import SwiftUI

struct LandingActionButton: View {
    var active: Bool
    
    var body: some View {
        let actionButton = Button("Get Started") {
        }
        .buttonBorderShape(.roundedRectangle)
        
        if !active {
            actionButton.buttonStyle(.bordered)
        } else {
            actionButton.buttonStyle(.borderedProminent)
        }
    }
}

struct Landing: View {
    @State var apiKey: String
    @State var isKeyCorrect: Bool
    
    var body: some View {
        VStack(spacing: 20) {
            Image("landing-logo")
                .padding(.bottom, 30)
                .padding(.top, 50)
            Text("You’ve been invited to an alpha version of this app. You can use ChatGPT in any language. More features coming soon")
                .font(.body)
                .multilineTextAlignment(.center)
            VStack {
                Text("To start, you need to provide an OpenAI API key - you can find your keys here:")
                    .font(.body)
                    .multilineTextAlignment(.center)
                Link("https://platform.openai.com/account/api-keys",
                     destination: URL(string: "https://platform.openai.com/account/api-keys")!)
            }
            VStack(spacing: 12) {
                ClearableText(placeholder: "Your API key", text: $apiKey, secure: true)
                    .showUnderline()
                if !isKeyCorrect {
                    Text("The key you entered is not working. Please double-check that you have entered the correct key and try again.")
                        .font(.caption)
                        .multilineTextAlignment(.center)
                        .foregroundColor(AppColors.accentDestructive)
                }
            }

            Text("Your key is securely stored in the Apple Keychain and only leaves your device during OpenAI API calls")
                .font(.caption)
                .multilineTextAlignment(.center)
            LandingActionButton(active: !apiKey.isEmpty && isKeyCorrect)
                .padding(16)
            Spacer()
        }.padding()
    }
}

struct Landing_Previews: PreviewProvider {
    static var previews: some View {
        Landing(apiKey: "", isKeyCorrect: false)
    }
}

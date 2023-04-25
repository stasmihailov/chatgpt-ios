//
//  Landing.swift
//  ChatGPTApp
//
//  Created by Denis Babochenko on 18/04/2023.
//

import SwiftUI

struct LandingActionButton: View {
    var active: Bool
    var action: () -> Void
    
    var body: some View {
        let btnAction = active ? action : {}
        
        let actionButton = Button("Get Started") {
            btnAction()
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
    @Binding var apiKey: String
    @State var isKeyCorrect: Bool = true
    let onGetStarted: () -> Void
    
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
            
            let action = isKeyCorrect ? onGetStarted : {}
            
            LandingActionButton(active: !apiKey.isEmpty && isKeyCorrect) {
                action()
            }
            .padding(16)
            Spacer()
        }.padding()
    }
}

struct Landing_Previews: PreviewProvider {
    struct LandingWrapper: View {
        @State var apiKey: String = ""
        @State private var showAlert = false
        
        var body: some View {
            Landing(apiKey: $apiKey,
                    isKeyCorrect: true) {
                showAlert = true
            }
            .alert(isPresented: $showAlert) {
                Alert(title: Text("Get Started!"),
                      message: Text("The key is correct!"),
                      dismissButton: .default(Text("OK")) {
                    showAlert = false
                })
            }
        }
    }
    
    static var previews: some View {
        LandingWrapper()
    }
}

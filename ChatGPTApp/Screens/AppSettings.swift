//
//  AppSettings.swift
//  ChatGPTApp
//
//  Created by Denis Babochenko on 18/04/2023.
//

import SwiftUI

struct AppSettings: View {
    @EnvironmentObject var keychain: KeychainManagerWrapper
    @EnvironmentObject var auth: AppAuthentication
    
    @State var apiKey: String
    
    private func onSaveSettings() {
        let result = keychain.saveApiToken(apiKey)
        switch result {
        case .ok:
            apiKey = ""
            break
        case .error(let err):
            // panic mode
            break
        }
    }
    
    private func onTokenReset() {
        keychain.deleteApiToken()
    }
    
    var body: some View {
        var settings = VStack {
            if auth.user == nil {
                AuthPanel()
            }
            
            ClearableText($apiKey,
                placeholder: "Enter new API key",
                secure: true
            )

            Text("Your key is securely stored in the Apple Keychain and leaves your device only during OpenAI API calls")
                .multilineTextAlignment(.center)
                .frame(maxWidth: .infinity)
                .font(Font.footnote)
            
            Button("Reset API Token") {
                onTokenReset()
            }
            
            Spacer()
        }
        .padding()
        .background(AppColors.bg)
        .dismissKeyboardOnTap()
        
        NavigationView {
            settings
            .navigationBarTitle(
                auth.user != nil ? "Hello, " + auth.user!.profile!.givenName! : "",
                displayMode: auth.user != nil ? .large : .inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button(action: onSaveSettings, label: {
                        Text("Done")
                            .bold()
                    })
                }

                if auth.user != nil {
                    ToolbarItem(placement: .navigationBarTrailing) {
                        AppButtons.destructive(label: "Sign out") {
                            auth.signOut()
                        }
                    }
                }
            }
        }
    }
}

struct AppSettings_Previews: PreviewProvider {
    static var previews: some View {
        AppSettings(apiKey: "")
    }
}

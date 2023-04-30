//
//  AppSettings.swift
//  ChatGPTApp
//
//  Created by Denis Babochenko on 18/04/2023.
//

import SwiftUI

struct AppSettings: View {
    @State var apiKey: String;
    @EnvironmentObject var keychain: KeychainManagerWrapper
    
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
            
        
        NavigationView {
            settings
            .padding()
            .background(AppColors.bg)
            .navigationBarTitle("Settings", displayMode: .inline)
            .navigationBarItems(
                trailing: Button("Done") {
                    onSaveSettings()
                })
        }
    }
}

struct AppSettings_Previews: PreviewProvider {
    static var previews: some View {
        AppSettings(apiKey: "")
    }
}

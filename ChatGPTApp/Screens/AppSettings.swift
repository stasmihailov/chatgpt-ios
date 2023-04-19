//
//  AppSettings.swift
//  ChatGPTApp
//
//  Created by Denis Babochenko on 18/04/2023.
//

import SwiftUI

struct AppSettings: View {
    @State var apiKey: String;
    
    var body: some View {
        var settings = VStack {
            ClearableText(
                placeholder: "Enter new API key",
                text: $apiKey
            )

            Text("Your key is securely stored in the Apple Keychain and leaves your device only during OpenAI API calls")
                .multilineTextAlignment(.center)
                .frame(maxWidth: .infinity)
                .font(Font.footnote)
            
            Spacer()
        }
            
        
        NavigationView {
            settings
            .padding()
            .background(AppColors.bg)
            .frame(width: .infinity, height: .infinity)
            .navigationBarTitle("Settings", displayMode: .inline)
            .navigationBarItems(
                trailing: Text("Done")
                    .foregroundColor(AppColors.accent))
        }
    }
}

struct AppSettings_Previews: PreviewProvider {
    static var previews: some View {
        AppSettings(apiKey: "")
    }
}

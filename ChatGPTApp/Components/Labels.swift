//
//  Labels.swift
//  ChatGPTApp
//
//  Created by Denis Babochenko on 06/05/2023.
//

import SwiftUI

struct OfflineModeLabel: View {
    var body: some View {
        HStack {
            Spacer()
            
            HStack {
                Group {
                    Text("Offline mode")
                    Image(systemName: "wifi.slash")
                }.font(.caption)
            }.padding(.top, 4)
            .padding(.bottom, 4)
            .padding(.leading, 12)
            .padding(.trailing, 12)
            .background(Color.red)
            .cornerRadius(200)
        }
    }
}

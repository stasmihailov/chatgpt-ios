//
//  Test.swift
//  ChatGPTApp
//
//  Created by Denis Babochenko on 12/05/2023.
//

import SwiftUI

struct Test: View {
    @State var apiKey: String = ""
    
    var body: some View {
        NavigationView {
            List {
                ForEach(1...40, id: \.self) { id in
                    Text("Hello, World!")
                }
            }
            .navigationTitle("Hello, Boris")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    AppButtons.destructive(label: "Log out") {
                        
                    }
                }
            }
        }
    }
}

struct TestPreview_Previews: PreviewProvider {
    static var previews: some View {
        Test()
    }
}

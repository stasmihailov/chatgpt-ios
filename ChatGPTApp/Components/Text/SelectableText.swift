//
//  SelectableText.swift
//  ChatGPTApp
//
//  Created by Denis Babochenko on 07/05/2023.
//
import SwiftUI
import UIKit
import MarkdownUI

struct SelectableText: View {
    var text: String
    
    init(_ text: String) {
        self.text = text
    }
    
    var body: some View {
        Markdown(text)
    }
}

struct SelectableText_Previews: PreviewProvider {
    struct SelectableTextContainer: View {
        struct Msg: View {
            @State var height: CGFloat = 0
            var text: String
            
            init(_ text: String) {
                self.text = text
            }

            var body: some View {
                VStack {
                    Text("Message")
                    SelectableText(text)
                }
                .padding()
            }
        }

        var body: some View {
            List {
                Msg("lol")
                Msg("""
                Today is the anniversary of the publication of Robert Frost’s iconic poem “Stopping by Woods on a Snowy Evening,” a fact that spurred the Literary Hub office into a long conversation about their favorite poems, the most iconic poems written in English, and which poems we should all have already read (or at least be reading next).
                """)
                Msg("Today is the anniversary of the publication of Robert Frost’s iconic poem “Stopping by Woods on a Snowy Evening,” a fact that spurred the Literary Hub office into a long conversation about their favorite poems, the most iconic poems written in English, and which poems we should all have already read (or at least be reading next).")
                Msg("lol")
            }.listStyle(.plain)
        }
    }
    
    static var previews: some View {
        SelectableTextContainer()
    }
}

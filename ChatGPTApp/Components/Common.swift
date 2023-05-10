//
//  Common.swift
//  ChatGPTApp
//
//  Created by Denis Babochenko on 03/05/2023.
//

import SwiftUI

extension View {
    public func tinted() -> some View {
        return self
    .background(
            VisualEffectView(effect: UIBlurEffect(style: .systemMaterial))
                .edgesIgnoringSafeArea(.all)
        )
    }
    
    public func dismissKeyboardOnTap() -> some View {
        return self
            .onTapGesture {
                UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder),
                                                to: nil, from: nil, for: nil)
            }
    }
}

fileprivate struct VisualEffectView: UIViewRepresentable {
    let effect: UIVisualEffect

    func makeUIView(context: Context) -> UIVisualEffectView {
        return UIVisualEffectView(effect: effect)
    }

    func updateUIView(_ uiView: UIVisualEffectView, context: Context) {
        uiView.effect = effect
    }
}

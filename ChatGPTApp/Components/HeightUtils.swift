//
//  HeightUtils.swift
//  ChatGPTApp
//
//  Created by Denis Babochenko on 03/05/2023.
//

import SwiftUI

extension View {
    func captureHeight(_ trigger: @escaping (CGFloat) -> Void) -> some View {
        return self
            .background(GeometryReader { geometry -> Color in
                DispatchQueue.main.async {
                    self.inputHeight = geometry.size.height
                }
                return Color.clear
            })
    }
}

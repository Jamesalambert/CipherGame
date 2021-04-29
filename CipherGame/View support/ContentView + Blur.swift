//
//  ContentView + Blur.swift
//  CipherGame
//
//  Created by J Lambert on 08/04/2021.
//

import SwiftUI

struct Blur : UIViewRepresentable {
    
    var style : UIBlurEffect.Style = .systemMaterial
    
    func makeUIView(context: Context) -> UIVisualEffectView {
        return UIVisualEffectView(effect: UIBlurEffect(style: style))
    }

    func updateUIView(_ uiView: UIVisualEffectView, context: Context) {
        uiView.effect = UIBlurEffect(style: style)
    }
}



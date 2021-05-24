//
//  Custom Animation.swift
//  CipherGame
//
//  Created by J Lambert on 23/05/2021.
//

import SwiftUI

struct Debug {
    static var animation : Bool = false
}

extension Animation {
    static var spring : Animation {.spring(response: Debug.animation ? 3 : 0.3, dampingFraction: 0.5, blendDuration: 0)}
    static var standardUI: Animation {.easeInOut(duration: Debug.animation ? 3 : 0.15) }
}


struct Snap : AnimatableModifier {
    var animatableData: Double
    func body(content: Content) -> some View {
        content.opacity(1)
    }
}


struct Flip : AnimatableModifier {
    var animatableData: Double {
        get {rotation / 180}
        set {rotation = newValue * 180}
    }
    var rotation : Double
    func body(content: Content) -> some View {
        content.rotation3DEffect(Angle(degrees: rotation), axis: (0,1,0))
    }
}

extension AnyTransition{
    static var flip : AnyTransition {
        AnyTransition.modifier(
            active: Flip(rotation: 0),
            identity: Flip(rotation: 180))
    }
}

extension AnyTransition{
    static var snap : AnyTransition {
        AnyTransition.modifier(
            active: Snap(animatableData: 0),
            identity: Snap(animatableData: 1))
    }
}



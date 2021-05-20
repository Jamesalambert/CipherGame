//
//  useful view code.swift
//  CipherGame
//
//  Created by J Lambert on 20/05/2021.
//

import SwiftUI


struct RoundSomeCorners : ViewModifier {
    
    var radius : CGFloat
    var corners : UIRectCorner
    
    func body(content: Content) -> some View {
        content.clipShape(RoundedRectShape(radius: radius, corners: corners))
    }
}

struct  RoundedRectShape : Shape {
    var radius : CGFloat = .infinity
    var corners : UIRectCorner = .allCorners
    func path(in rect: CGRect) -> Path {
        let path = UIBezierPath(roundedRect: rect,
                                byRoundingCorners: corners,
                                cornerRadii: CGSize(width: radius, height: radius))
        return Path(path.cgPath)
    }
}



//
//  TilePuzzle.swift
//  CipherGame
//
//  Created by J Lambert on 07/05/2021.
//

import SwiftUI
import UIKit

struct TilePuzzle: View {
    
    @EnvironmentObject
    var viewModel : CipherPuzzle
    
    @Environment(\.colorScheme)
    var colorScheme : ColorScheme
    
    @Environment(\.bookTheme)
    var bookTheme : BookTheme
    
    var puzzleImage : UIImage
    
    var isSolved : Bool {
        return grid.isSolved
    }
        
    var grid : GridPuzzle
    
    var body: some View {
        LazyVGrid(columns: self.columns(width: 100, spacing: 0), spacing: 0){
            ForEach(grid.rows){ row in
                ForEach(row.tiles){ tile in
                    Group {
                        if tile.content == 0 {
                            if tile.isEnabled {
                                Image(uiImage: puzzleImage.rect(x: tile.index[0], y: tile.index[1],size: grid.size))
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                                .cornerRadius(10)
                                .id(tile.id)
                            } else {
                                ZStack{
                                    Color.white.opacity(0.3).cornerRadius(10)
                                    Image(systemName: "questionmark.circle")
                                        .resizable(capInsets: .sized(horizontally: 10, vertically: 10), resizingMode: .stretch)
//                                        .cornerRadius(10)
                                }
                                .id(tile.id)
                            }
                        } else {
                            ZStack{}
                        }
                    }
                    .onTapGesture {
                        withAnimation{
                            viewModel.gridMove(tileHash: tile.id)
                        }
                    }
                }
            }
        }
    }
    
    func columns(width: Int, spacing: Int)->[GridItem]{
        return Array(repeating: GridItem(.fixed(CGFloat(width)),
                                         spacing: CGFloat(spacing),
                                         alignment: .center),
                     count: grid.size)
    }
}


extension UIImage {
    func rect(x : Int, y: Int, size : Int) -> UIImage {
        guard let image = self.cgImage else {return self}
        let width = image.width
        let height = image.height
        let rectSize = CGSize(width: width / size, height: height / size)
        let origin = CGPoint(x: x * Int(rectSize.width), y: y * Int(rectSize.height))
        let croppedImage = image.cropping(to: CGRect(origin: origin, size: rectSize))!
        return UIImage(cgImage: croppedImage)
    }
}

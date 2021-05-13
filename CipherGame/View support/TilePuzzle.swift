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
    
    var screenSize : CGSize
    
    var grid : GridPuzzle
    
    var body: some View {
        LazyVGrid(columns: self.columns(), spacing: 0){
            ForEach(grid.rows){ row in
                ForEach(row.tiles){ tile in
                    Group {
                        if tile.content == 0 || grid.isSolved {
                            if grid.tileIsEnabled(tile.id){
                                Image(uiImage: puzzleImage.rect(row: tile.index[0], col: tile.index[1],size: grid.size))
                                .resizable()
                                .aspectRatio(1, contentMode: .fit)
                                    .cornerRadius(10)
                                .id(tile.id)
                            } else {
                                ZStack{
                                    Color.white.opacity(0.4)
                                        .cornerRadius(10)
                                    Image(systemName: "questionmark.circle")
                                        .resizable(capInsets: EdgeInsets.zero(), resizingMode: .stretch)
                                        .aspectRatio(1,contentMode: .fit)
                                        .padding()
                                }
                                .overlay(RoundedRectangle(cornerRadius: 10).stroke(Color.black, lineWidth: 2)  )
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
    
    func columns()->[GridItem]{
        let width = 0.8 * min(screenSize.height, screenSize.width) / CGFloat(grid.size)
        return Array(repeating: GridItem(.fixed(CGFloat(width)),
                                         spacing: CGFloat(0),
                                         alignment: .center),
                     count: grid.size)
    }
}


extension UIImage {
    func rect(row : Int, col: Int, size : Int) -> UIImage {
        guard let image = self.cgImage else {return self}
        let width = image.width
        let height = image.height
        let rectSize = CGSize(width: width / size, height: height / size)
        let origin = CGPoint(x: col * Int(rectSize.height), y: row * Int(rectSize.width))
        let croppedImage = image.cropping(to: CGRect(origin: origin, size: rectSize))!
        return UIImage(cgImage: croppedImage)
    }
}
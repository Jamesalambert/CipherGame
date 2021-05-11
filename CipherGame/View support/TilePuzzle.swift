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
    
    //var grid : GridPuzzle
    
    var body: some View {
        LazyVGrid(columns: self.columns(), spacing: 0){
            ForEach(viewModel.currentGridPuzzle!.rows){ row in
                ForEach(row.tiles){ tile in
                    Group {
                        if tile.content == 0 || viewModel.currentGridPuzzle!.isSolved {
                            if viewModel.currentGridPuzzle!.tileIsEnabled(tile.id){
                                Image(uiImage: puzzleImage.rect(x: tile.index[0], y: tile.index[1],size: viewModel.currentGridPuzzle!.size))
                                .resizable()
                                .aspectRatio(1, contentMode: .fit)
                                    .cornerRadius(viewModel.currentGridPuzzle!.isSolved ? 0 : 10)
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
        let width = 0.8 * min(screenSize.height, screenSize.width) / CGFloat(viewModel.currentGridPuzzle!.size)
        return Array(repeating: GridItem(.fixed(CGFloat(width)),
                                         spacing: CGFloat(0),
                                         alignment: .center),
                     count: viewModel.currentGridPuzzle!.size)
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

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
        LazyVGrid(columns: self.columns(width: 100 ), spacing:0){
            ForEach(grid.rows){ row in
                ForEach(row.tiles){ tile in
                    if tile.content == 0, tile.isEnabled {
                    Image(uiImage: puzzleImage.rect(x: tile.index[0], y: tile.index[1]))
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .cornerRadius(10)
                        .id(tile.id)
                        .onTapGesture {
                            withAnimation{
                                viewModel.gridMove(tileHash: tile.id)
                            }
                        }
                    } else {
                        ZStack{}
                    }
                }
            }
        }
    }
    
    func columns(width: Int)->[GridItem]{
        return Array(repeating: GridItem(.fixed(CGFloat(width)), spacing: 0, alignment: .center), count: 3)
    }
}



//struct TilePuzzle_Previews: PreviewProvider {
//    static var previews: some View {
//        TilePuzzle(puzzleImage: UIImage(named: "marsRover")!, grid: GridPuzzle(imageName: "marsRover"))
//    }
//}

extension UIImage {
    func rect(x : Int, y: Int) -> UIImage {
        guard let image = self.cgImage else {return self}
        let width = image.width
        let height = image.height
        let rectSize = CGSize(width: width / 3, height: height / 3)
        let origin = CGPoint(x: x * Int(rectSize.width), y: y * Int(rectSize.height))
        let croppedImage = image.cropping(to: CGRect(origin: origin, size: rectSize))!
        return UIImage(cgImage: croppedImage)
    }
}

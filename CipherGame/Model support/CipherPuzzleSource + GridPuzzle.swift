//
//  CipherPuzzleSource + GridPuzzle.swift
//  CipherGame
//
//  Created by J Lambert on 09/05/2021.
//

import Foundation

    //Model
    struct GridPuzzle : Codable {
        
        var rows : [Row]
        var imageName : String
        
        var isEnabled : Bool {
            return rows.allSatisfy({$0.tiles.allSatisfy{$0.isEnabled}})
        }
        
        var isSolved : Bool {
            for (rowIndex, row) in self.rows.enumerated() {
                for (tileIndex, tile) in row.tiles.enumerated(){
                    if tile.index != [tileIndex, rowIndex] {
                        return false
                    }
                }
            }
            return true
        }
        
        var id = UUID()
        
        mutating
        func move(id : UUID) {
            let (x, y) : (Int,Int) = tappedSquare(with: id)
            if canMove(x: x, y: y){
                let movedTile = rows[y].tiles[x]
                let emptyTile = emptySquare()
                self.rows[y].tiles[x] = self.rows[emptyTile.y].tiles[emptyTile.x]
                self.rows[emptyTile.y].tiles[emptyTile.x] = movedTile
            }
        }
        
        private
        func canMove(x : Int, y : Int) -> Bool{
            if self.isEnabled{
                let emptySquare = emptySquare()
                var adjacentPoints : [(Int,Int)] = []
                adjacentPoints.append((emptySquare.x + 1, emptySquare.y))
                adjacentPoints.append((emptySquare.x, emptySquare.y + 1))
                adjacentPoints.append((emptySquare.x - 1, emptySquare.y))
                adjacentPoints.append((emptySquare.x, emptySquare.y - 1))
                return adjacentPoints.contains{$0 == (x,y)}
            }
            return false
        }
        
        private
        func emptySquare() -> (x : Int, y : Int) {
            for column in 0...2{
                for row in 0...2{
                    if self.rows[row].tiles[column].content == 1 {
                        return (column,row)
                    }
                }
            }
            return (-1,-1)
        }
        
        private
        func tappedSquare(with id : UUID) -> (x : Int, y : Int) {
            for column in 0...2{
                for row in 0...2{
                    if self.rows[row].tiles[column].id == id{
                        return (column,row)
                    }
                }
            }
            return (-1,-1)
        }
        
        init(imageName: String) {
            let arr : [[Int]] = [[0,0,0],[0,0,0],[1,0,0]]
            var rows : [Row] = []
            for (rowIndex, row) in arr.enumerated() {
                var tiles : [Tile] = []
                for (colIndex, value) in row.enumerated() {
                    tiles.append(Tile(index: [colIndex, rowIndex], content: value, isEnabled: true))
                }
                rows += [Row(tiles: tiles)]
            }
            
            self.rows = rows
            self.imageName = imageName
        }
    }
    
    struct Row : Identifiable, Codable {
        var id = UUID()
        var tiles : [Tile]
    }
    
    struct Tile : Identifiable, Codable{
        var id = UUID()
        var index : [Int]
        var content : Int
        var isEnabled : Bool = true
    }


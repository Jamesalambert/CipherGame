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
        
        var size : Int
        
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
            #if DEBUG
            printState()
            #endif
        }
        
        private
        func canMove(x : Int, y : Int) -> Bool{
            let emptySquare = emptySquare()
            var adjacentPoints : [(Int,Int)] = []
            adjacentPoints.append((emptySquare.x + 1, emptySquare.y))
            adjacentPoints.append((emptySquare.x, emptySquare.y + 1))
            adjacentPoints.append((emptySquare.x - 1, emptySquare.y))
            adjacentPoints.append((emptySquare.x, emptySquare.y - 1))
            return adjacentPoints.contains{$0 == (x,y)}
        }
        
        private
        func emptySquare() -> (x : Int, y : Int) {
            for column in 0..<self.size{
                for row in 0..<self.size{
                    if self.rows[row].tiles[column].content == 1 {
                        return (column,row)
                    }
                }
            }
            return (-1,-1)
        }
        
        private
        func tappedSquare(with id : UUID) -> (x : Int, y : Int) {
            for column in 0..<self.size{
                for row in 0..<self.size{
                    if self.rows[row].tiles[column].id == id{
                        return (column,row)
                    }
                }
            }
            return (-1,-1)
        }
        
        private
        func printState(){
            for row in rows{
                var rowString = ""
                for tile in row.tiles{
                    rowString += "\(tile.index[0]),\(tile.index[1]) "
                }
                print(rowString)
            }
            print("isSolved: \(isSolved)\n")
        }
        
        
        init(imageName: String, size : Int = 4) {
            var arr : [[Int]] = Array(repeating: Array(repeating: 0, count: size), count: size)
            arr[size - 1][0] = 1
            
            var rows : [Row] = []
            var tiles : [Tile] = []
            
            for (rowIndex, row) in arr.enumerated() {
                for (colIndex, value) in row.enumerated() {
                    tiles.append(Tile(index: [colIndex, rowIndex], content: value, isEnabled: rowIndex == 1 ? false : true))
                }
            }
            
            tiles = tiles.shuffled()
            
            for startIndex in stride(from: 0, to: size * size, by: size) {
                rows.append(Row(tiles: Array(tiles[startIndex...startIndex.advanced(by: size - 1)])))
            }
            
            self.size = size
            self.rows = rows
            self.imageName = imageName
            print("init")
            printState()
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


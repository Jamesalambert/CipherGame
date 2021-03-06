//
//  CipherPuzzleSource + GridPuzzle.swift
//  CipherGame
//
//  Created by J Lambert on 09/05/2021.
//

import Foundation

//Model
struct GridPuzzle : Codable, GameStage {
    
    var title: String
    var rows : [Row]
    let imageName : String?
    let solutionImageName : String?
    let size : Int
    let numberOfHiddenTiles : Int
    var id : UUID
    var solutionType : GridSolution = .rows
    var dependencies : [UUID]
    
    var isSolved : Bool {
        return GridPuzzle.soultionChecker(self)
    }
    
    func isFaceUp(_ tile : Tile) -> Bool{
        return self.isSolved || (tile.isEnabled && tile.content == 0)
    }
    
    func isMystery(_ tile : Tile) -> Bool{
        return self.isHidden(tile) && !tile.canBeEnabled
    }
    
    func isEmpty(_ tile : Tile) -> Bool {
        return tile.content == 1 && !self.isSolved
    }
    
    private
    func isHidden(_ tile : Tile) -> Bool{
        return tile.content == 0 && !self.isSolved && !tile.isEnabled
    }
    
    mutating
    func addTile(){
        guard let firstAddableTile = rows.flatMap({$0.tiles}).first(where: {!$0.isEnabled && !$0.canBeEnabled}) else {return}
        let rowIndex = rows.firstIndex(where: {$0.tiles.contains{$0 == firstAddableTile}})
        let tileIndex = rows[rowIndex!].tiles.firstIndex(where: {$0 == firstAddableTile})
        rows[rowIndex!].tiles[tileIndex!].setCanBeEnabled()
    }
    
    mutating
    func reveal(_ tile : Tile){
        let rowIndex = rows.firstIndex(where: {$0.tiles.contains{$0 == tile}})
        let tileIndex = rows[rowIndex!].tiles.firstIndex(where: {$0 == tile})
        rows[rowIndex!].tiles[tileIndex!].enable()
    }
    
    mutating
    func move(_ tile : Tile) {
        guard !isSolved else {return}
        let (x, y) : (Int,Int) = tappedSquare(with: tile)
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
    
    mutating
    func reset(){
        self = GridPuzzle(title: self.title,
                          imageName: self.imageName,
                          size: self.size,
                          hiddenTiles: self.numberOfHiddenTiles,
                          revealedImage: self.solutionImageName,
                          type: self.solutionType,
                          id: self.id,
                          dependencies: self.dependencies)
    }
    
    mutating
    func shuffleTiles() {
        let tiles : [Tile] = rows.flatMap{$0.tiles}.shuffled()
        
        self.rows.removeAll()
        
        for startIndex in stride(from: 0, to: size * size, by: size) {
            rows.append(Row(tiles: Array(tiles[startIndex...startIndex.advanced(by: size - 1)])))
        }
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
    func tappedSquare(with tile : Tile) -> (x : Int, y : Int) {
        for column in 0..<self.size{
            for row in 0..<self.size{
                if self.rows[row].tiles[column] == tile{
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
                rowString += "\(tile.index[0]),\(tile.index[1]), \(tile.isEnabled ? "E" : ""), \(tile.canBeEnabled ? "T" : "") "
            }
            print(rowString)
        }
        print("isSolved: \(isSolved)\n")
    }
    
    //solution functions
    private
    static
    func soultionChecker(_ puzzle : GridPuzzle) -> Bool {
        guard puzzle.rows.allSatisfy({row in !row.tiles.contains(where: {tile in !tile.isEnabled})}) else {return false}
        
        switch puzzle.solutionType {
        case .all:
            return GridPuzzle.allChecker(rows: puzzle.rows)
        case .rows:
            return GridPuzzle.rowsChecker(rows: puzzle.rows)
        case .columns:
            return GridPuzzle.columnsChecker(rows: puzzle.rows)
        }
    }
    
    //all
    private
    static
    func allChecker(rows : [Row]) -> Bool{
        for (rowIndex, row) in rows.enumerated() {
            for (tileIndex, tile) in row.tiles.enumerated(){
                if tile.index != [tileIndex, rowIndex] {
                    return false
                }
            }
        }
        return true
    }
    
    private
    static
    func rowsChecker(rows : [Row]) ->Bool {
        rows.enumerated().allSatisfy{(rowIndex, row) -> Bool in
            row.tiles.allSatisfy{ tile in
                tile.index[0] == rowIndex}
        }
    }
    
    private
    static
    func columnsChecker(rows : [Row]) ->Bool {
        rows.allSatisfy{ row in
            row.tiles.enumerated().allSatisfy{ (tileIndex, tile) in
                tile.index[1] == tileIndex}
        }
    }
    //solution funcs
    
    init(puzzle : ReadableGridPuzzle) {
        self = GridPuzzle(title: puzzle.title,
                          imageName: puzzle.image,
                          size: puzzle.size,
                          revealedImage: puzzle.solutionImage,
                          type: puzzle.type,
                          id: puzzle.id,
                          dependencies: puzzle.dependencies)
    }
    
    init(title: String, imageName: String?, size : Int = 4, hiddenTiles : Int = 0, revealedImage : String?, type: GridSolution, id: UUID, dependencies: [UUID]) {
        
        var arr : [[Int]] = Array(repeating: Array(repeating: 0, count: size), count: size)
        arr[size - 1][0] = 1
        
        var rows : [Row] = []
        var tiles : [Tile] = []
        
        for (rowIndex, row) in arr.enumerated() {
            for (colIndex, value) in row.enumerated() {
                tiles.append(Tile(index: [colIndex, rowIndex], content: value))
            }
        }
        
        tiles = tiles.shuffled()
        
        if hiddenTiles < tiles.count{
            for tileIndex in 0..<hiddenTiles {
                tiles[tileIndex].disable()
            }
        }
        
        tiles = tiles.shuffled()
        
        for startIndex in stride(from: 0, to: size * size, by: size) {
            rows.append(Row(tiles: Array(tiles[startIndex...startIndex.advanced(by: size - 1)])))
        }
        
        self.title = title
        self.size = size
        self.numberOfHiddenTiles = hiddenTiles
        self.rows = rows
        self.imageName = imageName
        self.solutionImageName = revealedImage
        self.solutionType = type
        self.id = id
        self.dependencies = dependencies
        #if DEBUG
        print("init")
        printState()
        #endif
    }
    
}

struct Row : Identifiable, Codable {
    var id = UUID()
    var tiles : [Tile]
}

struct Tile : Identifiable, Hashable, Codable{
    
    let index : [Int]
    let content : Int
    var id = UUID()
    
    var isEnabled : Bool = true
    var canBeEnabled : Bool = false
    
    mutating
    func enable(){
        if canBeEnabled{
            isEnabled = true
            canBeEnabled = false
        }
    }
    
    mutating
    func disable(){
        isEnabled = false
    }
    
    mutating
    func setCanBeEnabled(){
        canBeEnabled = true
    }
}

enum GridSolution : String, Codable, CaseIterable {
    
    case all  = "all"
    case rows = "rows"
    case columns = "columns"
    
    init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        let value = try? container.decode(String.self)
        switch value{
        case "all": self = .all
        case "rows": self = .rows
        case "columns": self = .columns
        default:
            self = .all
        }
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        try container.encode(self.rawValue)
//        switch self {
//        case .all: try container.encode(self.rawValue)
//        case .rows: try container.encode("rows")
//        case .columns: try container.encode("columns")
//        }
    }
    
}

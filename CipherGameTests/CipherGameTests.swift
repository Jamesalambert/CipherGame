//
//  CipherGameTests.swift
//  CipherGameTests
//
//  Created by J Lambert on 16/03/2021.
//

import XCTest
@testable import CipherGame

class CipherGameTests: XCTestCase {
    
    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }


    func testGetPuzzleData() throws {
        // This is an example of a performance test case.
        let cipherPuzzleViewModel = CipherPuzzle()
        
        self.measure {
            let _ = cipherPuzzleViewModel.data
        }
    }

    func testLoadPuzzleUI() throws {
        
        let cipherPuzzleViewModel = CipherPuzzle()
                
        self.measure {
            let _ = ContentView(viewModel: cipherPuzzleViewModel, saveAction: {})
        }
    }
    
    func testPuzzles() throws {
//        let puzzleModel = Game()
//        
//        //make sure there's a first puzzle
//        assert(puzzleModel.lastOpenPuzzleHash != nil)
//        
//        let puzzles = puzzleModel.books.flatMap{book in book.puzzles}
//        
//        for puzzle in puzzles {
//            //any uppercase in plaintext?
//            assert(!puzzle.plaintext.contains(where: {char in char.isUppercase}))
//            //key alphabet has 26 chars
//            assert(puzzle.keyAlphabet.count == 26)
//            //plain and ciphertext are equal lengths
//            assert(puzzle.plaintext.count == puzzle.ciphertext.count)
//            //no whitespace except spaces
//            assert(!puzzle.plaintext.contains(where: {char in char.isWhitespace && char != " "}))
//        }
        
        
        
    }
    
}

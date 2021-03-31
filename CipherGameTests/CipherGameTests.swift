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
        
        cipherPuzzleViewModel.currentPuzzleHash = cipherPuzzleViewModel.puzzleTitles(for: 0).first?.id

        self.measure {
            let _ = cipherPuzzleViewModel.data
        }
    }

    func testLoadPuzzleUI() throws {
        
        let cipherPuzzleViewModel = CipherPuzzle()
        
        cipherPuzzleViewModel.currentPuzzleHash = cipherPuzzleViewModel.puzzleTitles(for: 0).first?.id
        
        self.measure {
            let _ = ContentView(viewModel: cipherPuzzleViewModel)
        }
    }
    
}

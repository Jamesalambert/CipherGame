//
//  OnlineStore keychain tests.swift
//  CipherGameTests
//
//  Created by J Lambert on 25/05/2021.
//

import XCTest
@testable import CipherGame

class OnlineStore_keychain_tests: XCTestCase {
    
    var store : OnlineStore!
    var viewModel : CipherPuzzle!
    var bookNames : [String] = {
        (1...10).map{_ in
            String.alphabet.sample(of: 10).reduce(into: "", {(result, char) in return result += String(char)})
        }
    }()
    var bookIds : [String] = {
        (1...10).map{_ in
            String.alphabet.sample(of: 10).reduce(into: "", {(result, char) in return result += String(char)})
        }
    }()

    override func setUpWithError() throws {
        self.store = OnlineStore()
        self.viewModel = CipherPuzzle()
    }

    override func tearDownWithError() throws {
        self.viewModel.deleteAllPurchasesFromKeychain()
    }

    func testExample() throws {
        print(bookNames)
        print(bookIds)
        
        let exp = expectation(description: "store/retrieve in keychain")
        
        do {
            for (bookName, bookID) in zip(bookNames, bookIds){
                self.store.storeRecieptInKeychain(for: bookName, identifier: bookID)
            }
            
            DispatchQueue.global().async {
                self.viewModel.loadPurchasedBooksFromKeychain{ bookIds in
                    assert(bookIds.allSatisfy({self.viewModel.model.activeBookIds.contains($0)}))
                    exp.fulfill()
                }
            }
            
            wait(for: [exp], timeout: 10)
            
        }
    }

    func testPerformanceExample() throws {
        // This is an example of a performance test case.
        self.measure {
            // Put the code you want to measure the time of here.
        }
    }

}

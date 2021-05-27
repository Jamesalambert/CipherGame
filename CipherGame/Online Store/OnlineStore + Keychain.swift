//
//  CipherPuzzle + IAP.swift
//  CipherGame
//
//  Created by J Lambert on 01/05/2021.
//

import Foundation

extension OnlineStore {
    
    static let kcServiceString = "Puzzle Room"
    static let kcAccountString = "Purchased Books"
    static let kcQuery : [String : Any] = [
        kSecClass               as String           : kSecClassGenericPassword,
        kSecAttrService         as String           : OnlineStore.kcServiceString as Any,
        kSecAttrAccount         as String           : OnlineStore.kcAccountString as Any,
        kSecAttrSynchronizable  as String           : true
    ]
    
    func storeRecieptInKeychain(for bookName : String, newBookIdentifier : String) {
        
        var booksInKeychain : [String] = self.getpurchasesFromKeychain()
        
        //append new product id
        if !booksInKeychain.contains(newBookIdentifier){
            booksInKeychain.append(newBookIdentifier)
        }
        
        guard let dataToWrite = try? JSONEncoder().encode(booksInKeychain) else {print("couldn't encode data");return}
        
        let newKeychainData : [String : Any] = [kSecValueData as String : dataToWrite as Any]
        
        var foundItem : CFTypeRef?
        let searchStatus = SecItemCopyMatching(Self.kcQuery as CFDictionary, &foundItem)
        
        switch searchStatus {
        case errSecSuccess:
            //update keychain
            let success = SecItemUpdate(Self.kcQuery as CFDictionary, newKeychainData as CFDictionary)
            
            switch success {
            case errSecSuccess:
                stateDescription = "recoded purchase in keychain)"
                print("successfully wrote \(newBookIdentifier) to keychain: \(success.string)")
                return
            default:
                stateDescription = "couldn't record purcase in keychain)"
                print("couldn't write \(newBookIdentifier) to keychain error: \(success.string)")
            }
            
        default:
            //create new keychain item
            var queryForWriting = Self.kcQuery
            queryForWriting[kSecValueData as String] = dataToWrite as Any
            
            var createdItem : CFTypeRef?
            let success = SecItemAdd(queryForWriting as CFDictionary, &createdItem)

            switch success {
            case errSecSuccess:
                stateDescription = "recoded purchase in keychain)"
                print("successfully wrote \(newBookIdentifier) to keychain: \(success.string)")
                return
            default:
                stateDescription = "couldn't record purcase in keychain)"
                print("couldn't write \(newBookIdentifier) to keychain error: \(success.string)")
            }
        }
    }
    
    func loadPurchasedBooksFromKeychain(completion : @escaping (([String]) -> Void)){
        DispatchQueue.global(qos: .background).async {
            let purchasedBookIds = self.getpurchasesFromKeychain()
            DispatchQueue.main.async {
                print("adding to model: \(purchasedBookIds)")
                //call completion block
                completion(purchasedBookIds)
            }
        }
    }
    
    private
    func getpurchasesFromKeychain() -> [String] {
        
        var query = Self.kcQuery
        query[kSecReturnAttributes as String] = true
        query[kSecReturnData as String] = true
        
        var foundItems : CFTypeRef?
        let searchStatus = SecItemCopyMatching(query as CFDictionary, &foundItems)

        #if DEBUG
        print("Keychain message \(searchStatus): \(searchStatus.string)")
        #endif
        guard let result = foundItems as? [String : Any] else {return []}
        guard let productIDsData = result[kSecValueData as String] as? Data else {return []}
        
        if let output = try? JSONDecoder().decode(Array<String>.self, from: productIDsData) {
            return output
        }
        return []
    }
    
    //MARK:- debug
    func deleteAllPurchasesFromKeychain(){
        print("deleting...")
        let success = SecItemDelete(Self.kcQuery as CFDictionary)
        if success == errSecSuccess {objectWillChange.send()} //update debug ui automatically
        print("Keychain message \(success): \(success.string)")
    }
    
    func printKeychainData() -> String {
        print("printing keychain data")
        let data = getpurchasesFromKeychain()
        return data.description
    }
}


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
    
    func storeRecieptInKeychain(for bookName : String, newBookIdentifier : String) {
        
        var booksInKeychain : [String] = self.getpurchasesFromKeychain()
        
        //append new product id
        if !booksInKeychain.contains(newBookIdentifier){
            booksInKeychain.append(newBookIdentifier)
        }
        
        guard let dataToWrite = try? JSONEncoder().encode(booksInKeychain) else {print("couldn't encode data");return}

        var query : [String : Any] = [
            kSecClass as String                 : kSecClassGenericPassword,
            kSecAttrService as String           : Self.kcServiceString,        //"Puzzle Room"
            kSecAttrAccount as String           : Self.kcAccountString         //book ID
        ]
        
        let newKeychainData : [String : Any] = [kSecValueData as String : dataToWrite as Any]
        
        var foundItem : CFTypeRef?
        let searchStatus = SecItemCopyMatching(query as CFDictionary, &foundItem)
        
        switch searchStatus {
        case errSecSuccess:
            //update keychain
            let success = SecItemUpdate(query as CFDictionary, newKeychainData as CFDictionary)
            
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
            query[kSecValueData as String] = dataToWrite as Any
            var createdItem : CFTypeRef?
            let success = SecItemAdd(query as CFDictionary, &createdItem)

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
        let query : [String : Any] = [
            kSecClass       as String       : kSecClassGenericPassword,
            kSecAttrService as String       : OnlineStore.kcServiceString as Any,
            kSecAttrAccount as String       : OnlineStore.kcAccountString as Any,
            kSecReturnAttributes as String  : true,
            kSecReturnData as String      : true
        ]
        
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
        let query : [String : Any] = [
            kSecClass       as String       : kSecClassGenericPassword,
            kSecAttrService as String       : OnlineStore.kcServiceString as Any,
            kSecAttrAccount as String       : OnlineStore.kcAccountString as Any
        ]
        let success = SecItemDelete(query as CFDictionary)
        print("Keychain message \(success): \(success.string)")
    }
    
    func printKeychainData(){
        print("printing keychain")
        print(getpurchasesFromKeychain())
    }
}


//
//  CipherPuzzle + IAP.swift
//  CipherGame
//
//  Created by J Lambert on 01/05/2021.
//

import Foundation

extension CipherPuzzle {
        
    func loadPurchasedBooksFromKeychain(completion : (([String]) -> Void)? = nil){
        //read keychain for IAP
        DispatchQueue.global(qos: .background).async {
            let purchasedBookIds = self.getpurchasesFromKeychain()
            DispatchQueue.main.async {
                print("adding to model: \(purchasedBookIds)")
                self.model.add(books: purchasedBookIds)
                
                //call completion block if it exists
                completion?(purchasedBookIds)
            }
        }
    }
    
    //for debugging
    func deleteAllPurchasesFromKeychain(){
        print("deleting...")
        let query : [String : Any] = [
            kSecClass       as String       : kSecClassGenericPassword,
            kSecAttrService as String       : OnlineStore.kcServiceString as Any,
            kSecAttrAccount as String       : OnlineStore.kcAccountString as Any
        ]

        //delete!
        let success = SecItemDelete(query as CFDictionary)
        print("Keychain message \(success): \(success.string)")
        
    }
    
    private
    func getpurchasesFromKeychain() -> [String] {
        print("printing keychain")
        
        let query : [String : Any] = [
            kSecClass       as String       : kSecClassGenericPassword,
            kSecAttrService as String       : OnlineStore.kcServiceString as Any,
            kSecAttrAccount as String       : OnlineStore.kcAccountString as Any,
            kSecReturnAttributes as String  : true,
            kSecReturnData as String      : true
        ]
        
        var foundItems : CFTypeRef?
        let searchStatus = SecItemCopyMatching(query as CFDictionary, &foundItems)

        print("Keychain message \(searchStatus): \(searchStatus.string)")

        guard let result = foundItems as? [String : Any] else {return []}
        guard let productIDsData = result[kSecValueData as String] as? Data else {return []}
        guard let productIDs = String(data: productIDsData, encoding: .utf8) else {return []}
        
        let output = productIDs.split(separator: ",").map{String($0)}
        
        return output
    }
    
    func printKeychainData(){
        print("printing keychain")
        
        let query : [String : Any] = [
            kSecClass       as String       : kSecClassGenericPassword,
            kSecAttrService as String       : OnlineStore.kcServiceString as Any,
            kSecAttrAccount as String       : OnlineStore.kcAccountString as Any,
            kSecReturnAttributes as String  : true,
            kSecReturnData as String      : true
        ]
        
        var foundItems : CFTypeRef?
        let searchStatus = SecItemCopyMatching(query as CFDictionary, &foundItems)

        print("Keychain message \(searchStatus): \(searchStatus.string)")

        guard let result = foundItems as? [String : Any] else {return}
        guard let productIDsData = result[kSecValueData as String] as? Data else {return}
        guard let productIDs = String(data: productIDsData, encoding: .utf8) else {return}
        print(productIDs)
    }
    
    
    
    
    
    
}


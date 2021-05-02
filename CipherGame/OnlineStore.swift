//
//  OnlineStore.swift
//  CipherGame
//
//  Created by J Lambert on 30/04/2021.
//

import Foundation
import StoreKit

class OnlineStore : NSObject, ObservableObject {

    static let shared = OnlineStore()
    static let productsKey = "productIDs"
    
    @Published
    var productIDs : [String] = {
        guard let array =  UserDefaults.standard.object(forKey: OnlineStore.productsKey) as? [String] else {return []}
        print(array)
        return array
    }()
    
    @Published
    var finishedTransactions : Bool = false
    
    @Published
    var booksForSale : [ProductInfo] = []
    
    private
    var products = [SKProduct]()
    
    func getProducts(){
        let request = SKProductsRequest(productIdentifiers: Set(productIDs))
        request.delegate = self
        request.start()
    }

    func buyProduct(_ id : String){
        guard let product = self.products.first(where: {$0.productIdentifier == id}) else {
            print("Couldn't find product with id: \(id)")
            return
        }
        if SKPaymentQueue.canMakePayments(){
            let payment = SKPayment(product: product)
            SKPaymentQueue.default().add(self)
            SKPaymentQueue.default().add(payment)
        }
    }
    
    func restorePurchases() {
        SKPaymentQueue.default().add(self)
        SKPaymentQueue.default().restoreCompletedTransactions()
    }
    
    //needed for restoring transactions?!
    func paymentQueueRestoreCompletedTransactionsFinished(_ queue: SKPaymentQueue) {
        print("Finished restoring purchases.")
    }
    
    override init() {
        //TODO: retrieve from the network
        let defaults = UserDefaults.standard
        defaults.set(["test.mysteryIsland","test.spaceBook"], forKey: Self.productsKey)
    }
    
}



extension OnlineStore : SKProductsRequestDelegate, SKPaymentTransactionObserver {
    
    //SKProductsRequestDelegate
    func productsRequest(_ request: SKProductsRequest, didReceive response: SKProductsResponse){
        print("Invalid product identifiers: \(response.invalidProductIdentifiers)")
        if response.products.count > 0 {
            DispatchQueue.main.async {
                self.booksForSale = response.products.map{ProductInfo(product: $0)}
                self.products = response.products
            }
        }
    }
    
    //SKPaymentTransactionObserver
    func paymentQueue(_ queue: SKPaymentQueue, updatedTransactions transactions: [SKPaymentTransaction]) {
        var numberOfFinishedTransactions = 0
        for transaction in transactions {
            switch transaction.transactionState {
            case .purchasing:
                //do nothing
                break
            case .purchased, .restored:
                //unlock the item!
                storeInKeychain(identifier: transaction.payment.productIdentifier)
                numberOfFinishedTransactions += 1
                
                SKPaymentQueue.default().finishTransaction(transaction)
                SKPaymentQueue.default().remove(self)
            case .failed, .deferred:
                SKPaymentQueue.default().finishTransaction(transaction)
                SKPaymentQueue.default().remove(self)
            @unknown default:
                SKPaymentQueue.default().finishTransaction(transaction)
                SKPaymentQueue.default().remove(self)
            }
        }
        if numberOfFinishedTransactions > 0 {finishedTransactions.toggle()}
    }
    
}

struct ProductInfo : Identifiable{
    var id : String
    var title : String = ""
    var price : String = ""
    var description : String = ""
    
    init(product : SKProduct){
        
        func formattedPrice(for product : SKProduct) -> String {
            let formatter = NumberFormatter()
            formatter.numberStyle = .currency
            formatter.locale = product.priceLocale
            return formatter.string(from: product.price) ?? "formatting error"
        }
        self.title = product.localizedTitle
        self.description = product.localizedDescription
        self.price = formattedPrice(for: product)
        self.id = product.productIdentifier
    }
}

extension OnlineStore {
    
    static let kcServiceString = "Puzzle Room"
    
    func storeInKeychain(identifier : String) {
        guard let data = identifier.data(using: .utf8) else {
            print("couldn't encode data")
            return
        }

        let query : [String : Any] = [
            kSecClass as String : kSecClassGenericPassword,
            kSecAttrService as String: Self.kcServiceString,
            kSecAttrAccount as String : identifier, //store in unique location
            kSecValueData as String : data]
        //write into keychain
        let success = SecItemAdd(query as CFDictionary, nil)
        switch success {
        case errSecSuccess:
            return
        default:
           print("couldn't write to keychain error: \(success)")
        }
    }
}

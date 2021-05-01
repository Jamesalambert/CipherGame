//
//  OnlineStore.swift
//  CipherGame
//
//  Created by J Lambert on 30/04/2021.
//

import Foundation
import StoreKit

class OnlineStore : NSObject, ObservableObject, SKPaymentTransactionObserver {

    static let shared = OnlineStore()
    
    var productIDs = ["test.mysteryIsland"]
            
    @Published
    var booksForSale : [ProductInfo] = [] {
        didSet{
            booksForSale.forEach{ book in
                print(book.title)
                print(book.description)
                print(book.price)
            }
        }
    }
    
    private
    var products = [SKProduct]()
    
    func getProducts(){
        let request = SKProductsRequest(productIdentifiers: Set(productIDs))
        request.delegate = self
        request.start()
    }

    func buyProduct(_ id : String){
        guard let product = self.products.first(where: {$0.productIdentifier == id}) else {return}
        if SKPaymentQueue.canMakePayments(){
            let payment = SKPayment(product: product)
            SKPaymentQueue.default().add(self)
            SKPaymentQueue.default().add(payment)
        }
    }
    
    func restorePurchases() {
        SKPaymentQueue.default().restoreCompletedTransactions()
    }
    
    //needed for restoring transactions?!
    func paymentQueueRestoreCompletedTransactionsFinished(_ queue: SKPaymentQueue) {}
    
    
}

extension OnlineStore : SKProductsRequestDelegate {
    
    func productsRequest(_ request: SKProductsRequest, didReceive response: SKProductsResponse){
        print("Invalid product identifiers: \(response.invalidProductIdentifiers)")
        if response.products.count > 0 {
            DispatchQueue.main.async {
                self.booksForSale = response.products.map{ProductInfo(product: $0)}
                self.products = response.products
            }
        }
    }
    
    func paymentQueue(_ queue: SKPaymentQueue, updatedTransactions transactions: [SKPaymentTransaction]) {
        for transaction in transactions {
            switch transaction.transactionState {
            
            case .purchasing:
                //do nothing
                break
            case .purchased, .restored:
                //unlock the item!
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
    }
    
    
//        switch transaction.transactionState {
//        case .purchasing:
//            break
//        case .purchased, .restored:
//            SKPaymentQueue.default().finishTransaction(transaction)
//            SKPaymentQueue.default().remove(self)
//        case .failed, .deferred:
//            SKPaymentQueue.default().finishTransaction(transaction)
//            SKPaymentQueue.default().remove(self)
//        @unknown default:
//            SKPaymentQueue.default().finishTransaction(transaction)
//            SKPaymentQueue.default().remove(self)
//        }
    
    
}

extension SKProduct : Identifiable {}

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

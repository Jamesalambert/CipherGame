//
//  UITextFieldView.swift
//  CipherGame
//
//  Created by J Lambert on 19/03/2021.
//

import SwiftUI
import UIKit


struct NewTextField : UIViewRepresentable {
    
    @Binding
    var letterGuess : Character?
            
    @Binding
    var wasTapped : Bool
    
    var textColor : UIColor?
    
    var stringToDisplay : String {
        switch capType {
        case 3:
            return letterGuess.string().uppercased()
        case 0:
            return letterGuess.string().lowercased()
        default:
            return letterGuess.string()
        }
        
    }
    
    @Binding
    var capType : Int
    
    func makeUIView(context: Context) -> UITextField {
        let v = UITextField()
        v.delegate = context.coordinator
        v.textAlignment = .center
        v.textColor = textColor
        return v
    }


    func updateUIView(_ uiView: UITextField, context: Context) {
        uiView.text = stringToDisplay
        uiView.becomeFirstResponder()
    }
    
    
    func makeCoordinator() -> Coordinator {
        Coordinator(guess: $letterGuess,
                    wasTapped: $wasTapped)
    }
    
    
    class Coordinator : NSObject, UITextFieldDelegate {
        
        var guess : Binding<Character?>
        var wasTapped : Binding<Bool>
        
        init(guess : Binding<Character?>, wasTapped : Binding<Bool>){
            self.guess = guess
            self.wasTapped = wasTapped
        }
        
        
        //MARK:- UITextFieldDelegate
        
        func textFieldShouldReturn(_ textField: UITextField) -> Bool {
            self.guess.wrappedValue = textField.text?.first
            self.wasTapped.wrappedValue = false
            textField.resignFirstResponder()
            return true
        }
        
        func textFieldShouldEndEditing(_ textField: UITextField) -> Bool {
            self.wasTapped.wrappedValue = false
            return true
        }
        
        func textFieldDidEndEditing(_ textField: UITextField, reason: UITextField.DidEndEditingReason) {
            //record index
            textField.removeFromSuperview()
        }
        
        func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
            self.guess.wrappedValue = string.first
            return true
        }
       


        
    }
    
}

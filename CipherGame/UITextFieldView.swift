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
    
    var ciphertextLetter : Character
    
    var puzzleTitle : String?
    
    @Binding
    var wasTapped : Bool
    
    var textColor : UIColor?
    
    var stringToDisplay : String {
        return letterGuess.string()
    }
    
    @Binding
    var allCaps : Bool
    
    func makeUIView(context: Context) -> UITextField {
        let v = UITextField()
        v.delegate = context.coordinator
        v.textAlignment = .center
        v.autocapitalizationType = allCaps ? .allCharacters : .none
        v.textColor = textColor
        return v
    }


    func updateUIView(_ uiView: UITextField, context: Context) {
        uiView.text = stringToDisplay
        uiView.autocapitalizationType = allCaps ? .allCharacters : .none
        uiView.becomeFirstResponder()
    }
    
    
    func makeCoordinator() -> Coordinator {
        Coordinator(ciphertextLetter: ciphertextLetter,
                    guess: $letterGuess,
                    puzzleTitle: puzzleTitle!,
                    wasTapped: $wasTapped)
    }
    
    
    class Coordinator : NSObject, UITextFieldDelegate {
        
        var guess : Binding<Character?>
        var ciphertextLetter : Character
        var puzzleTitle : String
        var wasTapped : Binding<Bool>
        
        init(ciphertextLetter: Character, guess : Binding<Character?>,
             puzzleTitle : String, wasTapped : Binding<Bool>){
            
            self.ciphertextLetter = ciphertextLetter
            self.guess = guess
            self.puzzleTitle = puzzleTitle
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

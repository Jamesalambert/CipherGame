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
    
    @Binding
    var puzzleTitle : String?
    
    @Binding
    var wasTapped : Bool
    
    var stringToDisplay : String {
        guard let letterGuess = letterGuess else {return ""}

        return String(letterGuess)
    }
    
    func makeUIView(context: Context) -> UITextField {
        let v = UITextField()
        v.delegate = context.coordinator
        v.textAlignment = .center
        v.autocapitalizationType = .none
        v.backgroundColor = UIColor.red
        return v
    }


    func updateUIView(_ uiView: UITextField, context: Context) {
        uiView.text = stringToDisplay
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
        
        func textFieldShouldReturn(_ textField: UITextField) -> Bool {
            //print("should return \(String(describing: textField.text))")

            self.guess.wrappedValue = textField.text?.first
            self.wasTapped.wrappedValue = false
            textField.resignFirstResponder()
            return true
        }
        
        func textFieldShouldEndEditing(_ textField: UITextField) -> Bool {
            //print("did end \(String(describing: textField.text))")
//            self.guess.wrappedValue = textField.text?.first
            textField.removeFromSuperview()
            self.wasTapped.wrappedValue = false

            return true
        }
        
        func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
            self.guess.wrappedValue = string.first
            return true
        }
       


        
    }
    
}

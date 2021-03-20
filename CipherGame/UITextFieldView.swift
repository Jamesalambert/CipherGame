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
    
    
    func makeUIView(context: Context) -> UITextField {
        let v = UITextField()
        v.delegate = context.coordinator
        return v
    }


    func updateUIView(_ uiView: UITextField, context: Context) {
        uiView.text = ""//String(letterGuess.1)
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
        
        
        init(ciphertextLetter: Character,
             guess : Binding<Character?>,
             puzzleTitle : String,
        wasTapped : Binding<Bool>){
            
            self.ciphertextLetter = ciphertextLetter
            self.guess = guess
            self.puzzleTitle = puzzleTitle
            self.wasTapped = wasTapped
        }
        
        func textFieldShouldReturn(_ textField: UITextField) -> Bool {

            print("end Edit")
            
            self.guess.wrappedValue = textField.text?.first
            
            self.wasTapped.wrappedValue = false
            return true
        }
        
        func textFieldDidEndEditing(_ textField: UITextField) {
            
        }
        
        
    }
    
}

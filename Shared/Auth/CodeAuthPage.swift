//
//  NumberAuthPage.swift
//  zimmerFive
//
//  Created by John Sorensen on 1/3/22.
//

import SwiftUI
import Combine


struct EnterCode: View {
    @EnvironmentObject var firebaseAuthManager: FirebaseAuthManager
    
    func getDigitAtIndex(index: Int, code: String) -> String? {
        if index < code.count {
            return code[index]
        }
        return nil
    }
    
    func addChar(char: String) {
        if firebaseAuthManager.code.count < 6 {
            firebaseAuthManager.code.append(char)
        }
        
        if firebaseAuthManager.code.count == 6 {
            withAnimation(.linear(duration: 0.3)) {
                firebaseAuthManager.showCodeSubmit = true
            }
        }
    }
    
    func deleteChar() {
        if firebaseAuthManager.code.count > 0 {
            firebaseAuthManager.code.removeLast()
        }
        
        if firebaseAuthManager.code.count == 5 {
            withAnimation(.linear(duration: 0.3)) {
                firebaseAuthManager.showCodeSubmit = false
            }
        }
    }
    
    
    
    var body: some View {
        ZStack {
            GeometryReader { geo in
                VStack {
                    
                    AuthImage(size: geo.size.width - 225)
                    
                    
                    Spacer()
                    
                    PhoneAuthTitleText(text: "Enter Code")
                    
                    Button {
                        firebaseAuthManager.sendMessage()
                    } label: {
                        VStack {
                            PhoneAuthSubtitleText(text: "Didn't receive the code?")
                            PhoneAuthSubtitleText(text: "Tap here and we'll send another one")
                        }
                    }
                    
                    DisplayCode(code: $firebaseAuthManager.code, getDigit: getDigitAtIndex)

                    
                    if let errorMessage = firebaseAuthManager.errorMessage {
                        ErrorMessage(text: errorMessage)
                    }
                    
                    if firebaseAuthManager.showCodeSubmit {
                        Button {
                            Task { await firebaseAuthManager.verifyCode() }
                        } label: {
                            SubmitButtonText(text: "Verify")
                                
                        }
                    }
                    
                    Spacer()
                    
                    ZStack {
                        NumberPadBackground()
                        NumberPad(addCharFunction: addChar, deleteCharFunction: deleteChar)
                    }
                    .frame(height: geo.size.height / 2.75)
                }
                .onAppear {
                    print("Code View Appeared")
                }
            }
            
            if firebaseAuthManager.isLoading {
                TaskLoadingView()
            }
        }
    }
}

struct DisplayCode: View {
    @Binding var code: String
    var getDigit: (Int, String) -> String?
    var body: some View {
        HStack {
            ForEach(0..<6, id: \.self) { index in
                let digit = getDigit(index, code)
                ZStack {
                    Circle()
                        .fill(COLORS.GRAY)
                        .frame(maxWidth: .infinity)
                    
                    if let digit = digit {
                        Text(digit)
                            .font(.system(size: 30, weight: .medium))
                    }
                }
            }
        }
        .frame(height: 80)
        .padding(.horizontal, 20)
    }
}

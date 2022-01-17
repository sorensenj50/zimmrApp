//
//  PhoneAuthView.swift
//  zimmerFive
//
//  Created by John Sorensen on 1/2/22.
//

import SwiftUI


struct EnterPhone: View {
    let isCreatingAccount: Bool
    @EnvironmentObject var firebaseAuthManager: FirebaseAuthManager
    
    func getFormattedText(phoneNumber: String) -> String {
        if phoneNumber.count > 3 {
            let firstThree = phoneNumber.prefix(3)
            let index = phoneNumber.index(phoneNumber.startIndex, offsetBy: 3)
            var rest = String(phoneNumber[index...])
    
            if phoneNumber.count > 7 {
                let lastIndex = rest.index(rest.startIndex, offsetBy: 3)
                let firstSection = "(" + firstThree + ")"
                rest.insert("-", at: lastIndex)
                return firstSection + " " + rest
            } else {
                return firstThree + "-" + rest
            }
        } else {
            return phoneNumber
        }
    }
    
    func addChar(char: String) {
        if firebaseAuthManager.phoneNumber.count < 10 {
            firebaseAuthManager.phoneNumber.append(char)
        }
        
        if firebaseAuthManager.phoneNumber.count == 10 {
            withAnimation(.linear(duration: 0.3)) {
                firebaseAuthManager.showPhoneSubmit = true
            }
        }
    }
    
    func deleteChar() {
        if firebaseAuthManager.phoneNumber.count > 0 {
            firebaseAuthManager.phoneNumber.removeLast()
        }
        
        if firebaseAuthManager.phoneNumber.count == 9 {
            withAnimation(.linear(duration: 0.3)) {
                firebaseAuthManager.showPhoneSubmit = false
            }
        }
    }
    
    var body: some View {
        GeometryReader { geo in
            VStack {
                AuthImage(size: geo.size.width - 225)
                
                Spacer()
                
                PhoneAuthTitleText(text: "Enter Phone Number")
                EmptySubtitle(text: "Enter your phone number and we'll send you a temporary code")
                    .padding(.bottom, 15)
                
                DisplayPhoneNumber(phoneNumber: $firebaseAuthManager.phoneNumber, formattingFunc: getFormattedText)
                
                if let errorMessage = firebaseAuthManager.errorMessage {
                    ErrorMessage(text: errorMessage)
                }

                if firebaseAuthManager.showPhoneSubmit {
                    Button {
                        firebaseAuthManager.sendMessage()
                    } label: {
                        SubmitButtonText(text: "Next")
                    }
                }
                
                Spacer()
                
                ZStack {
                    NumberPadBackground()
                    NumberPad(addCharFunction: addChar, deleteCharFunction: deleteChar)
                }
                .frame(height: geo.size.height / 2.75)
                
                
                NavigationLink(destination: EnterCode(), isActive: $firebaseAuthManager.phoneSuccess) { EmptyView() }
            }
        }
        .onAppear {
            UserDefaults.standard.set("notYetChecked", forKey: "needsSetUp")
        }
    }
}

struct DisplayPhoneNumber: View {
    @Binding var phoneNumber: String
    var formattingFunc: (String) -> String
    
    var body: some View {
        HStack {
            Spacer()
            if phoneNumber.count == 0 {
                Text("Phone Number...")
                    .foregroundColor(.gray)
                
            } else {
                let formatted = formattingFunc(phoneNumber)
                Text(formatted.count == 0 ? phoneNumber[0]: formatted)
                    .foregroundColor(.black)
                    .font(.system(size: 30, weight: .medium))

            }
            
            Spacer()
            
        }
        .frame(height: 60)
        .background(COLORS.GRAY)
        .cornerRadius(50)
        .padding(.horizontal, 20)
    }
}




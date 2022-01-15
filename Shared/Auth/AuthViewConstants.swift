//
//  Numberpad.swift
//  zimmerFive
//
//  Created by John Sorensen on 1/2/22.
//

import SwiftUI

struct SubmitButtonText: View {
    let text: String
    var body: some View {
        Text(text)
            .font(.system(size: 22, weight: .medium))
            .foregroundColor(COLORS.SECONDARY)
    }
}

struct ErrorMessage: View {
    let text: String
    var body: some View {
        Text(text)
            .font(.system(size: 16, weight: .medium))
            .foregroundColor(.red)
            .padding(.bottom, 5)
    }
}

struct NumberPadDeleteButton: View {
    var deleteCharButton: () -> Void
    var body: some View {
        Button {
            deleteCharButton()
        } label: {
            ZStack {
                Color.white
                Image(systemName: "delete.left")
                    .font(.system(size: 30, weight: .medium))
                    .foregroundColor(.black)
                    
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .clipShape(RoundedRectangle(cornerRadius: 10))
        }
    }
}


struct NumberPadButton: View {
    var addCharFunction: (String) -> Void
    let char: String
    var body: some View {
        Button {
            addCharFunction(char)
        } label: {
            ZStack {
                Color.white
                Text(char)
                    .font(.system(size: 30, weight: .medium))
                    .foregroundColor(.black)
                    
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .clipShape(RoundedRectangle(cornerRadius: 10))
        }
    }
}

struct NumberPad: View {
    var addCharFunction: (String) -> Void
    var deleteCharFunction: () -> Void
    
    var body: some View {
        VStack(spacing: 10) {
            Rectangle()
                .opacity(0)
                .frame(height: 20)
            
            HStack(spacing: 15) {
                NumberPadButton(addCharFunction: addCharFunction, char: "1")
                NumberPadButton(addCharFunction: addCharFunction, char: "2")
                NumberPadButton(addCharFunction: addCharFunction, char: "3")
            }
            
            HStack(spacing: 15) {
                NumberPadButton(addCharFunction: addCharFunction, char: "4")
                NumberPadButton(addCharFunction: addCharFunction, char: "5")
                NumberPadButton(addCharFunction: addCharFunction, char: "6")
            }
            
            HStack(spacing: 15) {
                NumberPadButton(addCharFunction: addCharFunction, char: "7")
                NumberPadButton(addCharFunction: addCharFunction, char: "8")
                NumberPadButton(addCharFunction: addCharFunction, char: "9")
            }
                
            HStack(spacing: 15) {
                Rectangle()
                    .opacity(0)
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                
                NumberPadButton(addCharFunction: addCharFunction, char: "0")
                NumberPadDeleteButton(deleteCharButton: deleteCharFunction)
            }
                
        }
        .padding(.horizontal, 20)
        
    }
}

struct AuthRectangle: View {
    let string: String
    let color: Color

    var body: some View {
        RoundedRectangle(cornerRadius: 25)
            .stroke(color, lineWidth: 3)
            .frame(height: 50)
            .overlay(Text(string)
                        .foregroundColor(color)
                        .font(.system(size: 23))
                        .fontWeight(.semibold))

    }
}


struct NumberPadBackground: View {
    let height: CGFloat = 100
    var body: some View {
        ZStack {
            VStack {
                RoundedRectangle(cornerRadius: height / 2)
                    .frame(height: height)
                    .foregroundColor(COLORS.GRAY)
                
                Text("")
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .background(COLORS.GRAY)
            }
    
            
            
            VStack {
                Rectangle()
                    .opacity(0)
                    .frame(height: height / 2)
                
                Rectangle()
                    .frame(height: height / 2)
                    .foregroundColor(COLORS.GRAY)
                
                Rectangle()
                    .opacity(0)
                    .frame(maxHeight: .infinity)
            
            }
        }
    }
}

struct PhoneAuthTitleText: View {
    let text: String
    var body: some View {
        Text(text)
            .font(.system(size: 23, weight: .medium))
            .padding(.bottom, 5)
    }
}

struct PhoneAuthSubtitleText: View {
    let text: String
    var body: some View {
        Text(text)
            .font(.system(size: 16, weight: .light))
            .foregroundColor(.gray)
    }
}



struct AuthImage: View {
    let size: CGFloat
    var body: some View {
        Rectangle()
            .fill(LinearGradient(colors: [COLORS.PRIMARY, COLORS.SECONDARY], startPoint: .topLeading, endPoint: .bottomTrailing))
            .frame(width: size, height: size)
            .mask(
                Image(systemName: "bubble.left")
                    .resizable()
                    .scaledToFit()
                    .frame(width: size, height: size)
                

            )
    }
}

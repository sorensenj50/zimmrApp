//
//  GroupImageComponents.swift
//  zimmerFive
//
//  Created by John Sorensen on 1/5/22.
//

import SwiftUI


struct GroupImageDecider: View {
    static let cornerSize: CGFloat = 10
    
    let imageID: String
    let size: CGFloat
    
    var body: some View {
        if let image = Cache.instance.getImage(name: imageID) {
            ValidGroupImage(image: image, size: size)
        } else {
            GroupPlaceHolderImage(size: size)
        }
    }
}

struct ValidGroupImage: View {
    let image: UIImage
    let size: CGFloat
    
    var body: some View {
        Image(uiImage: image)
            .resizable()
            .scaledToFill()
            .frame(width: size, height: size)
            .clipShape(RoundedRectangle(cornerRadius: GroupImageDecider.cornerSize))
    }
}


struct GroupPlaceHolderImage: View {
    let size: CGFloat
    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: GroupImageDecider.cornerSize)
                .fill(.gray)
            Image(systemName: "person.3.fill")
                .resizable()
                .scaledToFit()
                .padding(7)
                .foregroundColor(.white)
                
        }
        .frame(width: size, height: size)
    }
}




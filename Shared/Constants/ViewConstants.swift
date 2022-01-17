//
//  ViewConstants.swift
//  zimmerFive
//
//  Created by John Sorensen on 1/3/22.
//

import Foundation
import SwiftUI

struct COLORS {
    static let PRIMARY = Color.blue
    static let SECONDARY = Color.green
    static let GRAY = Color.init(white: 0.9)
    static let LIGHT_GRAY = Color.init(white: 0.95)

}

struct TaskLoadingView: View {
    var body: some View {
        ProgressView()
            .scaleEffect(1.5)
    }
}

struct HexagonConstant {
    static let ratio: CGFloat =  0.8660254
}

struct VERSION {
    static let num = "v1.0"
}

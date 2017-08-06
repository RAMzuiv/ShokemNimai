//
//  Extensions.swift
//  RoyalGame
//
//  Created by Mikkel on 6/1/17.
//  Copyright © 2017 Mikkel Wilson. All rights reserved.
//

import Foundation
import SpriteKit

extension SKColor {
    convenience init(_ red: CGFloat, _ green: CGFloat, _ blue: CGFloat) {
        self.init(red: red, green: green, blue: blue, alpha: 1)
    }
}

precedencegroup PowerPrecedence {higherThan: MultiplicationPrecedence}
infix operator ^^: PowerPrecedence
func ^^ (radix: Float, power: Int) -> Float {
    return Float(pow(Double(radix), Double(power)))
}

func randFloat() -> CGFloat {
    return CGFloat(arc4random())/CGFloat(UINT32_MAX)
}

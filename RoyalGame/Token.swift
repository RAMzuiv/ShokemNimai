//
//  Token.swift
//  RoyalGame
//
//  Created by Mikkel on 5/16/17.
//  Copyright © 2017 Mikkel Wilson. All rights reserved.
//

import SpriteKit

class Token: CustomStringConvertible, Hashable {
    var position: Int
    let player: Int
    let tokenType: Int
    var sprite: SKSpriteNode?
    
    init(pos: Int, player: Int, type: Int = 0){
        position = pos
        self.player = player
        tokenType = type
    }
    
    var description: String {
        return "Token at \(position) for player \(player)"
    }
    
    var hashValue: Int {
        return position+player*20+20
    }
    
    var spriteName: String {
        switch tokenType {
        case 1: return "token P\(player) peasant"
        case 2: return "token P\(player) star"
        case 3: return "token P\(player) cross"
        case 4: return "token P\(player) hex"
        case 5: return "token P\(player) wave"
        case 6: return "token P\(player) hacker"
        //case 7: return "token P\(player) glider"
        case 8: return "token P\(player) octostar"
        case 9: return "token P\(player) yin"
        default: return "token P\(player)"
        }
    }
}

func ==(lhs: Token, rhs: Token) -> Bool {
    let equal = ((lhs.position == rhs.position) && (lhs.player == rhs.player || (lhs.position > 4 && lhs.position < 13) || lhs.position == 15))
    return equal
}

func ==(lhs: Token, rhs: Int) -> Bool {
    return lhs.position == rhs
}

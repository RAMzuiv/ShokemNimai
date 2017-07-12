//
//  Token.swift
//  RoyalGame
//
//  Created by Mikkel on 5/16/17.
//  Copyright © 2017 Mikkel Wilson. All rights reserved.
//

import SpriteKit

enum TokenType: Int, CustomStringConvertible {
    case unknown = 0, general, peasant, priest, dancer, siege, knight, jester
    
    var description: String {
        switch self {
        case .general: return "1"
        case .peasant: return "2"
        case .priest: return "3"
        case .dancer: return "4"
        case .siege: return "5"
        case .knight: return "6"
        case .jester: return "7"
        default: return "Unknown"
        }
    }
}

class Token: CustomStringConvertible, Hashable {
    var position: Int
    let player: Int
    let tokenType: TokenType
    var sprite: SKSpriteNode?
    
    init(pos: Int, player: Int, type: TokenType = .unknown){
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
        case .peasant: return "token P\(player) peasant"
        case .general: return "token P\(player) star"
        case .priest: return "token P\(player) cross"
        case .jester: return "token P\(player) hex"
        case .dancer: return "token P\(player) wave"
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

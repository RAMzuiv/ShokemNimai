//
//  Move.swift
//  RoyalGame
//
//  Created by Mikkel on 5/23/17.
//  Copyright © 2017 Mikkel Wilson. All rights reserved.
//

import Foundation

enum MoveType: Int {
    case add, move, remove, capture
}

class Move: CustomStringConvertible, Hashable {
    var type: MoveType
    var startPos: Int // Position of token to be moved for a .move .capture or .remove, or position to add token for .add
    var doubleMove: Bool
    
    init(at pos: Int, type: MoveType, doubleMove: Bool = false){
        self.type = type
        startPos = pos
        self.doubleMove = doubleMove
    }
    
    var hashValue: Int {
        return startPos
    }
    
    var description: String {
        return "\(type) at \(startPos)"
    }
}

func ==(lhs: Move, rhs: Move) -> Bool {
    return lhs.startPos == rhs.startPos && ((lhs.type == .add) == (rhs.type == .add))
}

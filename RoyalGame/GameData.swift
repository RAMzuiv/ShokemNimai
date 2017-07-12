//
//  GameData.swift
//  RoyalGame
//
//  Created by Mikkel on 5/18/17.
//  Copyright © 2017 Mikkel Wilson. All rights reserved.
//

import Foundation
import SpriteKit

class GameData {
    var scene: GameScene!
    //let view: SKView!
    let Controller: GameViewController!
    var tokens: [Token]!
    var activePlayer = 1 // 1 for P1, 2 for P2
    var jump = 0
    var legalMoves = Set<Move>()
    var tokenStock = [7,7]
    var diceState = [false, false, false, false]
    var gameOver = false
    //var availableTypes = [[TokenType]](repeating: [.general, .peasant, .priest, .dancer, .siege, .knight, .jester], count: 2)
    var availableTypes = [Set<TokenType>](repeating: [.general, .peasant, .priest, .dancer, .siege, .knight, .jester], count: 2)
    let rosettes = [4, 9, 14]
    var moveNum = 0
    var addMove: Move?
    
    func executeMove(at pos: Int, side: Int) { // 1 for P1 side, 2 for P2 side, 0 for middle
        if gameOver {return} // Don't do anything if in a gameover state
        /* // Used for debugging the gameover screen
        if side == 1 {
            gameover(1)
        } else if side == 2 {
            gameover(2)
        }
        */
        
        scan: if legalMoves.count == 0 {
            nextTurn() // if there are no legal moves, skip the player's turn
        } else if side == activePlayer || side == 0 { // only process the input if it is on the active player's side or in the middle
            for move in legalMoves {
                if move.startPos == pos {
                    switch move.type {
                    case .move:
                        tokenAt(at: pos, side: side)!.position += jump
                    case .add:
                        createToken(at: pos, player: activePlayer)
                        tokenStock[activePlayer-1]-=1 // Take the token out of the player's stock
                    case .capture:
                        availableTypes[2-activePlayer].insert(tokenAt(at: pos + jump, side: 2 - activePlayer)!.tokenType)
                        removeToken(at: pos + jump, player: activePlayer^3) // Remove a token that belongs to the other player at the new position
                        tokenAt(at: pos, side: side)!.position += jump
                        tokenStock[2-activePlayer]+=1 // Add the token back to the other player's stock
                    case .remove:
                        removeToken(at: pos, player: activePlayer) // Remove the token from the board. Do not add it back to stock, since it is no longer in play
                    }
                    if move.doubleMove{
                        nextTurn(doubleMove: true) // If the move lands on a rosetta (the thunderbolt or the safe spot), they can move again
                    } else {
                        nextTurn()
                    }
                    moveNum += 1
                    //print(moveNum)
                    break scan // if a move is matched, ignore the rest of the moves
                }
            }
            // If we have reached this point, there is no valid move
            scene.invalidMove()
        } else {
            scene.invalidMove()
        }
    }
    
    func typeForMove(at pos: Int, side: Int) -> MoveType? { // return nil if not a legal move, else return move type
        if legalMoves.count == 0 {
            nextTurn() // if there are no legal moves, skip the turn
            return nil
        } else if side == activePlayer || side == 0 { // only process the input if it is on the active player's side or in the middle
            for move in legalMoves {
                if move.startPos == pos {
                    return move.type
                    //break scan // if a move is matched, ignore the rest of the moves
                }
            }
            // If we have reached this point, there is no valid move
            scene.invalidMove()
            return nil
        } else {
            scene.invalidMove()
            return nil
        }
    }
    
    func nextTurn(doubleMove: Bool = false) {
        let playerWin = hasPlayerWon() // 0 if nobody has won, 1 for P1, and 2 for P2
        if playerWin != 0 {
            gameover(playerWin)
        } else {
            if !doubleMove {
                activePlayer = activePlayer ^ 3 // Bitwise xor with 0b0011 - so 1 becomes 2 and vice-versa, switching the active player
            }
            rollDice() // Set jump to a new random number
            scanMoves() // See if player has any possible moves
        
            scene.updateScreen()
        }
    }
    
    func gameover(_ winner: Int) {
        /*
        switch winner {
        case 1: print("Red wins")
        case 2: print("Green wins")
        default: print("Invalid victory state")
        }
        */
        gameOver = true
        Controller.winScreen(winner: winner)
    }
    
    func hasPlayerWon() -> Int {
        var P1Empty = true
        var P2Empty = true
        for token in tokens { // Check to see if each player has any tokens on the board
            if token.player == 1 {
                P1Empty = false
            }
            if token.player == 2 {
                P2Empty = false
            }
        }
        if P1Empty && tokenStock[0] == 0 { // If P1 has no tokens on the board or in stock, they win
            return 1
        } else if P2Empty && tokenStock[1] == 0 { // If P2 has no tokens, they win
            return 2
        } else {
            return 0 // Return 0 if nobody has won yet
        }
    }
    
    func createToken(at pos: Int, player: Int) {
        var tokenType: TokenType!
        repeat {
            let tokenNum = arc4random_uniform(7)
            switch tokenNum {
            case 0: tokenType = .general
            case 1: tokenType = .peasant
            case 2: tokenType = .priest
            case 3: tokenType = .dancer
            case 4: tokenType = .siege
            case 5: tokenType = .knight
            case 6: tokenType = .jester
            default: fatalError("createToken() random error") //tokenType = .unknown
            }
        } while (!availableTypes[player-1].contains(tokenType))
        availableTypes[player-1].remove(tokenType)
        let token = Token(pos: pos, player: player, type: tokenType)
        tokens.append(token)
    }
    
    func scanMoves() {
        //Check to see if the player has any possible moves
        addMove = nil // Initialize to nil, if an add move is encountered, set to that move
        legalMoves = Set<Move>()
        for token in tokens {
            // Make sure the token belongs to the player who is active - otherwise it can't be moved
            if token.player == activePlayer {
                let jumpPos = token.position+jump
                if let jumpToken = tokenAt(at: jumpPos, side: activePlayer) { // There is another token where the token can move
                    if jumpToken.player == activePlayer { // The tokens belong to the same player - so it can't be moved
                        //print("\(token) has no legal moves")
                    } else { // The token belongs to the other player, so it can be captured
                        if !rosettes.contains(jumpPos) { // Capture is prohibited on the rosetta
                            legalMoves.insert(Move(at: token.position, type: .capture))
                        }
                    }
                } else { // There is no token at the token's destination
                    if jumpPos > 14 {
                        legalMoves.insert(Move(at: token.position, type: .remove)) //The move will take the token off the board, so it must be removed
                    } else {
                        if rosettes.contains(jumpPos) {
                            legalMoves.insert(Move(at: token.position, type: .move, doubleMove: true)) // The move will land on a rosette, so it gets an extra turn
                        } else {
                            legalMoves.insert(Move(at: token.position, type: .move))
                        }
                    }
                }
            }
        }
        if tokenAt(at: jump, side: activePlayer) == nil && jump != 0 {
            if tokenStock[activePlayer-1]>0 {
                if !rosettes.contains(jump) {
                    let move = Move(at: jump, type: .add)
                    //legalMoves.insert(Move(at: jump, type: .add))
                    legalMoves.insert(move)
                    addMove = move
                } else { //Double moves on the rosetta
                    let move = Move(at: jump, type: .add, doubleMove: true)
                    //legalMoves.insert(Move(at: jump, type: .add, doubleMove: true))
                    legalMoves.insert(move)
                    addMove = move
                }
            }
        }
        //print(legalMoves)
    }
    
    func rollDice() {
        var zero: Bool
        var openingFour: Bool
        var openingDouble: Bool
        repeat {
            var sum = 0
            for i in 0..<4 {
                if arc4random_uniform(2) == 0{
                    sum += 1
                    diceState[i]=true
                }
                else {
                    diceState[i]=false
                }
            }
            jump = sum
            zero = (jump == 0) // Don't let a zero get rolled
            openingFour = (jump == 4 && moveNum < 2) // Don't let the player get a double on their first turn
            openingDouble = ((tokenAt(at: jump, side: activePlayer) != nil) && moveNum < 4) // Don't let the player move their only token on the second turn
        } while openingFour || zero || openingDouble // Re-roll the dice if we get a 0 or 4 on the player's first move
    }
    
    func printState() {
        print("P1 Stock: \(tokenStock[0]); P2 Stock: \(tokenStock[1])")
    }
    
    func playerName(_ player: Int) -> String {
        switch player {
        case 1: return("Red")
        case 2: return("Green")
        default: return("Invalid player")
        }
    }
    
    func tokenAt(at pos: Int, side: Int) -> Token? {
        let testToken = Token(pos: pos, player: side)
        for token in tokens {
            if testToken == token {return token}
        }
        return nil
    }
    
    func removeToken(at pos: Int, player: Int) {
        for i in 0..<tokens.count {
            let token = tokens[i]
            if token.position == pos && token.player == player {
                scene.removeToken(token)
                tokens.remove(at: i)
                return
            }
        }
    }
    
    func newGame(){
        if tokens != nil {
            for token in tokens {
                scene.removeToken(token)
            }
        }
        availableTypes = [Set<TokenType>](repeating: [.general, .peasant, .priest, .dancer, .siege, .knight, .jester], count: 2)
        moveNum = 0
        gameOver = false
        activePlayer = 1
        tokenStock = [7,7]
        tokens = []
        rollDice()
        scanMoves()
        scene.updateScreen()
    }
    
    init(controller: GameViewController) {
        self.Controller = controller
        //self.view = view
    }
}
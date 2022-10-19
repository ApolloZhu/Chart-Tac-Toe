//
//  TicTacToe.swift
//  Chart-Tac-Toe
//
//  Created by Apollo Zhu on 7/17/22.
//

import Combine

final class TicTacToe: ObservableObject {
  @Published
  private(set) var moves: [Move] = []
  @Published
  private(set) var state: State = .playing(nextMoveBy: .first)
  @Published
  private(set) var board: [[Player?]] = .emptyBoard
  
  func reset() {
    moves = []
    state = .playing(nextMoveBy: .first)
    board = .emptyBoard
  }
  
  var winner: Player? {
    switch state {
    case .won(winner: let winner): return winner
    case .playing, .draw: return nil
    }
  }
  
  var ended: Bool {
    switch state {
    case .playing: return false
    case .won, .draw: return true
    }
  }
  
  enum State {
    case playing(nextMoveBy: Player)
    case won(winner: Player)
    case draw
  }
  
  enum InvalidMove: Error {
    case gameEnded(winner: Player?)
    case occupied
    case outOfBounds
  }
  
  func place(atX x: Int, y: Int) throws {
    switch state {
    case .playing(nextMoveBy: let player):
      guard (0...2).contains(x) && (0...2).contains(y) else {
        throw InvalidMove.outOfBounds
      }
      guard board[x][y] == nil else {
        throw InvalidMove.occupied
      }
      board[x][y] = player
      moves.append(Move(x: x + 1, y: y + 1, player: player))
      
      // there's a better algorithm but good enough
      if board[x].allSatisfy({ $0 == player }) {
        state = .won(winner: player)
        return
      }
      if board[0][y] == player,
         board[1][y] == player,
         board[2][y] == player {
        state = .won(winner: player)
        return
      }
      if x == y,
         board[0][0] == player,
         board[1][1] == player,
         board[2][2] == player {
        state = .won(winner: player)
        return
      }
      if x + y == 2,
         board[0][2] == player,
         board[1][1] == player,
         board[2][0] == player {
        state = .won(winner: player)
        return
      }
      
      if moves.count == 9 {
        state = .draw
        return
      }
      
      switch player {
      case .first:
        state = .playing(nextMoveBy: .second)
      case .second:
        state = .playing(nextMoveBy: .first)
      }
    case .won(winner: let winner):
      throw InvalidMove.gameEnded(winner: winner)
    case .draw:
      throw InvalidMove.gameEnded(winner: nil)
    }
  }
}

extension [[Player?]] {
    fileprivate static let emptyBoard = Self(
      repeating: [Player?](repeating: nil, count: 3),
      count: 3
    )
}

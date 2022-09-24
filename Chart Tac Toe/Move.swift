//
//  Move.swift
//  Chart Tac Toe
//
//  Created by Apollo Zhu on 7/16/22.
//

struct Move: Identifiable {
  /// range: 1...3
  let x: Int
  /// range: 1...3
  let y: Int
  let player: Player
  
  var id: Int {
    // not a very general hash function but should be unique and consistent
    x * 100 + y * 10 + player.id
  }
}

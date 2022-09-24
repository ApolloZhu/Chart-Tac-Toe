//
//  Player.swift
//  Chart Tac Toe
//
//  Created by Apollo Zhu on 7/16/22.
//

enum Player: Identifiable, CaseIterable {
  case first
  case second
  
  var id: Int {
    switch self {
    case .first: return 1
    case .second: return 2
    }
  }
  
  var localizedDescription: String {
    switch self {
    case .first: return String(localized: "First Player")
    case .second: return String(localized: "Second Player")
    }
  }
}

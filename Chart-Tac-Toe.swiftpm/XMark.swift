//
//  XMark.swift
//  Chart-Tac-Toe
//
//  Created by Apollo Zhu on 7/16/22.
//

import SwiftUI
import Charts

struct XMark: ChartSymbolShape, InsettableShape {
  private let inset: CGFloat
  
  init(insetBy amount: CGFloat = 0) {
    self.inset = amount
  }
  
  func inset(by amount: CGFloat) -> some InsettableShape {
    XMark(insetBy: inset + amount)
  }
  
  func path(in rect: CGRect) -> Path {
    var path = Path()
    path.move(to: CGPoint(x: rect.minX + inset, y: rect.minY + inset))
    path.addLine(to: CGPoint(x: rect.maxX - inset, y: rect.maxY - inset))
    path.move(to: CGPoint(x: rect.minX + inset, y: rect.maxY - inset))
    path.addLine(to: CGPoint(x: rect.maxX - inset, y: rect.minY + inset))
    return path
  }
  
  var perceptualUnitRect: CGRect {
    CGRect(x: 0, y: 0, width: 1, height: 1)
  }
}

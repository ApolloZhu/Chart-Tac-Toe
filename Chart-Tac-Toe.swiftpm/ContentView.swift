//
//  ContentView.swift
//  Chart-Tac-Toe
//
//  Created by Apollo Zhu on 7/16/22.
//

import SwiftUI
import Charts

struct ContentView: View {
  @StateObject
  private var game = TicTacToe()
  private let lineWidth: CGFloat = 10
  
  var ticTacToe: some View {
    GeometryReader { geometry in
      // MARK: - Moves
      Chart {
        ForEach(game.moves) { move in
          PointMark(
            x: .value("Column", move.x),
            y: .value("Row", move.y)
          )
          .foregroundStyle(by: .value("Player", move.player.localizedDescription))
          .symbol(by: .value("Player", move.player.localizedDescription))
          // Note that although axis marks for 0 and 3 are not shown,
          // each of those get half of the normal grid line width.
          .symbolSize(CGSize(
            width: (geometry.size.width - 3 * lineWidth) / 3 * 0.8,
            height: (geometry.size.height - 3 * lineWidth) / 3 * 0.8)
          )
          .offset(x: -geometry.size.width / 6,
                  y: geometry.size.height / 6)
        }
      }
      .chartSymbolScale([
        Player.first.localizedDescription:
          Circle().strokeBorder(lineWidth: lineWidth),
        Player.second.localizedDescription:
          XMark().strokeBorder(style: .init(lineWidth: lineWidth,
                                            lineCap: .round)),
      ])
      .chartLegend(.hidden)
      // MARK: - Grids
      .chartXScale(domain: 0...3)
      .chartYScale(domain: 0...3)
      .chartXAxis {
        AxisMarks(values: [1, 2]) { _ in
          AxisGridLine(stroke: StrokeStyle(lineWidth: lineWidth))
        }
      }
      .chartYAxis {
        AxisMarks(values: [1, 2]) { _ in
          AxisGridLine(stroke: StrokeStyle(lineWidth: lineWidth))
        }
      }
      // MARK: - User Interactions
      .chartOverlay { chart in
        Color.clear
          .contentShape(Rectangle())
          .onTapGesture { location in
            if let (rawX, rawY): (Double, Double) = chart.value(at: location) {
              let x = min(max(0, Int(rawX)), 2)
              let y = min(max(0, Int(rawY)), 2)
              place(atX: x, y: y)
            }
          }
      }
      .disabled(game.ended)
      .chartPlotStyle { chart in
        chart
          .background(game.winner?.color.opacity(0.15))
      }
    }
    // MARK: - Make Square
    .aspectRatio(1, contentMode: .fit)
    .frame(minWidth: 100, minHeight: 100)
    // MARK: - Accessibility
    .accessibilityRepresentation {
      accessibilityRepresentation
    }
  }
  
  private var accessibilityRepresentation: some View {
    VStack(spacing: 0) {
      ForEach((0...2).reversed(), id: \.self) { y in
        HStack(spacing: 0) {
          ForEach(0...2, id: \.self) { x in
            Button {
              place(atX: x, y: y)
            } label: {
              Text(
                game.board[x][y] == nil
                   ? "empty"
                   : "move by \(game.board[x][y]!.localizedDescription)"
              )
              .contentShape(Rectangle())
              .frame(maxWidth: .infinity, maxHeight: .infinity)
            }
            .buttonStyle(.plain)
            .accessibilityValue("row \(y), column \(x)")
            .disabled(game.board[x][y] != nil || game.ended)
          }
        }
      }
    }
  }
  
  private func place(atX x: Int, y: Int) {
    withAnimation {
      do {
          try game.place(atX: x, y: y)
      } catch TicTacToe.InvalidMove.occupied {
        // FIXME: we should probably notify user but meh
      } catch {
        // this is rather unexpected
        fatalError(error.localizedDescription)
      }
    }
  }
  
  // MARK: - Other UI Controls
  #if os(watchOS)
  var navigationTitle: Text {
    switch game.state {
    case .draw:
      return Text("Draw")
    case .playing(nextMoveBy: let player):
      return Text("Next: \(player.symbol)")
    case .won(winner: let winner):
      return Text("Winner: \(winner.symbol)")
    }
  }
  #else
  @ViewBuilder
  var callout: some View {
    switch game.state {
    case .draw:
      Text("Draw")
        .font(.callout)
        .foregroundColor(.red)
    case .won(let player):
      Text("Winner")
        .font(.callout)
        .foregroundColor(player.color)
    case .playing:
      Text("Next Up")
        .font(.callout)
        .foregroundStyle(.secondary)
    }
  }
  
  @ViewBuilder
  var title2: some View {
    switch game.state {
    case .draw:
      Text("… or drawn using Swift Charts 😝")
        .font(.title2.bold())
        .foregroundColor(.primary)
    case .won(winner: let player),
        .playing(nextMoveBy: let player):
      Label(player.localizedDescription,
            systemImage: player == .first ? "circle" : "xmark")
        .font(.title2.bold())
        .foregroundColor(player.color)
    }
  }
  #endif
  
  var resetButton: some View {
    Button("Reset Chart") {
      game.reset()
    }
    .disabled(game.moves.isEmpty)
  }
  
  var body: some View {
    #if os(watchOS)
    NavigationStack {
      ScrollView {
        VStack {
          ticTacToe
          resetButton
        }
      }
      .navigationTitle(navigationTitle)
    }
    #else
    NavigationStack {
      VStack(alignment: .leading) {
        callout
        title2
        ticTacToe
      }
      .toolbar {
        resetButton
      }
      .padding()
      .navigationTitle("Tic Tac Toe")
    }
    #endif
  }
}

extension Player {
  var color: Color {
    switch self {
    case .first: return .blue
    case .second: return .green
    }
  }
  
  #if os(watchOS)
  var symbol: String {
    switch self {
    case .first: return "⭕️"
    case .second: return "❌"
    }
  }
  #endif
}

struct ContentView_Previews: PreviewProvider {
  static var previews: some View {
    ContentView()
      .previewLayout(.sizeThatFits)
  }
}

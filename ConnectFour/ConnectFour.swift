//
//  ConnectFour.swift
//  SimpleGame
//
//  Created by mian zhang on 12/11/24.
//

import SwiftUI

enum GridState:String {
    case empty="", red, yellow
}

struct ConnectFour: View {
    static let colNum = 7
    static let rowNum = 6
    @State private var grid: [[GridState]] = Array(repeating:Array(repeating: .empty, count: ConnectFour.colNum), count:ConnectFour.rowNum)
    @State private var gameEnds: Bool = false
    @State private var winner: GridState = .empty
    @State private var step: Int = 0
    
    var columns: [GridItem] = Array(repeating: GridItem(.flexible(), spacing:0), count: ConnectFour.colNum)
    
    func circleColor(_ row:Int, _ col:Int)-> Color {
        // row number index from upside down
        let gState =  grid[ConnectFour.rowNum - 1 - row][col]
        switch gState {
        case .empty: return .white
        case .red: return .red
        case .yellow: return .yellow
        }
    }
    
    var body: some View {
        GeometryReader { geometry in
            let cellSize = geometry.size.width / CGFloat(ConnectFour.colNum)
            let circleSize = cellSize-10.0*2
            VStack {
                LazyVGrid(columns: columns, spacing:0) {
                    ForEach(0..<ConnectFour.rowNum, id:\.self) { row in
                        ForEach(0..<7) { col in
                            ZStack {
                                Button {
                                    withAnimation(.easeIn ) {
                                        dropAt(row, col)
                                    }
                                } label: {
                                    Circle()
                                    .foregroundColor(circleColor(row, col))
                                    .frame(width:circleSize, height:circleSize)
                                }
                            
                            }.frame(width:cellSize, height:cellSize)
                        .background(.blue)
                    }
                    }
                
                }.frame(maxWidth: .infinity)
                    .padding(.top)
            
            let text = winner != .empty ? "Winner is \(winner.rawValue)" : "Next: " + (step % 2 == 0 ? "Yellow" : "Red")
            Text(text)
            Button {
                reset()
            } label: {
                Text("Reset")
            }
            if gameEnds {
                Text("Game Ends")
            }
            }
        }
    }
    
    func reset() {
        grid = Array(repeating:Array(repeating: .empty, count: ConnectFour.colNum), count:ConnectFour.rowNum)
        winner = .empty
        step = 0
        gameEnds = false
    }
    
    func dropAt(_ row: Int, _ col: Int) {
        guard winner == .empty else { return }
        let fill:GridState = step % 2 == 0 ? .yellow : .red
        var dropped = false
        for i in 0..<ConnectFour.rowNum {
            if grid[i][col] == .empty {
                grid[i][col] = fill
                
                winner = gameEnds(i, col)
                if winner != .empty {
                    break
                }
                if i == ConnectFour.rowNum - 1 {
                    break
                }
                dropped = true
                break
            }
        }
        if dropped {
            step += 1
        }
    }

    func runGame() {
        
        var i = 0
        while i < 10000, winner == .empty {
            let col = Int.random(in: 0..<ConnectFour.colNum)
            let fill:GridState = i % 2 == 0 ? .yellow : .red
            var dropped = false
            for i in 0..<ConnectFour.rowNum {
                if grid[i][col] == .empty {
                    grid[i][col] = fill
                    
                    if gameEnds(i, col) != .empty {
                        break
                    }
                    if i == ConnectFour.rowNum - 1 {
                        break
                    }
                    dropped = true
                    break
                }
            }
            if winner != .empty || !dropped {
                continue
            } else {
                i += 1
            }
        }
        
    }

    func gameEnds(_ row:Int, _ col:Int) -> GridState {
        let gridState = grid[row][col]
        // horizontal
        var count = 0
        for i in col-3...col {
            if i < 0 || i >= ConnectFour.colNum {
                continue
            }
            count = 0
            for j in i..<i+4 {
                if j < 0 || j >= ConnectFour.colNum {
                    continue
                }
                if grid[row][j] != gridState {
                    break
                } else {
                    count += 1
                }
            }
            if count == 4 {
                return gridState
            }
        }
        // vertical
        count = 0
        for i in 0..<4 {
            if row-i < 0 {
                break
            }
            if grid[row-i][col] != gridState {
                break
            } else {
                count += 1
            }
        }
        if count == 4 {
            return gridState
        }
        // diagnal
        for i in row-3...row {
            if i < 0 {
                continue
            }
            let j = col - (row-i)
            if j < 0 {
                continue
            }
            count = 0
            for k in 0..<4 {
                if i+k >= ConnectFour.rowNum || j+k >= ConnectFour.colNum {
                    break
                }
                if grid[i+k][j+k] != gridState {
                    break
                } else {
                    count += 1
                }
            }
            if count == 4 {
                return gridState
            }
        }
        for i in row-3...row {
            if i < 0 {
                continue
            }
            let j = col + (row-i)
            if j >= ConnectFour.colNum {
                continue
            }
            if 2 * i - row >= ConnectFour.colNum {
                break
            }
            count = 0
            for k in 0..<4 {
                if i+k >= ConnectFour.rowNum || j-k < 0 {
                    break
                }
                if grid[i+k][j-k] != gridState {
                    break
                } else {
                    count += 1
                }
            }
            if count == 4 {
                return gridState
            }
        }
        return .empty
    }
}

#Preview {
    ConnectFour()
}

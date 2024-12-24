//
//  TicTacToe.swift
//  SimpleGame
//
//  Created by mian zhang on 12/18/24.
//

import SwiftUI

enum CellState:String {
    case O, X, empty = ""
}

struct TicTacToe: View {
    var gridSize: Int
    @State var status: [[CellState]] = []
    
    @State var nextPlayer:String = "O" // can be "x"
    @State var step: Int = 0
    @State var finalWinner: String?
    

    init(gridSize: Int) {
        if gridSize >= 3, gridSize <= 6 {
            self.gridSize = gridSize
        } else {
            print("custom set gridSize \(gridSize) is off limit, using 3 by default.")
            self.gridSize = 3
        }
        self._status = State(initialValue: Array(repeating: Array(repeating: CellState.empty, count: self.gridSize), count: self.gridSize))
    }
    
    var body: some View {
        GeometryReader { geometry in
            let spacing: CGFloat = 10
            let totalSpacing = spacing * CGFloat(gridSize + 3)
            let cellSize = (geometry.size.width - totalSpacing) / CGFloat(gridSize)
            
            let gridItems = Array(repeating: GridItem(.fixed(cellSize), spacing: spacing), count: gridSize)
            VStack {
                // GridView gridSize x gridSize
                LazyVGrid(columns: gridItems, spacing:spacing) {
                    ForEach(0..<status.count, id:\.self) { row in
                        ForEach(0..<status[row].count, id:\.self) { column in
                    
                            Button {
                                // toggle empty to X or O based on input
                                if performAction(row, column) {
                                    step += 1
                                    if let winner = gameIsEnd(row, column) {
                                        finalWinner = winner
                                        print("game ends")
                                    }
                                }
                            } label: {
                                Text(status[row][column].rawValue)
                                    .frame(width: cellSize, height: cellSize)
                                    .background(Color.white)
                                    .foregroundColor(.gray)
                                    .font(.largeTitle)
                            }.frame(width: cellSize, height: cellSize)
                                .padding(.top, row == 0 ? spacing : 0)
                                .padding(.bottom, row == gridSize - 1 ? spacing : 0)
            
                        }
                    }
                }.background(.gray)
                    .padding(spacing)
                
                // Labels
                var labelText = ""
                if let winner = finalWinner {
                    labelText = "Winner is: \(winner) !"
                } else if step >= gridSize*gridSize  {
                    labelText = "No Moves !"
                } else {
                    labelText = "Next Turn: \(nextPlayer)"
                }
                Text(labelText)
                Button {
                    resetGame()
                } label: {
                    Text("Reset")
                }
            }
            //.padding()
        }
    }
    
    func resetGame() {
        step = 0
        finalWinner = nil
    
        status = Array(repeating:Array(repeating: .empty, count: gridSize), count:gridSize)
    }
    
    func performAction(_ row:Int, _ col:Int) -> Bool {
        if let _ = finalWinner {
            return false
        }
        if step == gridSize * gridSize {
            return false
        }
        let item = status[row][col]
        if item != .empty {
            return false
        }
    
        if step % 2 == 0 {
            nextPlayer = "X"
            status[row][col] = .O
        } else {
            nextPlayer = "O"
            status[row][col] = .X
        }

        return true
    }
    
    func gameIsEnd(_ x:Int, _ y:Int) -> String? {
        // rows
        let item = status[x][y]
        var found = true
        for i in 0..<gridSize {
            let follow = status[x][i]
            if item != follow {
                found = false
                break
            }
        }
        if found {
            return item.rawValue
        }
        // columns
        found = true
        for i in 0..<gridSize {
            let follow = status[i][y]
            if item != follow {
                found = false
                break
            }
        }
        if found {
            return item.rawValue
        }
        if x == y {
            found = true
            // diag
            for i in 0..<gridSize {
                let follow = status[i][i]
                if follow != item {
                    found = false
                    break
                }
            }
            if found {
                return item.rawValue
            }
            found = true
            // diag
            for i in 0..<gridSize {
                let follow = status[i][gridSize-1-i]
                if follow != item {
                    found = false
                    break
                }
            }
            if found {
                return item.rawValue
            }
        }
        return nil
    }
}

#Preview {
    TicTacToe(gridSize: 4)
}

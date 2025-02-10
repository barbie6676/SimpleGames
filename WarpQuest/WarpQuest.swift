//
//  WarpQuest.swift
//  SimpleGame
//
//  Created by mian zhang on 2/4/25.
//

import SwiftUI

enum WarpCellState: Equatable {
  case empty, plane, targetPlane, stone
}

enum Direction {
  case right, left, up, down
}

struct WarpQuest: View {
  static var DIMENSION = 5
  @State private var pos: [[WarpCellState]] = Array(repeating:Array(repeating: .empty, count: DIMENSION), count: DIMENSION)

  @State private var dirs: [[Direction]] = Array(repeating:Array(repeating: .right, count: DIMENSION), count: DIMENSION)
  @State private var stones:[(Int, Int)] = []
  @State private var des = (2, 2)
  @State private var ships = [(4, 2), (0, 3), (1, 1), (2, 3)]

  @State private var steps: [String] = []
  @State private var selected: [Int] = [-1, -1]
  @State private var gameEnd: Bool = false

  @State private var level: Int = 0
  @State private var highestLevel: Int = 0

  var body: some View {
      GeometryReader { geometry in
          let spacing: CGFloat = 5
          let totalSpacing = spacing * CGFloat(4)
          let cellSize = (geometry.size.width - totalSpacing) / CGFloat(5)

          let gridItems = Array(repeating: GridItem(.fixed(cellSize), spacing: spacing), count: WarpQuest.DIMENSION)
        VStack {
          Text("WarpQuest")
            .padding(.bottom, 10)
          LazyVGrid(columns: gridItems, spacing: spacing) {

            ForEach(0..<WarpQuest.DIMENSION, id: \.self) { row in
              ForEach(0..<WarpQuest.DIMENSION) { column in
                Button {
                  tapOn(row, column)
                } label: {
                  let cellState = pos[row][column]
                  switch(cellState) {
                  case .empty: 
                    if isTargetPosition(row, column) { Image(systemName: "star")
                    } else {
                      Text("").frame(width: cellSize, height: cellSize)
                    }
                  case .plane: Image(systemName: "airplane").rotationEffect(.degrees(directionToDegree(row, column)))
                  case .targetPlane: Image(systemName: "airplane.circle").rotationEffect(.degrees(directionToDegree(row, column)))
                  case .stone: Image(systemName: "nosign")
                  }
                }
                  .frame(width: cellSize, height: cellSize)
                  .background((row == selected[0] && column == selected[1]) ? Color.blue: (gameEnd ? Color.green : Color.white))
                  .padding(.top, row == 0 ? 5 : 0)
                  .padding(.bottom, row == 4 ? 5 : 0)
                  .foregroundColor(.black)
              }
            }
          }.background(Color.gray)

          HStack {
            Button {
              setUp(level)
            } label: {
              Text("Reset!")
            }
            Button {
              solution()
            } label: {
              Text("Show Solution")
            }

            if gameEnd {
              Button {
                level += 1
                if level > highestLevel {
                  highestLevel = level
                }
                setUp(level)
              } label: {
                let label = (level < gameSettings.count) ? "Next Level" : "Unlock All Levels"
                Text(label)
              }
            }
            Picker("Unlocked Levels", selection: $level) {
              ForEach(0...highestLevel, id: \.self) { num in
                    Text("Level \(num+1)")
              }
            }
            .pickerStyle(.menu)
            .frame(width:100)
            .onChange(of: level) { oldV, newV in
                if newV != oldV {
                  setUp(level)
                }
            }

          }

          Text(steps.joined(separator: ", "))
          Spacer()
        }
      }.task {
        // initial setup
        setUp(level)
        }
    }

  func isTargetPosition(_ x: Int, _ y: Int) -> Bool {
    x == des.0 && y == des.1
  }

  func directionToDegree(_ x: Int, _ y: Int) -> Double {
    switch(dirs[x][y]) {
    case .right: return 0
    case .left: return 180.0
    case .down: return 90.0
    case .up: return -90.0
    }
  }

  func setUpPlanes(_ planes: [(Int, Int)], _ grid: inout [[WarpCellState]]) {

    for i in 0..<WarpQuest.DIMENSION {
      for j in 0..<WarpQuest.DIMENSION {
        if grid[i][j] == .stone {
          continue
        }
        grid[i][j] = .empty
      }
    }

    for i in 0..<planes.count {
      let elem = planes[i]
      if i == 0 {
        grid[elem.0][elem.1] = .targetPlane
      } else {
        grid[elem.0][elem.1] = .plane
      }
    }
  }

  func setUp(_ level: Int) {
    steps.removeAll()
    guard level < gameSettings.count else { return }
    gameEnd = false
    let gameSetting = gameSettings[level]
    dirs = Array(repeating:Array(repeating: .right, count: WarpQuest.DIMENSION), count: WarpQuest.DIMENSION)
    des = (gameSetting.target[0], gameSetting.target[1])
    ships = gameSetting.planes.map { ($0[0], $0[1]) }
    stones = gameSetting.stones.map { ($0[0], $0[1]) }
    // repaint grid
    for i in 0..<WarpQuest.DIMENSION {
      for j in 0..<WarpQuest.DIMENSION {
        pos[i][j] = .empty
      }
    }
    for stone in stones {
      pos[stone.0][stone.1] = .stone
    }
    setUpPlanes(ships, &pos)
  }

  func canMoveTo(_ x: Int, _ y: Int, row: Bool = false, step: Int = 1) -> Bool {
    guard x >= 0, x < WarpQuest.DIMENSION, y >= 0, y < WarpQuest.DIMENSION else { return false }
    // a plane can only move horizontally or vertically
    // to a cell next to another plane
    if pos[x][y] == .plane || pos[x][y] == .targetPlane {
      if !row {
        if step > 0 {
          for col in selected[1]...y {
            if pos[x][col] == .stone {
              return false
            }
          }
        } else {
          for col in y...selected[1] {
            if pos[x][col] == .stone {
              return false
            }
          }
        }
      } else { // row = true
        if step > 0 {
          for r in selected[0]...x {
            if pos[r][y] == .stone {
              return false
            }
          }
        } else {
          for r in x...selected[0] {
            if pos[r][y] == .stone {
              return false
            }
          }
        }
      }
      return true
    }
    return false
  }

  func moveTo(_ x: Int, _ y: Int, _ dir: Direction) {
    let fromState = pos[selected[0]][selected[1]]

    if dirs[selected[0]][selected[1]] != dir {
      dirs[selected[0]][selected[1]] = dir
    }
    pos[x][y] = fromState
    dirs[x][y] = dir
    pos[selected[0]][selected[1]] = .empty
    dirs[selected[0]][selected[1]] = .right
    selected = [-1, -1]

    if fromState == .targetPlane, isTargetPosition(x, y) {
      gameEnd = true
    }
  }

  func tapOn(_ x: Int, _ y: Int) {
    guard gameEnd == false else { return }
    print("tap on \(x) \(y)")
    if x == selected[0], y == selected[1] {
      // deselect previous selection
      selected = [-1, -1]
      return
    }
    if pos[x][y] == .plane || pos[x][y] == .targetPlane {
      selected = [x, y]
    } else if pos[x][y] == .empty {
      if selected[0] == -1 {
        return
      }
      if selected[0] == x {
        if selected[1] > y, canMoveTo(x, y-1, step: -1) {
          // move left
          moveTo(x, y, .left)
        } else if selected[1] < y, canMoveTo(x, y+1) {
          // move right
          moveTo(x, y, .right)
        }
      } else if selected[1] == y {
        if selected[0] > x, canMoveTo(x-1, y, row: true, step:-1) {
          moveTo(x, y, .up)
        } else if selected[0] < x, canMoveTo(x+1, y, row: true) {
          // move down
          moveTo(x, y, .down)
        }
      }
    }
  }

  func solution() {

    var found = false
    var q: [[(Int, Int)]] = [ships]
    var lastShip = [-1]
    var lastDir = [-1]
    var path: [[String]] = [[]]
    var localPos:[[WarpCellState]] = Array(repeating:Array(repeating: .empty, count:5), count:5)

    for stone in stones {
      localPos[stone.0][stone.1] = .stone
    }
    while !q.isEmpty && !found {

      // get the current positions and repaint the grid.
      let planes = q.removeFirst()
      setUpPlanes(planes, &localPos)

        // remember the last movement
      let lastdir = lastDir.removeFirst()
      let lastship = lastShip.removeFirst()
      let laststeps = path.removeFirst()

      // for each ship, check the available movements.
      for i in 0..<planes.count {
        if found { break }
        var moves:[(Int, Int)] = []
        if i == lastship {
            moves = movable(localPos, planes, i, lastdir)
        } else {
            moves = movable(localPos, planes, i, -1)
        }

        // for each movement, check whether it's a solution:
        // if true, stop the game
        // otherwise add the new positions to the end of the queue.
        for j in (0..<moves.count).reversed() {
          let move = moves[j]
          let step = genStep(i, planes[i], move)

          if i == 0, isTargetPosition(move.0, move.1) {
            found = true
            steps = laststeps + [step]
            break
          }
          var shipsCopy = planes.map { $0 }
          shipsCopy[i] = move
          q.append(shipsCopy)

          var stepsCopy = laststeps.map { $0 }
          stepsCopy.append(step)
          path.append(stepsCopy)

          let dir = getDir(planes[i], move)
          lastDir.append(dir)
          lastShip.append(i)
        }
      }
    }
    if found {
        print(steps)
    }
  }

/**
 * Method to get a direction based on the last movement of a ship.
 */
  func getDir(_ p1: (Int, Int), _ p2: (Int, Int)) -> Int {
    //if the ship moved down, it won't move up next time.
    if p1.1 == p2.1 && p2.0 > p1.0 { return 0 }
    if p1.1 == p2.1 && p2.0 < p1.0 { return 1 }
    if p1.0 == p2.0 && p2.1 > p1.1 { return 2 }
    if p1.0 == p2.0 && p2.1 < p1.1 { return 3 }
    return -1
  }

/**
 * Method to check the available movements of the ith ship.
 * Except for a certain direction.
 */
  func movable(_ pos: [[WarpCellState]], _ planes:[(Int, Int)], _ id: Int, _ direction: Int) -> [(Int, Int)] {
    let ship = planes[id]
    var moves: [(Int, Int)] = []
    // look for other ships at four different directions
    // last-dir 0 down 1 up 2 right 3 down
    if direction != 0 {
      for i in (0..<ship.0).reversed() {
        if pos[i][ship.1] == .stone {
              break
        } else if (pos[i][ship.1] == .plane || pos[i][ship.1] == .targetPlane) {
                if i < ship.0 - 1 {
                    moves.append((i + 1, ship.1))
                    if id == 0 , isTargetPosition(i + 1, ship.1) {
                        return moves
                    }
                }
                break
            }
        }
    }

    if direction != 1 {
      for i in (ship.0 + 1)..<WarpQuest.DIMENSION {
        if pos[i][ship.1] == .stone {
                break
        } else if (pos[i][ship.1] == .plane || pos[i][ship.1] == .targetPlane) {
                if i > ship.0 + 1 {
                    moves.append((i - 1, ship.1))
                  if id == 0, isTargetPosition(i - 1, ship.1) {
                        return moves
                    }
                }
                break
            }
        }
    }

    if direction != 2 {
      for i in (0..<ship.1).reversed() {
        if pos[ship.0][i]  == .stone {
                break
        } else if (pos[ship.0][i] == .plane || pos[ship.0][i] == .targetPlane) {
                if i < ship.1 - 1 {
                    moves.append((ship.0, i + 1))
                    if id == 0 , isTargetPosition(ship.0, i + 1) {
                        return moves
                    }
                }
                break
            }
        }
    }

    if direction != 3 {
      for i in (ship.1 + 1)..<WarpQuest.DIMENSION {
        if pos[ship.0][i] == .stone {
                break
        } else if (pos[ship.0][i] == .plane || pos[ship.0][i] == .targetPlane) {
                if i > ship.1 + 1 {
                    moves.append((ship.0, i - 1))
                    if id == 0, isTargetPosition(ship.0, i - 1) {
                        return moves
                    }
                }
                break
            }
        }
    }
    return moves
  }

  func genStep(_ id: Int , _ a: (Int, Int), _ b: (Int, Int)) -> String {
    return "Ship \(id): ( \(a.0), \(a.1)) to (\(b.0), \(b.1))"
  }

}

#Preview {
    WarpQuest()
}

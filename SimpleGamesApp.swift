//
//  SimpleGamesApp.swift
//  SimpleGame

//

import SwiftUI

struct ContentView: View {

  var body: some View {
    Text("Welcome to Play Some Games!")
  }

}

@main
struct SimpleGamesApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
            // 1. Tic-Tac-Toe game with customerized dimention
            // TicTacToe(gridSize:3)

            // 2. ConnectFour game with 7x6 grid
            // ConnectFour()
        }
    }
}

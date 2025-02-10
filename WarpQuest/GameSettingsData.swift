//
//  GameSettingsData.swift
//  SimpleGame
//
//  Created by mian zhang on 2/8/25.
//

import Foundation

struct WarpQuestSetting: Decodable {
    var stones: [[Int]]
    var target: [Int]
    var planes: [[Int]]
}

var gameSettings: [WarpQuestSetting] = load("gameSettings.json")




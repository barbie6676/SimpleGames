//
//  SampleData.swift
//  SimpleGame
//
//  Created by mian zhang on 12/18/24.
//

import Foundation

struct GuessWordSetting: Decodable {
    var secret: String
    var maxGuess: Int
    var words: [String]
}

var guessSamples: [GuessWordSetting] = load("secret_sample.json")

// moved to LoadFile.swift
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

func load<T: Decodable>(_ filename: String) -> T {
    let data: Data

    guard let file = Bundle.main.url(forResource: filename, withExtension: nil)
        else {
            fatalError("Couldn't find \(filename) in main bundle.")
    }

    do {
        data = try Data(contentsOf: file)
    } catch {
        fatalError("Couldn't load \(filename) from main bundle:\n\(error)")
    }

    do {
        let decoder = JSONDecoder()
        return try decoder.decode(T.self, from: data)
    } catch {
        fatalError("Couldn't parse \(filename) as \(T.self):\n\(error)")
    }
}

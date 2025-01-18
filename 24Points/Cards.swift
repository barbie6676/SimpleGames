//
//  Cards.swift
//  SimpleGame
//
//  Created by mian zhang on 12/22/24.
//

import Foundation

enum Suit: String, CaseIterable {
    case spade = "♠️", heart = "♥️", club =  "♣️",  diamond =  "♦️", smallJoker = "\u{1F0CF}", bigJoker = "\u{1F0DF}"
}

struct Card: Comparable, Equatable {
    var suit: Suit
    var rank: Int
    
    static func == (lhs: Self, rhs: Self) -> Bool {
        lhs.rank == rhs.rank && lhs.suit == rhs.suit
    }
    static func < (lhs: Self, rhs: Self) -> Bool {
        lhs.rank < rhs.rank
    }
    static func <= (lhs: Self, rhs: Self) -> Bool {
        lhs.rank <= rhs.rank
    }
    static func >= (lhs: Self, rhs: Self) -> Bool {
        lhs.rank >= rhs.rank
    }
    static func > (lhs: Self, rhs: Self) -> Bool {
        lhs.rank > rhs.rank
    }
}

class Deck {
    var cards: [Card]
    
    init() {
        cards = []
        for suit in Suit.allCases {
            for i in 1...13 {
                cards.append(Card(suit: suit, rank: i))
            }
        }
        cards.append(Card(suit: .smallJoker, rank: 14))
        cards.append(Card(suit: .bigJoker, rank: 15))
    }
    
    func shuffle() {
        cards.shuffle()
    }
    
    func remove(_ card: Card) {
        cards.removeAll { $0 == card }
    }
    
    func serve() -> Card? {
        return cards.popLast()
    }
}

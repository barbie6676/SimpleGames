//
//  Trie.swift
//  SimpleGame
//
//  Created by mian zhang on 12/20/24.
//

import Foundation

class Node {
    var char: Character = "."
    var prefix: String = ""
    var children: [Node?] = Array(repeating:nil , count: 26)
}

class Trie {
    var root:Node = Node()
    var allWords: Set<String> = []
    var blacklist: [Set<Character>] = Array(repeating: Set([]), count: 6)
    
    func reset() {
        root = Node()
        allWords.removeAll()
        for i in 0..<6 {
            blacklist[i] = Set()
        }
    }
    
    func cToIdx(_ c:Character) -> Int {
        if let ascii = c.asciiValue {
            return Int(ascii) - 97
        }
        return -1
    }
    
    func insert(_ word: String) {
        allWords.insert(word)
        let wl = Array(word)
        var node = root
        var prefix = root.prefix
        for i in 0..<6 {
            if let child = node.children[cToIdx(wl[i])] {
                node = child
            } else {
                node = Node()
                node.char = wl[i]
                node.prefix = String(prefix)
                node.children[cToIdx(wl[i])] = node
            }
            prefix += String(wl[i])
        }
    }
    
    func removeWordsFrom(_ node:Node) -> Set<String> {
        
        var toRemove: Set<String> = []
        var queue: [Node] = [node]
        while !queue.isEmpty {
            let poped = queue.removeFirst()
            if poped.prefix.count == 5 {
                toRemove.insert(poped.prefix + String(poped.char))
            } else if poped.prefix.count < 5 {
                for i in 0..<26 {
                    if let child = poped.children[i] {
                        queue.append(child)
                    }
                }
            }
        }
        allWords.subtract(toRemove)
        return toRemove
    }
    
    func removeAfter(exactMatch: Int, guess: String) -> Set<String> {
        var toRemove: Set<String> = []
        let gl = Array(guess)
        for word in allWords {
            var match = 0
            let wl = Array(word)
            for i in 0..<6 {
                if gl[i] == wl[i] {
                    match += 1
                    if match >= exactMatch {
                        break
                    }
                }
            }
            if match < exactMatch {
                toRemove.insert(word)
            }
        }
        allWords.subtract(toRemove)
        return toRemove
    }
    
    func remove(_ ch: Character, at: Int) -> Set<String> {
        guard !blacklist[at].contains(ch) else { return Set() }
        blacklist[at].insert(ch)
        var queue: [(Node, Int)] = [(root, 0)]
        var toRemove: Set<String> = []
        while !queue.isEmpty {
            let (node, idx) = queue.removeFirst()
            if idx < at {
                for child in node.children {
                    if let nonNil = child {
                        queue.append((nonNil, idx+1))
                    }
                }
            } else if idx == at {
                if let child = node.children[cToIdx(ch)] {
                    toRemove.formUnion(removeWordsFrom(child))
                    node.children[cToIdx(ch)] = nil
                }
            }
        }
        return toRemove
    }
}

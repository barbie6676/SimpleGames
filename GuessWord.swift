//
//  GuessWord.swift
//  SimpleGame
//
//  Created by mian zhang on 12/18/24.
//

import SwiftUI

struct GuessWord: View {
    @State private var sampleIndex:Int = 0
    @State private var words:[String] = []
    @State private var trie = Trie()
    @State private var guesses:[(String, Int)] = []
    @State private var secret: String = ""
    @State private var guessedSecret: Bool = false
    @State private var maxGuess: Int = 10
    
    init() {
        self._words = State(initialValue: guessSamples[0].words)
        self._secret = State(initialValue: guessSamples[0].secret)
        self._maxGuess = State(initialValue: guessSamples[0].maxGuess)
        words.forEach { trie.insert($0) }
    }
    
    var body: some View {
        GeometryReader { geometry in
            VStack {
                HStack {
                    Picker("Sample Setting", selection: $sampleIndex) {
                        ForEach(guessSamples.indices, id:\.self) { idx in
                            Text("Test Case: \(idx)").tag(idx)
                        }
                        Text("Generate Random").tag(guessSamples.count)
                    }.onChange(of: sampleIndex) { oldValue, newValue in
                        if newValue != oldValue {
                            guessedSecret = false
                            guesses.removeAll()
                            if newValue == guessSamples.count {
                                secret = generateRandomWord()
                                words.removeAll()
                                trie.reset()
                                for _ in 0..<100 {
                                    let rand = generateRandomWord()
                                    words.append(rand)
                                    trie.insert(rand)
                                }
                                trie.insert(secret)
                                words.append(secret)
                                maxGuess = 15
                            } else {
                                words = guessSamples[newValue].words
                                secret = guessSamples[newValue].secret
                                maxGuess = guessSamples[newValue].maxGuess
                                trie.reset()
                                words.forEach { trie.insert($0) }
                            }
                        }
                    }
                    
                    Text(guessedSecret ? "You guessed \(secret)" : "Guess Secret Word")
                        .font(.title2)
                        .frame(maxWidth: .infinity, alignment: .center)
                }
                
                let contentHeight = 50 * Double(words.count)
                ScrollView {
                    let columns = Array(repeating: GridItem(.flexible()), count: 4)
                    
                    LazyVGrid(columns: columns) {
                        ForEach(words.indices, id:\.self) { item in
                            Button {
                                guessWord(at: item)
                            } label: {
                                Text(words[item])
                            }.frame(minHeight: 20)
                        }
                    }
                }.frame(minHeight: min(geometry.size.height*0.5, contentHeight))
                
                HStack {
                    Text("Wrong guesses")
                    Spacer()
                    Text("exact match")
                }.cornerRadius(5.0)
                    .padding(.horizontal, 20)
                ScrollViewReader { proxy in
                    List {
                        
                        ForEach(guesses.indices, id:\.self) { item in
                            HStack {
                                Text(guesses[item].0)
                                Spacer()
                                Text("\(guesses[item].1)")
                            }
                        }.onAppear {
                            // Scroll to the second item, which reduces the initial offset
                            proxy.scrollTo(0, anchor: .top)
                        }
                    }.listStyle(.plain)
                        .frame(maxHeight: CGFloat(maxGuess) * 20)
                }
            }
        }
    }
    
    func generateRandomWord() -> String {
        var seed = ""
        for _ in 0..<6 {
            let randIdx: UInt8 = UInt8.random(in: 0..<26)
            let ch = Character(UnicodeScalar(randIdx+97))
            seed += String(ch)
        }
        return seed
    }
    
    func guessWord(at: Int) {
        
        guard !guessedSecret else {
            return
        }
        guard guesses.count <= maxGuess else {
            print("max guesses limit reached")
            return
        }
        let match = askMaster(words[at])
        print("guessed \(words[at]) matched \(match)")
        if match == 6 {
            guessedSecret = true
        } else {
            let guess = words[at]
            guesses.append((guess, match))
            if match == 0 {
                let wl = Array(guess)
                for i in 0..<6 {
                    let toRemove = trie.remove(wl[i], at: i)
                    words.removeAll { toRemove.contains($0)}
                }
                words.removeAll  { $0 == guess}
            } else {
                let toRemove = trie.removeAfter(exactMatch: match, guess:guess)
                words.remove(at: at)
                words.removeAll { toRemove.contains($0) }
            }
        }
    }
    
    func askMaster(_ guess: String) -> Int {
        var match = 0
        let w1 = Array(secret)
        let w2 = Array(guess)
        for i in 0..<6 {
            if w1[i] == w2[i] {
                match += 1
            }
        }
        return match
    }
}

#Preview {
    GuessWord()
}

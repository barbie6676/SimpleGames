//
//  TwentyFourPoints.swift
//  SimpleGame
//
//  Created by mian zhang on 12/22/24.
//

import SwiftUI

struct TwentyFourPoints: View {
    @State private var deck: Deck = Deck()
    @State private var numbers: [Int] = [3,3,3,4]
    @State private var answers: [String] = []
    @State private var memory:[Int: [[Int]:Set<String>]] = [:]
    var body: some View {
        VStack {
            Button {
                serveFourCards()
            } label: {
                Text("Play!")
                    .foregroundStyle(.black)
                    .font(.title)
            }.padding(.top, 30)
            
            LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 4), spacing: 10.0) {
                ForEach(0..<4) { idx in
                    let num = (idx < numbers.count) ? "\(numbers[idx])" : ""
                    Text(num)
                        .padding()
                        .frame(minWidth: 50)
                        .frame(height:50)
                        .background(Color.white)
                        .clipShape(RoundedRectangle(cornerRadius: 10))
                        .overlay(
                                RoundedRectangle(cornerRadius: 10) // Same corner radius
                                    .stroke(Color.gray, lineWidth: 2) // Border
                        )
                }
            }.frame(maxWidth:.infinity)
                .padding(.horizontal, 50)
            Spacer()
            List {
                Text("Answers")
                ForEach(0..<answers.count, id: \.self) { idx in
                    Text(answers[idx]).frame(alignment: .center)
                }
            }
        }.task {

            removeJokers()
            serveFourCards()
        }
    }
    
    func removeJokers() {
        deck.remove(Card(suit: Suit.bigJoker, rank:15))
        deck.remove(Card(suit: Suit.smallJoker, rank:14))
        deck.shuffle()
    }
    
    func serveFourCards() {
        answers.removeAll()
        numbers.removeAll()
        memory.removeAll()
        if deck.cards.count < 4 {
           deck = Deck()
            removeJokers()
        }
        
        for _ in 0..<4 {
            numbers.append(deck.serve()!.rank)
        }
        calculate24()
    }
    
    func calculate24() {
        var sorted = numbers.sorted()
        calculateWithTarget(sorted, 0, 24).forEach {
            answers.append( $0 )
        }

        while nextPermutation(&sorted) {
            //print(sorted)
            calculateWithTarget(sorted, 0, 24).forEach {
                answers.append( $0 )
            }
        }
        let indexSet: Set<Int> = [0,1,2,3]
        for i in 0..<3 {
            for j in (i+1)..<4 {
                print(i, j)
                let a = sorted[i]
                let b = sorted[j]
                var left = indexSet
                left.subtract([i, j])
                var cd:[Int] = []
                left.forEach {
                    cd.append($0)
                }
                print(cd)
              combineTwo(a, b).forEach { (equation, result) in
                calculateTwo(sorted[cd[0]], sorted[cd[1]], 24-result, reverse: true).forEach {
                  answers.append(equation + " + "  + $0)
                }
                calculateTwo(sorted[cd[0]], sorted[cd[1]], result-24, reverse: true).forEach {
                  answers.append(equation + " - " + $0)
                }
                calculateTwo(sorted[cd[0]], sorted[cd[1]], result+24, reverse: true).forEach {
                  answers.append($0 + " - " + equation)
                }
                if result > 0 {
                  if 24 % result == 0 {
                    calculateTwo(sorted[cd[0]], sorted[cd[1]], 24/result, reverse: true).forEach {
                      answers.append(equation + " * " + $0)
                    }
                  } else if result % 24 == 0 {
                    calculateTwo(sorted[cd[0]], sorted[cd[1]], result/24, reverse: true).forEach {
                      answers.append(equation + " / " + $0)
                    }
                  } else {
                    calculateTwo(sorted[cd[0]], sorted[cd[1]], result*24, reverse: true).forEach {
                      answers.append($0 + " / " + equation)
                    }
                  }
              }
                }
            }
        }
        print(memory)

        answers = Array(Set(answers))
    }
    
    func nextPermutation( _ numbers: inout [Int]) -> Bool {
        var swap = -1
        for i in (0..<3).reversed() {
            for j in ((i+1)..<4).reversed() {
                if numbers[i] < numbers[j] {
                    numbers.swapAt(i, j)
                    swap = i
                    break
                }
            }
            if swap != -1 {
                break
            }
        }
        if swap == -1 {
            return false
        }
        var s = swap+1
        var e = 3
        while s < e {
            numbers.swapAt(s, e)
            s += 1
            e -= 1
        }
        return true
    }
    
    func calculateWithTarget(_ nums: [Int], _ start: Int, _ target: Int) -> [String] {
        if target < 0 { return [] }
        var numSet = nums[start...].map { $0 }
        numSet.sort()

        if let setToEqua = memory[target] {
            if let equa = setToEqua[numSet] {
                return Array(equa)
            }
        }
        if start == 2 {
            return calculateTwo(nums[start], nums[start+1], target)
        }

        var res: [String] = []
        let one = nums[start]
        calculateWithTarget(nums, start + 1, target - one).forEach { res.append("(\(one) + " + $0 + ")") }
        calculateWithTarget(nums, start + 1, one - target).forEach { res.append("(\(one) - " + $0 + ")") }

        if target % one == 0 {
            calculateWithTarget(nums, start + 1, target/one).forEach { res.append("\(one) * " + $0) }
        }
        if one % target == 0 {
            calculateWithTarget(nums, start + 1, one/target).forEach { res.append("\(one) / " + $0) }
        }
 
        if res.count > 0 {
            print("\(res) for starting from \(start) target \(target)")
            print("now the numset is \(numSet)")
            if var setToEqua = memory[target] {
                if var equa = setToEqua[numSet] {
                    equa.formUnion(res)
                    setToEqua[numSet] = equa
                } else {
                    setToEqua[numSet] = Set(res)
                }
                memory[target] = setToEqua
            } else {
                memory[target] = [numSet:Set(res)]
            }
        }
        return res
    }
    
    func combineTwo(_ a: Int, _ b: Int) -> [(String, Int)] {
        var res: [(String, Int)] = []
        res.append(("(\(a) + \(b))", a+b))
        if a > b {
            res.append(("(\(a) - \(b))", a-b))
        } else {
            res.append(("(\(b) - \(a))", b-a))
        }
        res.append(("\(a) * \(b)", a*b))
        if a % b  == 0 {
            res.append(("\(a) / \(b)", a/b))
        } else if b % a  == 0 {
            res.append(("\(b) / \(a)", b/a))
        }
        
        return res
    }
    
    func calculateTwo(_ a: Int, _ b: Int, _ target: Int, reverse: Bool = false) -> [String] {
        if target < 0 { return [] }
        var numSet = [a, b]
        numSet.sort()
        var res: [String] = []
            if a+b == target {
                res.append("(\(a) + \(b))")
            }
            if a*b == target {
                res.append("\(a) * \(b)")
            }
            if a-b == target {
                res.append("(\(a) - \(b))")
            }
            
            if a%b == 0, a/b == target {
                res.append("\(a) / \(b)")
            }
            
            if reverse {
                if b-a == target {
                    res.append("(\(b) - \(a))")
                }
                if b%a == 0, b/a == target {
                    res.append("\(b) / \(a)")
                }
            }
        if res.count > 0 {
            if var setToEqua = memory[target] {
                if var equa = setToEqua[numSet] {
                    equa.formUnion(res)
                    setToEqua[numSet] = equa
                } else {
                    setToEqua[numSet] = Set(res)
                }
                memory[target] = setToEqua
            } else {
                memory[target] = [numSet:Set(res)]
            }
        }
        return res
    }
}

#Preview {
    TwentyFourPoints()
}

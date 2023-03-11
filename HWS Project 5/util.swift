//
//  util.swift
//  HWS Project 5
//
//  Created by Walker Lockard on 3/10/23.
//

import Foundation

let SCORE_MAP: [UInt: UInt] = [
    1: 1,
    2: 2,
    3: 3,
    4: 5,
    5: 8,
    6: 13,
    7: 21,
    8: 34
]

func scoreWord(word: String) -> UInt {
    return SCORE_MAP[UInt(exactly: word.count)!]!
}

struct AcceptedAnswer {
    let word: String
    let score: UInt
    
    init(word: String) {
        self.word = word
        self.score = scoreWord(word: word)
    }
}


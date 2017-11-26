//
//  Array+Extensions.swift
//  1 Bit Rogue
//
//  Created by james bouker on 8/9/17.
//  Copyright © 2017 Jimmy Bouker. All rights reserved.
//

import Foundation

extension MutableCollection where Index == Int {

    func shuffled() -> Self {
        var copy = self
        copy.shuffle()
        return copy
    }

    mutating func shuffle() {
        if count < 2 { return }

        for i in startIndex ..< endIndex - 1 {
            let j = Int(arc4random_uniform(UInt32(endIndex - i))) + i
            if i != j {
                swapAt(i, j)
            }
        }
    }
}

extension Array {
    public func cross(_ array: [Element]) -> [(Element, Element)] {
        var ret = [(Element, Element)]()
        for x in self {
            for y in array {
                ret.append((x, y))
            }
        }
        return ret
    }

    public func toDictionary<Key: Hashable>(with selectKey: (Element) -> Key) -> [Key: Element] {
        var dict = [Key: Element]()
        for element in self {
            dict[selectKey(element)] = element
        }
        return dict
    }

    public mutating func filtered(_ isIncluded: (Element) -> Bool) {
        self = filter(isIncluded)
    }
}

extension Array {

    func randomItem() -> Element? {
        if isEmpty { return nil }
        let index = Int(arc4random_uniform(UInt32(count)))
        return self[index]
    }
}

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
    mutating func modifyWhere(_ test: (Element) -> Bool, to: (inout Element) -> Void) {
        for index in indices {
            var element = self[index]
            if test(element) {
                to(&element)
                self[index] = element
            }
        }
    }

    mutating func modifyForEach(_ body: (_ index: Index, _ element: inout Element) -> Void) {
        for index in indices {
            modifyElement(atIndex: index) { body(index, &$0) }
        }
    }

    mutating func modifyElement(atIndex index: Index, _ modifyElement: (_ element: inout Element) -> Void) {
        var element = self[index]
        modifyElement(&element)
        self[index] = element
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

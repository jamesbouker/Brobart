//
//  Dictionary+Extensions.swift
//  Bobart
//
//  Created by james bouker on 1/10/18.
//  Copyright © 2018 JimmyBouker. All rights reserved.
//

import Foundation

extension Dictionary {
    func hasKey(_ key: Key) -> Bool {
        return self[key] != nil
    }
}

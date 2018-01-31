//
//  ImageView+Extensions.swift
//  Bobart
//
//  Created by james bouker on 1/29/18.
//  Copyright © 2018 JimmyBouker. All rights reserved.
//

import UIKit

extension UIImageView {
    @IBInspectable var pixelated: Bool {
        set {
            layer.minificationFilter = kCAFilterNearest
            layer.magnificationFilter = kCAFilterNearest
        } get {
            return
                layer.minificationFilter == kCAFilterNearest &&
                layer.magnificationFilter == kCAFilterNearest
        }
    }
}

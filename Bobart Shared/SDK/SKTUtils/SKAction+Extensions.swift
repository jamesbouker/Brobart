/*
 * Copyright (c) 2013-2014 Razeware LLC
 *
 * Permission is hereby granted, free of charge, to any person obtaining a copy
 * of this software and associated documentation files (the "Software"), to deal
 * in the Software without restriction, including without limitation the rights
 * to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 * copies of the Software, and to permit persons to whom the Software is
 * furnished to do so, subject to the following conditions:
 *
 * The above copyright notice and this permission notice shall be included in
 * all copies or substantial portions of the Software.
 *
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 * IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 * FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 * AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 * LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 * OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
 * THE SOFTWARE.
 */

import SpriteKit

public extension SKNode {

    public func rung(_ actions: [SKAction]) {
        run(.group(actions))
    }

    public func runs(_ actions: [SKAction?]) {
        run(.sequence(actions.flatMap { $0 }))
    }
}

public extension SKAction {

    class func twoFrameAnim(pixelatedFile: String, direction: String? = nil) -> SKAction {
        let file1 = pixelatedFile + "_1" + (direction != nil ? "_\(direction!)" : "")
        let file2 = pixelatedFile + "_2" + (direction != nil ? "_\(direction!)" : "")
        let frame1 = SKTexture.pixelatedImage(file: file1)
        let frame2 = SKTexture.pixelatedImage(file: file2)
        let anim = SKAction.animate(with: [frame1, frame2], timePerFrame: frameTime)
        return .repeatForever(anim)
    }

    class func removeAction(_ type: String) -> SKAction {
        return SKAction.customAction(withDuration: 0) { node, _ in
            node.removeAction(forKey: type)
        }
    }

    /**
     * Performs an action after the specified delay.
     */
    public class func afterDelay(_ delay: TimeInterval, performAction action: SKAction) -> SKAction {
        return SKAction.sequence([SKAction.wait(forDuration: delay), action])
    }

    /**
     * Performs a block after the specified delay.
     */
    public class func afterDelay(_ delay: TimeInterval, runBlock block: @escaping () -> Void) -> SKAction {
        return SKAction.afterDelay(delay, performAction: SKAction.run(block))
    }

    /**
     * Removes the node from its parent after the specified delay.
     */
    public class func removeFromParentAfterDelay(_ delay: TimeInterval) -> SKAction {
        return SKAction.afterDelay(delay, performAction: SKAction.removeFromParent())
    }

    /**
     * Creates an action to perform a parabolic jump.
     */
    public class func jumpToHeight(_ height: CGFloat, duration: TimeInterval, originalPosition: CGPoint) -> SKAction {
        return SKAction.customAction(withDuration: duration) { node, elapsedTime in
            let fraction = elapsedTime / CGFloat(duration)
            let yOffset = height * 4 * fraction * (1 - fraction)
            node.position = CGPoint(x: originalPosition.x, y: originalPosition.y + yOffset)
        }
    }
}

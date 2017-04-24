//
//  KUIButtonBarSepratorView.swift
//  KUIButtonBar
//
//  Created by kofktu on 2017. 4. 24..
//  Copyright © 2017년 Kofktu. All rights reserved.
//

import UIKit

internal class KUIButtonBarSepratorView: UIView {
    
    var rowCount: Int = 0 {
        didSet {
            setNeedsDisplay()
        }
    }
    var columnCount: Int = 0 {
        didSet {
            setNeedsDisplay()
        }
    }
    var lineColor: UIColor = .lightGray {
        didSet {
            setNeedsDisplay()
        }
    }
    var lineWidth: CGFloat = 1.0 / UIScreen.main.scale {
        didSet {
            setNeedsDisplay()
        }
    }
    var lineInset: UIEdgeInsets = .zero {
        didSet {
            setNeedsDisplay()
        }
    }
    
    override func draw(_ rect: CGRect) {
        super.draw(rect)
        
        let context = UIGraphicsGetCurrentContext()
        context?.setLineWidth(lineWidth)
        context?.setStrokeColor(lineColor.cgColor)
        
        draw(vertical: rect, in: context)
        draw(horizontal: rect, in: context)
    }
    
    // MARK: - Private
    private func draw(horizontal rect: CGRect, `in` context: CGContext?) {
        guard rowCount > 1 else {
            return
        }
        
        let y = rect.height / CGFloat(rowCount)
        
        for index in 0 ..< rowCount - 1 {
            let dy = CGFloat(index + 1) * y
            context?.move(to: CGPoint(x: lineInset.left, y: dy))
            context?.addLine(to: CGPoint(x: rect.maxX - lineInset.right, y: dy))
            context?.strokePath()
        }
    }
    
    private func draw(vertical rect: CGRect, `in` context: CGContext?) {
        guard columnCount > 1 else {
            return
        }
        
        let x = rect.width / CGFloat(columnCount)
        
        for index in 0 ..< columnCount - 1 {
            let dx = CGFloat(index + 1) * x
            context?.move(to: CGPoint(x: dx, y: lineInset.top))
            context?.addLine(to: CGPoint(x: dx, y: rect.maxY - lineInset.bottom))
            context?.strokePath()
        }
    }
}

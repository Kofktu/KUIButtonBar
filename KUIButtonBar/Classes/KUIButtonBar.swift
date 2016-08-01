//
//  KUIButtonBar.swift
//  KUIButtonBar
//
//  Created by kofktu on 2016. 7. 29..
//  Copyright © 2016년 Kofktu. All rights reserved.
//

import UIKit

@objc
public protocol KUIButtonBarDelegate: class {
    
    // Required
    func render(buttonBar: KUIButtonBar, button: UIButton, index: Int)
    
    // Optional
    optional func click(buttonBar: KUIButtonBar, button: UIButton, index: Int)
    optional func selected(buttonBar: KUIButtonBar, button: UIButton, index: Int)
    
}

public struct KUIButtonBarConfig {
    public var toggle: Bool
    public var numberOfButtons: Int
    public var rowCount: Int
    public var columnCount: Int
    public var horizontalGap: CGFloat
    public var verticalGap: CGFloat
    public var defaultSelectedIndex: Int // toggle 값이 true 인 경우에만 KUIButtonBar refresh시 기본값으로 설정됨
    
    public init(
        toggle: Bool = false,
        numberOfButtons: Int,
        horizontalGap: CGFloat = 0.0,
        verticalGap: CGFloat = 0.0,
        defaultSelectedIndex: Int = -1) {
        self.toggle = toggle
        self.numberOfButtons = numberOfButtons
        self.rowCount = 1
        self.columnCount = numberOfButtons
        self.horizontalGap = horizontalGap
        self.verticalGap = verticalGap
        self.defaultSelectedIndex = defaultSelectedIndex
    }
    
    public init(
        toggle: Bool = false,
        numberOfButtons: Int,
        rowCount: Int,
        columnCount: Int,
        horizontalGap: CGFloat = 0.0,
        verticalGap: CGFloat = 0.0,
        defaultSelectedIndex: Int = -1) {
        self.toggle = toggle
        self.numberOfButtons = numberOfButtons
        self.rowCount = rowCount
        self.columnCount = columnCount
        self.horizontalGap = horizontalGap
        self.verticalGap = verticalGap
        self.defaultSelectedIndex = defaultSelectedIndex
    }
}

public class KUIButtonBar: UIView {
    
    public weak var delegate: KUIButtonBarDelegate?
    public var config: KUIButtonBarConfig!
    
    public var buttonType: UIButtonType = .Custom
    public var padding: UIEdgeInsets = UIEdgeInsetsZero
    
    public private(set) var buttons = [UIButton]()
    public private(set) var selectedIndex: Int = -1
    public var selectedButton: UIButton? {
        guard selectedIndex >= 0 else { return nil }
        return  buttons[selectedIndex]
    }
    
    private var calculatedButtonWidth: CGFloat {
        var width = CGRectGetWidth(frame) - (padding.left + padding.right)
        width -= config.horizontalGap * CGFloat(max(0, config.columnCount - 1))
        width /= CGFloat(config.columnCount)
        return width
    }
    private var calculatedButtonHeight: CGFloat {
        var height = CGRectGetHeight(frame) - (padding.top + padding.bottom)
        height -= config.verticalGap * CGFloat(max(0, config.rowCount - 1))
        height /= CGFloat(config.rowCount)
        return height
    }
    
    deinit {
        removeButtons()
    }
    
    public override func layoutSubviews() {
        super.layoutSubviews()
        
        guard buttons.count > 0 else { return }
        
        let buttonSize = CGSizeMake(calculatedButtonWidth, calculatedButtonHeight)
        
        for (index, button) in buttons.enumerate() {
            button.frame = CGRectMake(xOffsetForIndex(index), yOffsetForIndex(index), buttonSize.width, buttonSize.height)
        }
    }
    
    public func refresh() {
        let currentSelectedIndex = selectedIndex
        
        removeButtons()
        
        if config.toggle {
            selectedIndex = currentSelectedIndex >= 0 ? currentSelectedIndex : config.defaultSelectedIndex
        }
        
        createButtons()
    }
    
    public func deselect() {
        clearForSelectedButton()
        selectedIndex = -1
    }
    
    internal func onButtonPressed(sender: UIButton) {
        let index = buttons.indexOf(sender) ?? -1
        
        delegate?.click?(self, button: sender, index: index)
        
        guard config.toggle else { return }
        
        if sender != selectedButton {
            clearForSelectedButton()
            
            sender.userInteractionEnabled = false
            sender.selected = true
            selectedIndex = index
            
            delegate?.selected?(self, button: sender, index: index)
        }
    }
    
    private func createButtons() {
        guard buttons.count == 0 else { return }
        
        let buttonSize = CGSizeMake(calculatedButtonWidth, calculatedButtonHeight)
        
        for index in 0 ..< config.numberOfButtons {
            let button = UIButton(type: buttonType)
            button.frame = CGRectMake(xOffsetForIndex(index), yOffsetForIndex(index), buttonSize.width, buttonSize.height)
            button.selected = (index == selectedIndex)
            button.userInteractionEnabled = true
            button.addTarget(self, action: #selector(onButtonPressed(_:)), forControlEvents: .TouchUpInside)
            addSubview(button)
            buttons.append(button)
            delegate?.render(self, button: button, index: index)
        }
    }
    
    private func removeButtons() {
        guard buttons.count > 0 else { return }
        
        for button in buttons {
            button.removeFromSuperview()
        }
        
        buttons.removeAll()
        selectedIndex = -1
    }
    
    private func clearForSelectedButton() {
        selectedButton?.selected = false
        selectedButton?.userInteractionEnabled = true
    }
    
    private func xOffsetForIndex(index: Int) -> CGFloat {
        let columnIndex = CGFloat(index % config.columnCount)
        return padding.left + (columnIndex * calculatedButtonWidth) + (columnIndex * config.horizontalGap)
    }
    
    private func yOffsetForIndex(index: Int) -> CGFloat {
        let rowIndex = floor(CGFloat(index / config.columnCount))
        return padding.top + (rowIndex * calculatedButtonHeight) + (rowIndex * config.verticalGap)
    }
}

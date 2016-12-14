//
//  KUIButtonBar.swift
//  KUIButtonBar
//
//  Created by kofktu on 2016. 7. 29..
//  Copyright © 2016년 Kofktu. All rights reserved.
//

import UIKit

@objc public protocol KUIButtonBarDelegate: class {
    
    // Required
    func render(_ buttonBar: KUIButtonBar, button: UIButton, index: Int)
    
    // Optional
    @objc optional func click(_ buttonBar: KUIButtonBar, button: UIButton, index: Int)
    @objc optional func selected(_ buttonBar: KUIButtonBar, button: UIButton, index: Int)
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

open class KUIButtonBar: UIView {
    
    open weak var delegate: KUIButtonBarDelegate?
    open var config: KUIButtonBarConfig!
    
    open var buttonType: UIButtonType = .custom
    open var padding: UIEdgeInsets = UIEdgeInsets.zero
    
    open fileprivate(set) var buttons = [UIButton]()
    open fileprivate(set) var selectedIndex: Int = -1
    open var selectedButton: UIButton? {
        guard selectedIndex >= 0 else { return nil }
        return  buttons[selectedIndex]
    }
    
    fileprivate var calculatedButtonWidth: CGFloat {
        var width = frame.width - (padding.left + padding.right)
        width -= config.horizontalGap * CGFloat(max(0, config.columnCount - 1))
        width /= CGFloat(config.columnCount)
        return width
    }
    fileprivate var calculatedButtonHeight: CGFloat {
        var height = frame.height - (padding.top + padding.bottom)
        height -= config.verticalGap * CGFloat(max(0, config.rowCount - 1))
        height /= CGFloat(config.rowCount)
        return height
    }
    
    deinit {
        removeButtons()
    }
    
    open override func layoutSubviews() {
        super.layoutSubviews()
        
        guard buttons.count > 0 else { return }
        
        let buttonSize = CGSize(width: calculatedButtonWidth, height: calculatedButtonHeight)
        
        for (index, button) in buttons.enumerated() {
            button.frame = CGRect(origin: CGPoint(x: xOffsetForIndex(index), y: yOffsetForIndex(index)), size: CGSize(width: buttonSize.width, height: buttonSize.height))
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
    
    internal func onButtonPressed(_ sender: UIButton) {
        let index = buttons.index(of: sender) ?? -1
        
        delegate?.click?(self, button: sender, index: index)
        
        guard config.toggle else { return }
        
        if sender != selectedButton {
            clearForSelectedButton()
            
            sender.isUserInteractionEnabled = false
            sender.isSelected = true
            selectedIndex = index
            
            delegate?.selected?(self, button: sender, index: index)
        }
    }
    
    private func createButtons() {
        guard buttons.count == 0 else { return }
        
        let buttonSize = CGSize(width: calculatedButtonWidth, height: calculatedButtonHeight)
        
        for index in 0 ..< config.numberOfButtons {
            let button = UIButton(type: buttonType)
            button.frame = CGRect(origin: CGPoint(x: xOffsetForIndex(index), y: yOffsetForIndex(index)), size: buttonSize)
            button.isSelected = (index == selectedIndex)
            button.isUserInteractionEnabled = true
            button.addTarget(self, action: #selector(onButtonPressed(_:)), for: .touchUpInside)
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
        selectedButton?.isSelected = false
        selectedButton?.isUserInteractionEnabled = true
    }
    
    private func xOffsetForIndex(_ index: Int) -> CGFloat {
        let columnIndex = CGFloat(index % config.columnCount)
        return padding.left + (columnIndex * calculatedButtonWidth) + (columnIndex * config.horizontalGap)
    }
    
    private func yOffsetForIndex(_ index: Int) -> CGFloat {
        let rowIndex = floor(CGFloat(index / config.columnCount))
        return padding.top + (rowIndex * calculatedButtonHeight) + (rowIndex * config.verticalGap)
    }
}

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
    public var rowCount: Int
    public var columnCount: Int  // numberOfButtons 하기전에 값 설정해놓을것
    public var numberOfButtons: Int
    public var horizontalGap: CGFloat
    public var verticalGap: CGFloat
    public var defaultSelectedIndex: Int // toggle 값이 true 인 경우에만 KUIButtonBar refresh시 기본값으로 설정됨
    
    public init(
        toggle: Bool = false,
        numberOfButtons: Int,
        rowCount: Int = 1,
        columnCount: Int = 1,
        horizontalGap: CGFloat = 0.0,
        verticalGap: CGFloat = 0.0,
        defaultSelectedIndex: Int = -1) {
        self.toggle = toggle
        self.numberOfButtons = numberOfButtons
        self.rowCount = rowCount
        self.columnCount = rowCount > 1 ? columnCount : numberOfButtons
        self.horizontalGap = horizontalGap
        self.verticalGap = verticalGap
        self.defaultSelectedIndex = defaultSelectedIndex
    }
    
    public mutating func set(rowCount: Int = 1, columnCount: Int) {
        self.columnCount = columnCount
        self.rowCount = rowCount
        numberOfButtons = rowCount * columnCount
    }
}

public enum KUIButtonBarStyleType {
    case top
    case bottom
    case seprator
}

public struct KUIButtonBarStyle {
    public var topLine: KUIButtonBarLineStyle?
    public var bottomLine: KUIButtonBarLineStyle?
    public var sepratorLine: KUIButtonBarLineStyle?
    
    public init(
        type: [KUIButtonBarStyleType],
        color: UIColor) {
        if type.contains(.top) {
            topLine = KUIButtonBarLineStyle(color: color)
        }
        if type.contains(.bottom) {
            bottomLine = KUIButtonBarLineStyle(color: color)
        }
        if type.contains(.seprator) {
            sepratorLine = KUIButtonBarLineStyle(color: color)
        }
    }
}

public struct KUIButtonBarLineStyle {
    public var isHidden: Bool
    public var color: UIColor
    public var width: CGFloat
    public var inset: UIEdgeInsets
    
    public init(
        isHidden: Bool = false,
        color: UIColor = .lightGray,
        width: CGFloat = 1.0 / UIScreen.main.scale,
        inset: UIEdgeInsets = .zero) {
        self.isHidden = isHidden
        self.color = color
        self.width = width
        self.inset = inset
    }
}

open class KUIButtonBar: UIView {
    
    open weak var delegate: KUIButtonBarDelegate?
    open var config: KUIButtonBarConfig!
    open var style: KUIButtonBarStyle?
    
    open var buttonType: UIButtonType = .custom
    open var padding: UIEdgeInsets = UIEdgeInsets.zero
    
    open private(set) var buttons = [UIButton]()
    open private(set) var selectedIndex: Int = -1
    open var selectedButton: UIButton? {
        guard selectedIndex >= 0 else { return nil }
        return  buttons[selectedIndex]
    }
    
    internal lazy var sepratorView: KUIButtonBarSepratorView = { [unowned self] in
        let view = KUIButtonBarSepratorView(frame: CGRect.zero)
        view.backgroundColor = .clear
        return view
    }()
    
    private var calculatedButtonWidth: CGFloat {
        var width = frame.width - (padding.left + padding.right)
        width -= config.horizontalGap * CGFloat(max(0, config.columnCount - 1))
        width /= CGFloat(config.columnCount)
        return width
    }
    private var calculatedButtonHeight: CGFloat {
        var height = frame.height - (padding.top + padding.bottom)
        height -= config.verticalGap * CGFloat(max(0, config.rowCount - 1))
        height /= CGFloat(config.rowCount)
        return height
    }
    
    deinit {
        removeButtons()
    }
    
    public override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }
    
    public required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    open override func awakeFromNib() {
        super.awakeFromNib()
        setup()
    }
    
    open override func draw(_ rect: CGRect) {
        super.draw(rect)
        
        let context = UIGraphicsGetCurrentContext()
        
        if let style = style?.topLine, !style.isHidden {
            context?.setStrokeColor(style.color.cgColor)
            context?.setLineWidth(style.width)
            context?.move(to: CGPoint(x: style.inset.left, y: 0.0))
            context?.addLine(to: CGPoint(x: rect.maxX - style.inset.right, y: 0.0))
            context?.strokePath()
        }
        
        if let style = style?.bottomLine, !style.isHidden {
            context?.setStrokeColor(style.color.cgColor)
            context?.setLineWidth(style.width)
            context?.move(to: CGPoint(x: style.inset.left, y: rect.maxY))
            context?.addLine(to: CGPoint(x: rect.maxX - style.inset.right, y: rect.maxY))
            context?.strokePath()
        }
    }
    
    open override func layoutSubviews() {
        super.layoutSubviews()
        
        sepratorView.frame = bounds
        
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
        updateSepratorView()
        setNeedsDisplay()
    }
    
    public func deselect() {
        clearForSelectedButton()
        selectedIndex = -1
    }
    
    @objc internal func onButtonPressed(_ sender: UIButton) {
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
    
    // MARK: - Private
    private func setup() {
        insertSubview(sepratorView, at: 0)
    }
    
    private func updateSepratorView() {
        sepratorView.rowCount = config.rowCount
        sepratorView.columnCount = config.columnCount
        
        if let style = style?.sepratorLine {
            sepratorView.isHidden = style.isHidden
            sepratorView.lineWidth = style.width
            sepratorView.lineColor = style.color
            sepratorView.lineInset = style.inset
        } else {
            sepratorView.isHidden = true
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

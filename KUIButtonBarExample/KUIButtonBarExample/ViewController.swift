//
//  ViewController.swift
//  KUIButtonBarExample
//
//  Created by kofktu on 2016. 8. 1..
//  Copyright © 2016년 Kofktu. All rights reserved.
//

import UIKit
import KUIButtonBar

class ViewController: UIViewController, KUIButtonBarDelegate {

    @IBOutlet weak var horizontalButtonBar: KUIButtonBar!
    @IBOutlet weak var verticalButtonBar: KUIButtonBar!
    @IBOutlet weak var mixButtonBar: KUIButtonBar!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        setupHorizontal()
        setupVertical()
        setupMix()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    private func setupHorizontal() {
        horizontalButtonBar.delegate = self
        horizontalButtonBar.padding = UIEdgeInsetsMake(5.0, 5.0, 5.0, 5.0)
        horizontalButtonBar.config = KUIButtonBarConfig(toggle: false, numberOfButtons: 3, horizontalGap: 3.0, verticalGap: 0.0)
        horizontalButtonBar.refresh()
        
        horizontalButtonBar.layer.borderColor = UIColor.blue.cgColor
        horizontalButtonBar.layer.borderWidth = 1.0
    }
    
    private func setupVertical() {
        verticalButtonBar.delegate = self
        verticalButtonBar.config = KUIButtonBarConfig(numberOfButtons: 3, rowCount: 3, columnCount: 1)
        
//        modify config property
//        verticalButtonBar.config.numberOfButtons = 4
//        verticalButtonBar.config.rowCount = 4
        
        verticalButtonBar.refresh()
        
        verticalButtonBar.layer.borderColor = UIColor.blue.cgColor
        verticalButtonBar.layer.borderWidth = 1.0
    }
    
    private func setupMix() {
        mixButtonBar.delegate = self
        mixButtonBar.config = KUIButtonBarConfig(toggle: true, numberOfButtons: 6, rowCount: 2, columnCount: 3, horizontalGap: 3.0, verticalGap: 3.0, defaultSelectedIndex: 0)
        mixButtonBar.refresh()
        
        mixButtonBar.layer.borderColor = UIColor.blue.cgColor
        mixButtonBar.layer.borderWidth = 1.0
    }

    // Required
    func render(_ buttonBar: KUIButtonBar, button: UIButton, index: Int) {
        print("render::index : \(index)")
        
        let titles = ["A", "B", "C", "D", "E", "F", "G"]
        button.setTitle(titles[index], for: [])
        button.setTitleColor(UIColor.black, for: [])
        button.setTitleColor(UIColor.magenta , for: .selected)
        
        button.layer.borderColor = UIColor.red.cgColor
        button.layer.borderWidth = 1.0
    }
    
    func click(_ buttonBar: KUIButtonBar, button: UIButton, index: Int) {
        print("click::index : \(index)")
    }
    
    func selected(_ buttonBar: KUIButtonBar, button: UIButton, index: Int) {
        print("selected::index : \(index)")
    }
}


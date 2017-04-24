//
//  KUIButtonBarTests.swift
//  KUIButtonBarTests
//
//  Created by kofktu on 2017. 4. 24..
//  Copyright © 2017년 Kofktu. All rights reserved.
//

import XCTest
import KUIButtonBar

class KUIButtonBarTests: XCTestCase {
    
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func test_numberOfButtons() {
        let buttonBar = KUIButtonBar()
        buttonBar.config = KUIButtonBarConfig(numberOfButtons: 4)
        
        XCTAssertEqual(buttonBar.config.numberOfButtons, 4)
        XCTAssertEqual(buttonBar.config.rowCount, 1)
        XCTAssertEqual(buttonBar.config.columnCount, 4)
        
        buttonBar.config.set(columnCount: 3)
        
        XCTAssertEqual(buttonBar.config.numberOfButtons, 3)
        XCTAssertEqual(buttonBar.config.rowCount, 1)
        XCTAssertEqual(buttonBar.config.columnCount, 3)
        
        buttonBar.config.set(rowCount: 2, columnCount: 3)
        
        XCTAssertEqual(buttonBar.config.numberOfButtons, 6)
        XCTAssertEqual(buttonBar.config.rowCount, 2)
        XCTAssertEqual(buttonBar.config.columnCount, 3)
    }
}

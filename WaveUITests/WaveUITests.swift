//
//  WaveUITests.swift
//  WaveUITests
//
//  Created by Georgi Malkhasyan on 8/19/20.
//  Copyright © 2020 Malkhasyan. All rights reserved.
//

import XCTest

class WaveUITests: XCTestCase {
    
    var app: XCUIApplication!

    override func setUpWithError() throws {
        app = XCUIApplication()
        continueAfterFailure = false

    }

    override func tearDownWithError() throws {
      app = nil
    }

    
    



}

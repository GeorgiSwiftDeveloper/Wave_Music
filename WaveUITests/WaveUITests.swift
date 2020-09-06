//
//  WaveUITests.swift
//  WaveUITests
//
//  Created by Georgi Malkhasyan on 8/19/20.
//  Copyright © 2020 Malkhasyan. All rights reserved.
//

import XCTest
@testable import Wave
class WaveUITests: XCTestCase {
    
    var app: XCUIApplication!

    override func setUpWithError() throws {
        app = XCUIApplication()
        continueAfterFailure = false

    }

    override func tearDownWithError() throws {
      app = nil
    }

    func testTabBar_Controller() {
        
        app.launch()
        
        app.tabBars.buttons.element(boundBy: 0).tap()
        XCTAssertTrue(app.isDisplayLibraryView, "MyLibraryView is not available when tabbar clicked")
        
//        app.tabBars.buttons.element(boundBy: 1).tap()
//        XCTAssertTrue(app.isDisplayGenresList, "GenreListView is not available when tabbar clicked")
        
        app.tabBars.buttons.element(boundBy: 2).tap()
        XCTAssertTrue(app.isDisplaySearchView, "SearchView is not available when tabbar clicked")
        
        app.tabBars.buttons.element(boundBy: 3).tap()
        XCTAssertTrue(app.isDisplayPlaylistView, "PlayListView is not available when tabbar clicked")
    }
    
    
    func testSearchYouTube_When_It_Was_Tapped(){
        app.launch()
        app.tabBars.buttons.element(boundBy: 2).tap()
        app.searchFields.element.tap()
        app.searchFields.element.typeText("Eminem")
        XCTAssert(app.keyboards.buttons["search"].exists, "The keyboard with name search is not found")
        app.keyboards.buttons["search"].tap()
    }
    
    



}


extension XCUIApplication {
    
    var isDisplayLibraryView: Bool {
        return otherElements["MyLibrary"].exists
    }
    
    
    var isDisplayGenresList: Bool  {
        return otherElements["GenreList"].exists
    }
    
    var isDisplaySearchView: Bool  {
           return otherElements["SearchView"].exists
       }
    
    var isDisplayPlaylistView: Bool  {
           return otherElements["PlaylistView"].exists
       }
}

//
//  InventoryUITestsCS3260.swift
//  InventoryUITests
//
//  Created by Ted Cowan on 10/13/18.
//  Copyright © 2018 Ted Cowan. All rights reserved.
//

import XCTest

class InventoryUITestsCS3260: XCTestCase {
    
    var app: XCUIApplication!
    let sampleItems = [("Item one", "This is item one"),
                       ("Item two", "This is item two"),
                       ("Item three", "This is item three"),
                       ]
    
    override func setUp() {
        super.setUp()
        
        // Put setup code here. This method is called before the invocation of each test method in the class.
        
        // In UI tests it is usually best to stop immediately when a failure occurs.
        continueAfterFailure = true
        // UI tests must launch the application that they test. Doing this in setup will make sure it happens for each test method.
        app = XCUIApplication()
        app.launch()

        // In UI tests it’s important to set the initial state - such as interface orientation - required for your tests before they run. The setUp method is a good place to do this.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testVerifyLabelsAndTable() {
        // Use recording to get started writing UI tests.
        // Use XCTAssert and related functions to verify your tests produce the correct results.
        XCTAssert(app.navigationBars["Inventory"].exists, "Screen not titled \"Inventory\"")
        XCTAssert(app.navigationBars["Inventory"].buttons["Add"].exists, "Add button not found")
        XCTAssert(app.tables.element(boundBy: 0).exists, "No table found on opening screen")

    }
    
    func testAddItems() {
        addItems(items: sampleItems, application: app)
    
    }
    
    func testEditItem() {
        var testItems = [("Item one", "This is item one"),
                           ("Item two", "This is item two"),
                           ("Item three", "This is item three"),
                           ]

        let tableView = app.tables.element(boundBy: 0)
        
        addItems(items: testItems, application: app)
                
        let buttons = tableView.buttons
        XCTAssert(buttons.element(boundBy: 1).exists, "Second cell to be deleted not found")
        let button = buttons.element(boundBy: 1)
        XCTAssert(button.label ==  "chevron", "Table entry 1 disclosure button not found")

        button.forceTapElement()
        XCTAssert(app.navigationBars["Edit Item"].exists, "Screen not titled \"Edit Item\"")
        XCTAssert(app.navigationBars["Edit Item"].buttons["Inventory"].exists, "Inventory back button not found")
        XCTAssert(app.navigationBars["Edit Item"].buttons["Save"].exists, "Save button not found")
        XCTAssert(app.textFields["editShortDescription"].exists, "No textField found with identifier addShortDescription in Edit Item")
        XCTAssert(app.textViews["editLongDescription"].exists, "No textView found with identifier addLongDescription in Edit Item")

        let addedText = " more text added here"
        app.textFields["editShortDescription"].tap()
        usleep(250000)  // now required with iOS 13
        app.textFields["editShortDescription"].tap()
        sleep(3)
        let selectAll = app.menuItems["Select All"].exists
        if selectAll {
            app.menuItems["Select All"].tap()
            app.menuItems["Cut"].tap()
            app.typeText(testItems[1].0 + addedText)
            app.textViews["editLongDescription"].tap()
            usleep(250000)  // now required with iOS 13
            app.textViews["editLongDescription"].tap()
            app.menuItems["Select All"].tap()
            app.menuItems["Cut"].tap()
            app.textViews["editLongDescription"].typeText(testItems[1].1 + addedText)
            app.navigationBars["Edit Item"].buttons["Save"].tap()
        } else {
            app.menuItems.element.tap()  // get rid of the Paste button
            //sleep(3)
            app.navigationBars["Edit Item"].buttons["Inventory"].tap()
            //sleep(3)
        }

        let cells = tableView.children(matching: .cell)
        testItems[1].0 = testItems[1].0 + addedText
        testItems[1].1 = testItems[1].1 + addedText

        for i in 0..<sampleItems.count {
            let texts = cells.element(boundBy: i).staticTexts
            let titleFound = texts.element(boundBy: 0).label
            let subTitleFound = texts.element(boundBy: 1).label
            XCTAssert(titleFound == testItems[i].0, "Table cell \(i) title contains \"\(titleFound)\" but should contain \"\(testItems[i].0)\"")
            XCTAssert(subTitleFound == testItems[i].1, "Table cell \(i) subTitle contains \"\(subTitleFound)\" but should contain \"\(testItems[i].1)\"")
        }
    }
    
    func testDeleteItem() {
        var someItems = [("Item one", "This is item one"),
                           ("Item two", "This is item two"),
                           ("Item three", "This is item three"),
                           ]

        
        let tableView = app.tables.element(boundBy: 0)
        addItems(items: sampleItems, application: app)

        let itemToDelete = 1
                
        let cells = tableView.cells
        let cell = cells.element(boundBy: itemToDelete)
        cell.swipeLeft()
        XCTAssert(cell.buttons["Delete"].exists, "Second cell does not include a Swipe to Delete button")
        cell.buttons["Delete"].tap()
        
        someItems.remove(at: itemToDelete)
        
        let rowCount = tableView.cells.count
        XCTAssert(rowCount == someItems.count, "After Delete, table should have \(someItems.count+1) rows, but found \(rowCount+1)")

        for i in 0..<someItems.count {
            let texts = cells.element(boundBy: i).staticTexts
            let titleFound = texts.element(boundBy: 0).label
            let subTitleFound = texts.element(boundBy: 1).label
            XCTAssert(titleFound == someItems[i].0, "Table cell \(i) title contains \"\(titleFound)\" but should contain \"\(someItems[i].0)\"")
            XCTAssert(subTitleFound == someItems[i].1, "Table cell \(i) title contains \"\(subTitleFound)\" but should contain \"\(someItems[i].1)\"")

        }
    }
    
    func testBackButtonDoesNotSave() {
        let oneItem = [("Item one", "This is item one"),
                           ]


        let tableView = app.tables.element(boundBy: 0)

        addItems(items: oneItem, application: app, save: false)
        app.navigationBars["Add New Item"].buttons["Inventory"].tap()

        let rowCount = tableView.cells.count
        XCTAssert(rowCount == 0, "Table should have no rows in it, but found \(rowCount)")
    }
    
    func addItems(items:[(String,String)], application:XCUIApplication, save:Bool = true) {
        let tableView = app.tables.element(boundBy: 0)

        for i in 0..<items.count {
            sleep(2)
            _ = app.navigationBars["Inventory"].buttons["Add"].waitForExistence(timeout: 2)
            app.navigationBars["Inventory"].buttons["Add"].tap()

            XCTAssert(app.navigationBars["Add New Item"].exists, "Screen not titled \"Add New Item\"")
            XCTAssert(app.navigationBars["Add New Item"].buttons["Inventory"].exists, "Inventory back button not found in Add New Item")
            XCTAssert(app.navigationBars["Add New Item"].buttons["Save"].exists, "Save button not found in Add New Item")
            XCTAssert(app.textFields["addShortDescription"].exists, "No textField found with identifier addShortDescription in Add New Item")
            XCTAssert(app.textViews["addLongDescription"].exists, "No textView found with identifier addLongDescription in Add New Item")
            
            XCTAssert(app.textFields["addShortDescription"].title == "", "addShortDescription is not empty on entry to Add New Item")
            XCTAssert(app.textViews["addLongDescription"].title == "", "addLongDescription is not empty on entry to Add New Item")

            app.textFields["addShortDescription"].tap()
            app.textFields["addShortDescription"].typeText(items[i].0)
            UIPasteboard.general.string = items[i].1
            app.textViews.element.tap()
            sleep(3)
            app.textViews.element.doubleTap()
            sleep(4)
            _ = app.menuItems.element(boundBy: 0).waitForExistence(timeout: 3)
            app.menuItems.element(boundBy: 0).tap()
            sleep(4)
            if save == true {
                _ = app.navigationBars["Add New Item"].buttons["Save"].waitForExistence(timeout: 2)
                app.navigationBars["Add New Item"].buttons["Save"].tap()
            }

        }
        if save == true {
            let rowCount = tableView.cells.count
            XCTAssert(rowCount == items.count, "Table should have \(items.count) rows, but found \(rowCount)")
            let cells = tableView.children(matching: .cell)
            for i in 0..<items.count {
                let texts = cells.element(boundBy: i).staticTexts
                let titleFound = texts.element(boundBy: 0).label
                let subTitleFound = texts.element(boundBy: 1).label
                print("\(i): \(titleFound) \(subTitleFound)")
                XCTAssert(titleFound == items[i].0, "Table cell \(i) title contains \"\(titleFound)\" but should contain \"\(items[i].0)\"")
                XCTAssert(subTitleFound == items[i].1, "Table cell \(i) subTitle contains \"\(subTitleFound)\" but should contain \"\(items[i].1)\"")
                let buttons = cells.element(boundBy: i).buttons
                let button = buttons.element(boundBy: 0)
                XCTAssert(button.label ==  "chevron", "Table entry \(i) disclosure button not found")
                
            }
        }
    }
}

extension XCUIElement {
    func forceTapElement() {
        if self.isHittable {
            self.tap()
        }
        else {
            let coordinate: XCUICoordinate = self.coordinate(withNormalizedOffset: CGVector(dx:0.0, dy:0.0))
            coordinate.tap()
        }
    }
}

//
//  TestBotUITests.swift
//  TestBotUITests
//
//  Created by Vamsidhar Vannam on 30/04/24.
//

import XCTest

final class TestBotUITests: XCTestCase {
    
    let app = XCUIApplication()
    var currentScreen: String = ""
    var lastTappedElement: String = ""
    var screens = [XCScreen]()
    
    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
        
        // In UI tests it is usually best to stop immediately when a failure occurs.
        continueAfterFailure = false
        
        // In UI tests it’s important to set the initial state - such as interface orientation - required for your tests before they run. The setUp method is a good place to do this.
    }
    
    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }
    
    func testExample() throws {
        // UI tests must launch the application that they test.
        app.launch()
        checkIdentifier()
    }
    
    func checkIdentifier() {
        // Iterate through all elements and find the identifier
        for element in app.descendants(matching: .any).allElementsBoundByIndex {
            if element.identifier.lowercased().contains("identifier:") {
                let pageID = element.identifier
                if currentScreen == "" {
                    let screen = XCScreen(screenID: pageID, parent: "", source: "")
                    screens.append(screen)
                    currentScreen = pageID
                    captureScreen(pageID: pageID)
                    loopThroughLabels()
                    checkNavigation()
                } else {
                    navHappened(oldScreen: currentScreen, newScreen: pageID)
                }
                break
            }
        }
    }
    
    func loopThroughLabels() {

           // Access all static text elements in the app
           let allStaticTexts = app.staticTexts.allElementsBoundByAccessibilityElement

           // Filter UILabels from all static text elements
           let allLabels = allStaticTexts.filter { $0.elementType == .staticText }

           // Loop through all UILabels
           for label in allLabels {
               // Perform actions or assertions on each label
               print("\(currentScreen) Label text: \(label.label)")
               // You can add more actions/assertions here
           }
       }
    
    func navHappened(oldScreen: String, newScreen: String) {
        let screen = XCScreen(screenID: newScreen, parent: oldScreen, source: lastTappedElement)
        screens.append(screen)
        currentScreen = newScreen
        captureScreen(pageID: oldScreen + ":" + newScreen)
        checkNavigation()
        if newScreen == "Identifier: Third Page" {
            getScreenJSON()
        }
    }
    
    func getScreenJSON() {
        let encoder = JSONEncoder()

        do {
            // Encode the array of structs into JSON data
            let jsonData = try encoder.encode(screens)

            // Convert JSON data to String
            if let jsonString = String(data: jsonData, encoding: .utf8) {
                print("jsonString"+jsonString)
            } else {
                print("Error converting JSON data to string")
            }
        } catch {
            print("Error encoding array of structs to JSON: \(error)")
        }
    }
    
    
    func checkNavigation() {
        
        // Access all buttons in the app
                let allButtons = app.buttons.allElementsBoundByAccessibilityElement

                // Loop through all buttons
                for button in allButtons {
                    // Perform actions or assertions on each button
                    if button.identifier == "NavButton" {
                        button.tap()
                        lastTappedElement = "\(currentScreen) NavButton"
                        checkIdentifier()
                    }
                    // You can add more actions/assertions here
                }
        
    }
    
    func captureScreen(pageID: String) {
        let screenshot = app.screenshot()
        let screenshotData = screenshot.pngRepresentation
        let customFilename = "\(pageID).png"
        guard let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first else {
            XCTFail("Failed to get Documents directory")
            return
        }
        
        // Append custom filename to the Documents directory path
        let fileURL = documentsDirectory.appendingPathComponent(customFilename)
        
        do {
            // Write the PNG data to the file
            try screenshotData.write(to: fileURL)
            print("Screenshot saved at: \(fileURL)")
        } catch {
            XCTFail("Failed to save screenshot: \(error.localizedDescription)")
        }
    }
    
    func testLaunchPerformance() throws {
        if #available(macOS 10.15, iOS 13.0, tvOS 13.0, watchOS 7.0, *) {
            // This measures how long it takes to launch your application.
            measure(metrics: [XCTApplicationLaunchMetric()]) {
                XCUIApplication().launch()
            }
        }
    }
}


struct XCScreen: Codable {
    let screenID: String
    let parent: String
    let source: String
}

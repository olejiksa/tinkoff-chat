//
//  ThemesServiceTests.swift
//  TinkoffChatTests
//
//  Created by Олег Самойлов on 26/05/2018.
//  Copyright © 2018 Oleg Samoylov. All rights reserved.
//

import XCTest
@testable import TinkoffChat

class ThemesServiceTests: XCTestCase {
    
    /// Service layer object to test
    private var themesService: IThemesService!
    
    /// Themes
    private let themes: [UIColor] = [.red,
                                     .orange,
                                     .yellow,
                                     .green,
                                     .cyan,
                                     .blue,
                                     .purple]
    
    // MARK: - Setting up of test environment
    
    override func setUp() {
        super.setUp()
        
        let themesManager: IThemesManager = ThemesManager()
        themesService = ThemesService(themesManager: themesManager)
    }
    
    override func tearDown() {
        themesService = nil
        
        super.tearDown()
    }
    
    // MARK: - Tests
    
    func testThat_initialThemeIsNil() {
        // Case when app uses default theme initally
        
        // given
        let theme = themesService.current
        
        // when & then
        XCTAssertNil(theme)
    }
    
    func testThat_hasRandomThemeSelected() {
        // Case when app theme was saved and loaded
        
        // given
        let theme = themes[random(0..<themes.count)]
        
        loadAndSave(theme)
    }
    
    func testThat_randomThemeIsCorrect() {
        /* Case when app theme was just saved
         * Compares "input theme" with current on the moment
         * when it will be selected */
 
        // given
        let theme = themes[random(0..<themes.count)]
        
        save(theme)
    }
    
    func testThat_canAnyThemeBeLoadedAndSaved() {
        // given
        // See up list of themes...
        
        for everyTheme in themes {
            loadAndSave(everyTheme)
        }
    }
    
    func testThat_canAnyThemeBeSaved() {
        // given
        // See up list of themes...
        
        for everyTheme in themes {
            save(everyTheme)
        }
    }
    
    func testThat_invertedLightnessIsNotSame() {
        // given
        let significance = 0.10
        var commonCounter = 0
        var positiveCounter = 0
        
        for color in themes {
            let promise = expectation(description: "Theme is saved")
            
            // when
            themesService.invert(color) { invertable in
                promise.fulfill()
                
                commonCounter += 1
                if !invertable {
                    positiveCounter += 1
                }
            }
            
            wait(for: [promise], timeout: 2)
        }
        
        let probability = Double(positiveCounter / commonCounter)
            
        // then
        XCTAssertLessThanOrEqual(probability, significance)
    }
    
    // MARK: - Auxiliary methods
    
    private func random(_ range: Range<Int>) -> Int {
        let low = range.lowerBound
        let up = range.upperBound
        return low + Int(arc4random_uniform(UInt32(up - low)))
    }
    
    private func loadAndSave(_ theme: UIColor) {
        let promiseForSave = expectation(description: "Theme is saved")
        let promiseForLoad = expectation(description: "Theme is loaded")

        // when
        themesService.save(theme) {
            promiseForSave.fulfill()
            self.themesService.current = nil // reset after save
        }
        
        wait(for: [promiseForSave], timeout: 5)
        
        themesService.load() { // load saved theme
            promiseForLoad.fulfill()
            
            guard let newTheme = self.themesService.current else {
                XCTFail()
                return
            }
            
            // then
            XCTAssertTrue(theme.isEqual(newTheme))
        }
        
        wait(for: [promiseForLoad], timeout: 5)
    }
    
    private func save(_ theme: UIColor) {
        let promise = expectation(description: "Theme is saved")
        
        // when
        themesService.save(theme) {
            promise.fulfill()
            
            guard let newTheme = self.themesService.current else {
                XCTFail()
                return
            }
            
            // then
            XCTAssertTrue(theme.isEqual(newTheme))
        }
        
        wait(for: [promise], timeout: 5)
    }
    
}

//
//  ThemesViewControllerTests.swift
//  TinkoffChatTests
//
//  Created by Олег Самойлов on 27/05/2018.
//  Copyright © 2018 Oleg Samoylov. All rights reserved.
//

import XCTest
@testable import TinkoffChat

class ThemesViewControllerTests: XCTestCase {
    
    /// Presentation layer object to test
    private var controllerUnderTest: ThemesViewController!
    
    /// Themes
    private let themes: [UIColor] = [#colorLiteral(red: 0.4745098054, green: 0.8392156959, blue: 0.9764705896, alpha: 1), #colorLiteral(red: 0.721568644, green: 0.8862745166, blue: 0.5921568871, alpha: 1), #colorLiteral(red: 1, green: 0.9572783113, blue: 0.3921568627, alpha: 1)]
    
    /// Mocks & stubs
    private var themesMock: ThemesMock!
    
    // MARK: - Setting up of test environment
    
    override func setUp() {
        themesMock = ThemesMock()
        
        let manager: IThemesManager = ThemesManager()
        let service: IThemesService = ThemesService(themesManager: manager)
        let model: IThemesModel = ThemesModel(theme1: themes[0], theme2: themes[1], theme3: themes[2], themesService: service, closure: { vc, color in
            vc.view.backgroundColor = color
        })
        
        controllerUnderTest = ThemesViewController(model: model)
        controllerUnderTest.mock = themesMock
        
        _ = controllerUnderTest.view
        
        super.setUp()
    }
    
    override func tearDown() {
        controllerUnderTest = nil
        themesMock = nil
        
        super.tearDown()
    }
    
    // MARK: - Tests
    
    func testThat_selectionWorks() {
        guard let buttons = controllerUnderTest.buttonsWithTag else {
            XCTFail()
            return
        }
        
        for i in 0..<buttons.count {
            // given
            let expectedFirstTag = i + 1
            
            // when
            controllerUnderTest.didThemeButtonTap(buttons[i])
            
            // then
            XCTAssertTrue(themesMock.methodCalled)
            XCTAssertEqual(buttons[i], themesMock.methodParameter)
            XCTAssertEqual(expectedFirstTag, themesMock.stub)
        }
    }
    
    func testThat_themeMayBeChanged() {
        // Case for >=2 unique theme colors
        
        // given
        let current = controllerUnderTest.view.backgroundColor
        
        // when
        for color in themes {
            if !color.isEqual(current) {
                // then
                return
            }
        }
        
        // then
        XCTFail()
    }
    
    // MARK: - Auxiliary methods
    
    private func random(_ range: Range<Int>) -> Int {
        let low = range.lowerBound
        let up = range.upperBound
        return low + Int(arc4random_uniform(UInt32(up - low)))
    }
    
    // MARK: - Mocks
    
    class ThemesMock: ThemesSelector {
        
        var stub: Int!
        
        var methodCalled = false
        var methodParameter: UIButton!
        
        var counter = 0
        
        // MARK: - ThemesSelector
        
        func didThemeButtonTap(_ sender: UIButton) {
            methodCalled = true
            methodParameter = sender
            
            counter += 1
            
            stub = sender.tag
        }
    }
    
}

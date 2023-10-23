//
//  PriceChangeTests.swift
//  BlockCanvasTests
//
//  Created by Renee Hsu on 2023/10/22.
//

import XCTest
@testable import Block_Canvas

final class PriceChangeTests: XCTestCase {
    var sut: CryptoPageViewController!
    
    override func setUpWithError() throws {
        try super.setUpWithError()
        let storyboard = UIStoryboard(name: "Crypto", bundle: nil)
        sut = storyboard.instantiateViewController(withIdentifier: "CryptoPageViewController") as? CryptoPageViewController
    }
    
    override func tearDownWithError() throws {
        sut = nil
        try super.tearDownWithError()
    }
    
    func testPositivePriceChangeConfiguration() {
        let priceChange: Double = 5.0
        
        let config = sut.configurationForPriceChange(priceChange)
        
        XCTAssertEqual(config.title, "5.0%")
        XCTAssertEqual(config.image, UIImage(systemName: "arrowtriangle.up.fill", withConfiguration: UIImage.SymbolConfiguration(pointSize: 8)))
        XCTAssertEqual(config.background.backgroundColor, .systemGreen)
    }
    
    func testNegativePriceChangeConfiguration() {
        let priceChange: Double = -5.0

        let config = sut.configurationForPriceChange(priceChange)
        
        XCTAssertEqual(config.title, "-5.0%")
        XCTAssertEqual(config.image, UIImage(systemName: "arrowtriangle.down.fill", withConfiguration: UIImage.SymbolConfiguration(pointSize: 8)))
        XCTAssertEqual(config.background.backgroundColor, .systemPink)
    }
    
    func testZeroPriceChangeConfiguration() {
        let priceChange: Double = 0.0

        let config = sut.configurationForPriceChange(priceChange)

        XCTAssertEqual(config.title, "0.0%")
        XCTAssertNil(config.image)
        XCTAssertEqual(config.background.backgroundColor, .black)
    }
}

//
//  ResponseFormatterTest.swift
//  BlockCanvasTests
//
//  Created by Renee Hsu on 2023/10/22.
//

import XCTest
@testable import Block_Canvas

final class ResponseFormatterTest: XCTestCase {
    var sut: DiscoverAPIService!
    
    override func setUpWithError() throws {
        try super.setUpWithError()
        sut = DiscoverAPIService()
    }
    
    override func tearDownWithError() throws {
        sut = nil
        try super.tearDownWithError()
    }
    
    func testRecommendationResponseFormatter() {
        // Given: A "bad" response
        let badResponse = """
        - CollectionOne
        CollectionTwo
        -CollectionThree
        - Collection Four With Spaces
        """
        
        // When: Passing the "bad" response to the formatter
        let result = sut.formatRecommendationResponse(badResponse)
        
        // Then: Check the result
        let expectedResult = ["CollectionOne", "CollectionTwo", "CollectionThree", "CollectionFourWithSpaces"]
        XCTAssertEqual(result, expectedResult, "The formatter did not handle the bad response correctly.")
    }
    
}

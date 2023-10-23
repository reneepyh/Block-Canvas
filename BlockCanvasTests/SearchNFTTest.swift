//
//  BlockCanvasTests.swift
//  BlockCanvasTests
//
//  Created by Renee Hsu on 2023/10/21.
//

import XCTest
@testable import Block_Canvas

final class SearchNFTTest: XCTestCase {
    var sut: DiscoverAPIService!
    var mockSession: MockURLSession!
    
    override func setUpWithError() throws {
        try super.setUpWithError()
        mockSession = MockURLSession()
        sut = DiscoverAPIService(session: mockSession)
    }
    
    override func tearDownWithError() throws {
        sut = nil
        try super.tearDownWithError()
    }
    
    func testNoDataResponse() {
        mockSession.stubbedData = nil
        mockSession.stubbedError = nil
        
        let expectation = self.expectation(description: "No Data Response Test")
        sut.searchNFT(keyword: "test", offset: 0) { result in
            switch result {
            case .success:
                print("Received result: \(result)")
                XCTFail("Expected failure when no data is returned, but got success instead.")
            case .failure(let error as NSError):
                XCTAssertEqual(error.code, -1)
                XCTAssertEqual(error.domain, "")
                XCTAssertEqual(error.userInfo[NSLocalizedDescriptionKey] as? String, "No data.")
            }
            expectation.fulfill()
        }
        
        wait(for: [expectation], timeout: 3.0)
    }
}

class MockURLSession: URLSession {
    var stubbedError: Error?
    var stubbedData: Data?
    
    override func dataTask(with request: URLRequest, completionHandler: @escaping (Data?, URLResponse?, Error?) -> Void) -> URLSessionDataTask {
        return MockURLSessionDataTask {
            completionHandler(self.stubbedData, nil, self.stubbedError)
        }
    }
}

class MockURLSessionDataTask: URLSessionDataTask {
    private let closure: () -> Void
    
    init(closure: @escaping () -> Void) {
        self.closure = closure
    }
    
    override func resume() {
        closure()
    }
}

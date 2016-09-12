//
//  RegisterRequestTests.swift
//  SecurityKeyBLE
//
//  Created by Benjamin P Toews on 9/11/16.
//  Copyright © 2016 GitHub. All rights reserved.
//

import XCTest

class RegisterRequestTests: XCTestCase {
    func testRoundTrip() throws {
        let c = try SHA256.digest("world".dataUsingEncoding(NSUTF8StringEncoding)!)
        let a = try SHA256.digest("hello".dataUsingEncoding(NSUTF8StringEncoding)!)
        
        let r1 = RegisterRequest(challengeParameter: c, applicationParameter: a)
        let r2 = try RegisterRequest(raw: r1.raw)
        
        XCTAssertEqual(r1.challengeParameter, r2.challengeParameter)
        XCTAssertEqual(r1.applicationParameter, r2.applicationParameter)
    }
}
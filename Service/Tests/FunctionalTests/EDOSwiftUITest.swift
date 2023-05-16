//
// Copyright 2018 Google Inc.
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
//      http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.
//

import Foundation
import XCTest
class EDOSwiftUITest: XCTestCase {
  @discardableResult
  func launchAppWithPort(port: Int, value: Int) -> XCUIApplication {
    let application = XCUIApplication()
    application.launchArguments = [
      "-servicePort", String(format: "%d", port), String("-dummyInitValue"),
      String(format: "%d", value),
    ]
    application.launch()
    return application
  }

  func testRemoteInvocation() {
    launchAppWithPort(port: 1234, value: 10)
    let service = EDOHostService(port: 2234, rootObject: self, queue: DispatchQueue.main)
    let hostPort = EDOHostPort(port: 1234, name: nil, deviceSerialNumber: nil)
    let testDummy = EDOClientService<EDOTestDummyExtension>.rootObject(with: hostPort)
    let swiftClass = testDummy.returnProtocol()
    XCTAssertEqual(swiftClass.returnString(), "Swift String")

    XCTAssertEqual(
      swiftClass.returnWithBlock { (str: NSString) in
        XCTAssertEqual(str, "Block")
        return swiftClass
      }, "Swift StringBlock")
    service.invalidate()
  }

  /// Verifies eDO can make remote calls through Swift @objc methods.
  func testRemoteInvocationWithParameter() throws {
    launchAppWithPort(port: 1234, value: 10)
    let service = EDOHostService(port: 2234, rootObject: self, queue: DispatchQueue.main)
    let hostPort = EDOHostPort(port: 1234, name: nil, deviceSerialNumber: nil)
    let testDummy = EDOClientService<EDOTestDummyExtension>.rootObject(with: hostPort)
    let swiftClass = testDummy.returnProtocol()
    let data = ["a": 1, "b": 2] as NSDictionary
    XCTAssertEqual(swiftClass.returnWithDictionarySum(data: data.passByValue()), 3)
    XCTAssertEqual(swiftClass.returnWithDictionarySum(data: data), 3)
    let testingStruct = EDOTestSwiftStruct(intValues: [1, 2, 3, 4, 5])
    let codedResult = try swiftClass.sumFrom(codedStruct: testingStruct.eDOCodableVariable)
    let result: [Int] = try codedResult.unwrap()
    XCTAssertEqual(result.first, 15)
    service.invalidate()
  }

  /// Verifies Swift array can be passed across the process and used by other Swift code.
  func testRemoteSwiftArray() {
    launchAppWithPort(port: 1234, value: 10)
    let service = EDOHostService(port: 2234, rootObject: self, queue: DispatchQueue.main)
    let hostPort = EDOHostPort(port: 1234, name: nil, deviceSerialNumber: nil)
    let testDummy = EDOClientService<EDOTestDummyExtension>.rootObject(with: hostPort)
    let swiftClass = testDummy.returnProtocol()
    let target = swiftClass.returnSwiftArray()
    XCTAssertNotNil(target[0])
    XCTAssertNotNil(target[1])
    service.invalidate()
  }

  /// Verifies Swift error is propagated through `throw`, and can be accessed through `localizedDescription`.
  func testRemoteSwiftError() {
    launchAppWithPort(port: 1234, value: 10)
    let service = EDOHostService(port: 2234, rootObject: self, queue: DispatchQueue.main)
    let hostPort = EDOHostPort(port: 1234, name: nil, deviceSerialNumber: nil)
    let testDummy = EDOClientService<EDOTestDummyExtension>.rootObject(with: hostPort)
      .returnProtocol()
    var propagatedError: AnyObject? = nil

    do {
      try testDummy.propagateError(withCustomizedDescription: false)
    } catch EDOTestError.intentionalError {
      XCTFail("Remote Swift error is identified locally, which is supported before")
    } catch {
      propagatedError = error as AnyObject
    }
    XCTAssertTrue(propagatedError?.localizedDescription?.contains("EDOTestError") ?? false)

    do {
      try testDummy.propagateError(withCustomizedDescription: true)
    } catch EDOCustomizedTestError.intentionalError {
      XCTFail("Remote Swift error is identified locally, which is supported before")
    } catch {
      propagatedError = error as AnyObject
    }
    XCTAssertEqual(
      propagatedError?.localizedDescription,
      "An override for EDOCustomizedTestError.intentionalError")

    service.invalidate()
  }
}

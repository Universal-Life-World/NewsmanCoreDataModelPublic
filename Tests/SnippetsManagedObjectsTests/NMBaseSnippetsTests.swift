//
//  NMBaseSnippetsTests.swift
//  
//
//  Created by Anton2016 on 08.01.2022.
//

import XCTest
import NewsmanCoreDataModel

class NMBaseSnippetsTests: XCTestCase
{
 static var model: NMCoreDataModel!
 var sut: NMBaseSnippet!
 
 override class func setUp()
 {
  model = NMCoreDataModel(name: "Newsman", for: .inMemorySQLight)
 }
 
 override func setUp()
 {
  
 }
 
 override func setUpWithError() throws {}

 override func tearDownWithError() throws { }
 
 override class func tearDown()
 {
  model = nil
 }
 
 private func snippetDefaultPropertiesInitialSetupCheckup(for sut: NMBaseSnippet) throws
 {
  let moc = try XCTUnwrap(sut.managedObjectContext)
  let psc = try XCTUnwrap(moc.persistentStoreCoordinator)
  let mom = psc.managedObjectModel
  let sutEntityName = String(describing: type(of: sut))
  let sut_entity = try XCTUnwrap(mom.entities.first{$0.name == sutEntityName})
 
  sut_entity.attributesByName.filter{!$0.value.isOptional}.forEach
  {
 
   let attrDefaultValue = $0.value.defaultValue
 
   let sutValue = sut.value(forKey: $0.key)
  
   switch (attrDefaultValue, sutValue)
   {
    case (let modValue as Bool,    let sutValue as Bool):    XCTAssertEqual(modValue, sutValue)
    case (let modValue as Int16,   let sutValue as Int16):   XCTAssertEqual(modValue, sutValue)
    case (let modValue as UUID,    let sutValue as UUID):    XCTAssertEqual(modValue, sutValue)
    case (let modValue as NSValue, let sutValue as NSValue): XCTAssertEqual(modValue, sutValue)
    case (let modValue as Double,  let sutValue as Double):  XCTAssertEqual(modValue, sutValue)
    case (let modValue as String,  let sutValue as String):  XCTAssertEqual(modValue, sutValue)
    case (let modValue as Date,    let sutValue as Date):    XCTAssertEqual(modValue, sutValue)
    case ( nil , nil ) : break
    default:
     XCTFail("UNKNOWN MODEL ATTRIBUTE TYPE!")
   
   }
   
  }
 }
 
 func testSnippetCreatedCorrectlyUsingGenericNewWithBlockModelMethod() throws
 {
  let expectation = expectation(description: "NMBaseSnippet new test")
  Self.model.new{(base: NMPhotoSnippet) -> () in
   let now = Date().timeIntervalSinceReferenceDate
   XCTAssertNotNil(base.managedObjectContext)
   XCTAssertNotNil(base.id)
   XCTAssertNil(base.trashedTimeStamp)
   XCTAssertNil(base.ck_metadata)
   
   let created = try XCTUnwrap(base.date, "Snippet Date Must be set up on creation")
   let modified = try XCTUnwrap(base.lastModifiedTimeStamp, "Snippet Last Modified Date Must be set up on creation")
   let accessed = try XCTUnwrap(base.lastAccessedTimeStamp, "Snippet Last Accessed Date Must be set up on creation")
  
   //XCTAssertTrue(base.type == .base, "Snippet Date Must be Base Snippet!")
   
   XCTAssertTrue(created == modified && created == accessed)
  
   XCTAssertEqual(created.timeIntervalSinceReferenceDate, now, accuracy: 0.01)
   XCTAssertNotNil(base.url, "Base Snippet cannot have file storage")
   
   expectation.fulfill()
  }
  waitForExpectations(timeout: 0.01)
 }

    
}

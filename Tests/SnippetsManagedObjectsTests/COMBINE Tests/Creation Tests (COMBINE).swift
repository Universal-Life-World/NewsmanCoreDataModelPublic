import XCTest
import NewsmanCoreDataModel
import CoreLocation

@available(iOS 14.0, *)
extension NMBaseSnippetsCombineAPITests {
 
 func test_Snippets_CREATED_correctly_without_persistance_using_Combine_API() {
  
  //ARRANGE...
  let SUTS_COUNT = 6
  let PERSISTED = false
  var SUTS = [NMBaseSnippet]()
  
  let expectations = NMBaseSnippet.SnippetType.allCases.map{ snippetType -> XCTestExpectation in
   
   let expectation = XCTestExpectation(description: "All Snippets Types Creation with Combine")
   
   switch snippetType {
    case .base:
     snippet_creation_with_checkup_helper(objectType: NMBaseSnippet.self,
                                          persist: PERSISTED,
                                          snippetType: snippetType){
      SUTS.append($0)
      expectation.fulfill()
     }
    case .photo:
     snippet_creation_with_checkup_helper(objectType: NMPhotoSnippet.self,
                                          persist: PERSISTED,
                                          snippetType: snippetType) {
      SUTS.append($0)
      expectation.fulfill()
     }
    case .audio:
     snippet_creation_with_checkup_helper(objectType: NMAudioSnippet.self,
                                          persist: PERSISTED,
                                          snippetType: snippetType) {
      SUTS.append($0)
      expectation.fulfill()
     }
    case .video:
     snippet_creation_with_checkup_helper(objectType: NMVideoSnippet.self,
                                          persist: PERSISTED,
                                          snippetType: snippetType) {
      SUTS.append($0)
      expectation.fulfill()
     }
    case .text:
     snippet_creation_with_checkup_helper(objectType: NMTextSnippet.self,
                                          persist: PERSISTED,
                                          snippetType: snippetType) {
      SUTS.append($0)
      expectation.fulfill()
     }
    case .mixed:
     snippet_creation_with_checkup_helper(objectType: NMMixedSnippet.self,
                                          persist: PERSISTED,
                                          snippetType: snippetType) {
      SUTS.append($0)
      expectation.fulfill()
     }
   }
   
   return expectation
  }
  
  //ACTION...
  let result = XCTWaiter.wait(for: expectations, timeout: 0.1)
  
  //ASSERT...
  XCTAssertEqual(result, .completed)
  XCTAssertEqual(SUTS.count, SUTS_COUNT)
  
  let contexts = SUTS.compactMap(\.managedObjectContext)
  XCTAssertEqual(contexts.count, SUTS_COUNT)
  XCTAssertEqual(Set(contexts).count, 1) // Assert that all snippets have the same unique MOC!
  XCTAssertEqual(Set(contexts).first, model.context) // Assert that snippets' MOC is model main MOC!
  
  //FILE STORAGE CLEAN-UP...
  storageRemoveHelperSync(for: SUTS)
  
  
 }
 
 func test_Snippets_CREATED_correctly_AND_PERSISTED_IN_MAIN_CONTEXT_using_Combine_API() {
  
  //ARRANGE...
  let SUTS_COUNT = 6
  let PERSISTED = true
  var SUTS = [NMBaseSnippet]()
  
  let expectations = NMBaseSnippet.SnippetType.allCases.map{ snippetType -> XCTestExpectation in
   
   let expectation = XCTestExpectation(description: "All Snippets Types Creation with Combine")
   
   switch snippetType {
    case .base:
     snippet_creation_with_checkup_helper(objectType: NMBaseSnippet.self,
                                          persist: PERSISTED,
                                          snippetType: snippetType) {
      SUTS.append($0)
      expectation.fulfill()
     }
    case .photo:
     snippet_creation_with_checkup_helper(objectType: NMPhotoSnippet.self,
                                          persist: PERSISTED,
                                          snippetType: snippetType) {
      SUTS.append($0)
      expectation.fulfill()
     }
    case .audio:
     snippet_creation_with_checkup_helper(objectType: NMAudioSnippet.self,
                                          persist: PERSISTED,
                                          snippetType: snippetType) {
      SUTS.append($0)
      expectation.fulfill()
     }
    case .video:
     snippet_creation_with_checkup_helper(objectType: NMVideoSnippet.self,
                                          persist:PERSISTED,
                                          snippetType: snippetType) {
      SUTS.append($0)
      expectation.fulfill()
     }
    case .text:
     snippet_creation_with_checkup_helper(objectType: NMTextSnippet.self,
                                          persist: PERSISTED,
                                          snippetType: snippetType) {
      SUTS.append($0)
      expectation.fulfill()
     }
    case .mixed:
     snippet_creation_with_checkup_helper(objectType: NMMixedSnippet.self,
                                          persist: PERSISTED,
                                          snippetType: snippetType) {
      SUTS.append($0)
      expectation.fulfill()
     }
   }
   
   return expectation
  }
  
  //ACTION...
  let result = XCTWaiter.wait(for: expectations, timeout: 0.1)
  
  //ASSERT...
  XCTAssertEqual(result, .completed)
  XCTAssertEqual(SUTS.count, SUTS_COUNT)
  
  let contexts = SUTS.compactMap(\.managedObjectContext)
  XCTAssertEqual(contexts.count, SUTS_COUNT)
  XCTAssertEqual(Set(contexts).count, 1) // Assert that all snippets have the same unique MOC!
  XCTAssertEqual(Set(contexts).first, model.context) // Assert that snippets' MOC is model main MOC!
  
  //FILE STORAGE CLEAN-UP...
  storageRemoveHelperSync(for: SUTS)
  
  
 }
 
 func test_Snippets_CREATED_correctly_AND_PERSISTED_IN_Background_MOC_using_Combine_API() {
  
   //ARRANGE...
  let SUTS_COUNT = 6
  let PERSISTED = true
  var SUTS = [NMBaseSnippet]()
  
  let expectations = NMBaseSnippet.SnippetType.allCases.map{ snippetType -> XCTestExpectation in
   
   let expectation = XCTestExpectation(description: "All Snippets Types Creation in BG MOC with Combine")
   
   switch snippetType {
    case .base:
     snippet_background_creation_with_checkup_helper(objectType: NMBaseSnippet.self,
                                                     persist: PERSISTED,
                                                     snippetType: snippetType) {
      SUTS.append($0)
      expectation.fulfill()
     }
    case .photo:
     snippet_background_creation_with_checkup_helper(objectType: NMPhotoSnippet.self,
                                                     persist: PERSISTED,
                                                     snippetType: snippetType) {
      SUTS.append($0)
      expectation.fulfill()
     }
    case .audio:
     snippet_background_creation_with_checkup_helper(objectType: NMAudioSnippet.self,
                                                     persist: PERSISTED,
                                                     snippetType: snippetType) {
      SUTS.append($0)
      expectation.fulfill()
     }
    case .video:
     snippet_background_creation_with_checkup_helper(objectType: NMVideoSnippet.self,
                                                     persist:PERSISTED,
                                                     snippetType: snippetType) {
      SUTS.append($0)
      expectation.fulfill()
     }
    case .text:
     snippet_background_creation_with_checkup_helper(objectType: NMTextSnippet.self,
                                                     persist: PERSISTED,
                                                     snippetType: snippetType) {
      SUTS.append($0)
      expectation.fulfill()
     }
    case .mixed:
     snippet_background_creation_with_checkup_helper(objectType: NMMixedSnippet.self,
                                                     persist: PERSISTED,
                                                     snippetType: snippetType) {
      SUTS.append($0)
      expectation.fulfill()
     }
   }
   
   return expectation
  }
  
   //ACTION...
  let result = XCTWaiter.wait(for: expectations, timeout: 0.1)
  
   //ASSERT...
  XCTAssertEqual(result, .completed)
  XCTAssertEqual(SUTS.count, SUTS_COUNT)
  
  let contexts = SUTS.compactMap(\.managedObjectContext)
  XCTAssertEqual(contexts.count, SUTS_COUNT)
  XCTAssertEqual(Set(contexts).count, 1) // Assert that all snippets have the same unique MOC!
  XCTAssertEqual(Set(contexts).first, model.context) // Assert that snippets' MOC is model main MOC!
  
   //FILE STORAGE CLEAN-UP...
  storageRemoveHelperSync(for: SUTS)
  
  
 }
 
 func test_Snippets_deleted_when_modification_block_throws() {
  
  //ARRANGE...
  let expectations = NMBaseSnippet.SnippetType.allCases.map{ snippetType -> XCTestExpectation in
   let expectation = XCTestExpectation(description: "All Snippets Types Throwing Modification")
   switch snippetType
   {
    case .base:
     snippet_throwing_modification_helper(objectType: NMBaseSnippet.self,
                                          snippetType: snippetType) { expectation.fulfill() }
    case .photo:
     snippet_throwing_modification_helper(objectType: NMPhotoSnippet.self,
                                          snippetType: snippetType) { expectation.fulfill() }
    case .audio:
     snippet_throwing_modification_helper(objectType: NMAudioSnippet.self,
                                          snippetType: snippetType) { expectation.fulfill() }
    case .video:
     snippet_throwing_modification_helper(objectType: NMVideoSnippet.self,
                                          snippetType: snippetType) { expectation.fulfill() }
    case .text:
     snippet_throwing_modification_helper(objectType: NMTextSnippet.self,
                                          snippetType: snippetType) { expectation.fulfill() }
    case .mixed:
     snippet_throwing_modification_helper(objectType: NMMixedSnippet.self,
                                          snippetType: snippetType) { expectation.fulfill() }
   }
   
   return expectation
  }
  
  //ACTION...
  let result = XCTWaiter.wait(for: expectations, timeout: 0.1)
  
  //ASSERT...
  XCTAssertEqual(result, .completed)
 }
 
 
}


import XCTest
import NewsmanCoreDataModel
import CoreLocation

@available(iOS 14.0, *)
extension NMBaseSnippetsTests {
 
 func test_Snippets_CREATED_correctly_without_persistance()
 {
  
  var SUTS = [NMBaseSnippet]()
  
  let expectations = NMBaseSnippet.SnippetType.allCases.map{ snippetType -> XCTestExpectation in
   
   let expectation = XCTestExpectation(description: "All Snippets Types Creation")
   
   switch snippetType {
    case .base:
     snippet_creation_with_checkup_helper(objectType: NMBaseSnippet.self, snippetType: snippetType){
      SUTS.append($0)
      expectation.fulfill()
     }
    case .photo:
     snippet_creation_with_checkup_helper(objectType: NMPhotoSnippet.self, snippetType: snippetType) {
      SUTS.append($0)
      expectation.fulfill()
     }
    case .audio:
     snippet_creation_with_checkup_helper(objectType: NMAudioSnippet.self, snippetType: snippetType) {
      SUTS.append($0)
      expectation.fulfill()
     }
    case .video:
     snippet_creation_with_checkup_helper(objectType: NMVideoSnippet.self, snippetType: snippetType) {
      SUTS.append($0)
      expectation.fulfill()
     }
    case .text:
     snippet_creation_with_checkup_helper(objectType: NMTextSnippet.self, snippetType: snippetType) {
      SUTS.append($0)
      expectation.fulfill()
     }
    case .mixed:
     snippet_creation_with_checkup_helper(objectType: NMMixedSnippet.self, snippetType: snippetType) {
      SUTS.append($0)
      expectation.fulfill()
     }
    }
    
   return expectation
  }
 
  let result = XCTWaiter.wait(for: expectations, timeout: 0.1)
  XCTAssertEqual(result, .completed)
  
  
  self.storageRemoveHelperSync(for: SUTS)
 
  
  
 }
 
 
 @available(iOS 14.0, *)
 final func snippet_throwing_modification_helper<T: NMBaseSnippet>(objectType:T.Type,
                                                                   snippetType: NMBaseSnippet.SnippetType,
                                                                   handler: @escaping () -> () )
 {
  model.create(persist: true, objectType: T.self) {
    throw SnippetTestError.failed(snippet: $0)
   } handler: { result in
     switch result {
      case .success(let photoSnippet):
       XCTFail("Snippet \(photoSnippet) must be removed from context!")

      case .failure(let error as SnippetTestError<T>):
       guard case let .failed(snippet) = error else {
        XCTFail("UNKNOWN TEST ERROR CASE \(error.localizedDescription)")
        return
       }
       XCTAssertTrue(snippet.objectID.isTemporaryID)
       XCTAssertTrue(snippet.hasChanges)
       XCTAssertTrue(snippet.isDeleted)
      
       if let path = (snippet as? NMFileStorageManageable)?.url?.path {
        XCTAssertFalse(FileManager.default.fileExists(atPath: path))
       }
      
      default:
       XCTFail("UNEXPECTED TEST RESULT \(result)")
     }
     handler()
   }
 }
 
 func test_Snippets_deleted_when_modification_block_throws()
 {
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
 
  let result = XCTWaiter.wait(for: expectations, timeout: 0.1)
  XCTAssertEqual(result, .completed)
 }
 
 
}





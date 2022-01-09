import XCTest
import NewsmanCoreDataModel

extension NMBaseSnippetsTests
{
 
 func test_NMBaseSnippet_creation()
 {
  let expectation = expectation(description: "Create new NMBaseSnippet expectation")
  snippet_creation_helper(objectType: NMBaseSnippet.self, snippetType: .base){ base in
   expectation.fulfill()
  }
  waitForExpectations(timeout: 0.01)

 }
 
 @available(iOS 15.0, *)
 @available(macOS 12.0.0, *)
 func test_NMBaseSnippet_creation_async() async throws
 {
  
  _ = try await snippet_creation_helper(objectType: NMBaseSnippet.self, snippetType: .base)

 }
 
 
}

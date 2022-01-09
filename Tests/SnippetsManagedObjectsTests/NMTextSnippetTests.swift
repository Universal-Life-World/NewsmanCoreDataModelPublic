import XCTest
import NewsmanCoreDataModel

extension NMBaseSnippetsTests
{
 
 func test_NMTextSnippet_creation()
 {
  let expectation = expectation(description: "Create new NMTextSnippet expectation with file storage init")
  snippet_creation_helper(objectType: NMTextSnippet.self, snippetType: .text) { text in
   expectation.fulfill()
  }
  waitForExpectations(timeout: 0.01)

 }
 
 
 @available(iOS 15.0, *) @available(macOS 12.0.0, *)
 func test_NMTextSnippet_creation_async() async throws
 {
  
  _ = try await snippet_creation_helper(objectType: NMTextSnippet.self, snippetType: .text)

 }
 
 
 
}

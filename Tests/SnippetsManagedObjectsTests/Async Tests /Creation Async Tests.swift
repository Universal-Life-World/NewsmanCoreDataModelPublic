import XCTest
import NewsmanCoreDataModel

//MARK: ALL SNIPPETS CREATION UNIT TESTS EXTENSION.

@available(iOS 15.0, *)
@available(macOS 12.0.0, *)
extension NMBaseSnippetsAsyncTests
{
 //MARK: Test that when all snippets are created without persistance they have not NILID field!
 
 final func test_Snippets_CREATED_Correctly_with_NO_Persistance() async throws
 {
  let SUTS = try await createAllSnippets(persisted: false)
  XCTAssertEqual(SUTS.compactMap{ $0.id }.count, 6)
  try await storageRemoveHelperAsync(for: SUTS)
  
 }
 
 //MARK: Test that when all snippets are created and persisted they can be fetched from MOC.
 
 final func test_Snippets_CREATED_correctly_With_Persistance() async throws
 {
  let SUTS = try await createAllSnippets(persisted: true)
  try await snippetsPersistanceCheckHelperAsync(for: SUTS) //FETCH SNIPPETS...
  try await storageRemoveHelperAsync(for: SUTS)
  
 }
 
 //MARK: Test that all snippets are created and persisted with modification block and last access & modification time stamps are updated properly.
 
 final func test_Snippets_CREATED_correctly_WITH_Persistance_and_modification_block() async throws
 {
  @Sendable func block( _ snippet: NMBaseSnippet) throws
  {
   let now1 = Date().timeIntervalSinceReferenceDate
   XCTAssertEqual(snippet.priority, .normal)
   let lastAccessed1 = try XCTUnwrap(snippet.lastAccessedTimeStamp).timeIntervalSinceReferenceDate
   XCTAssertEqual(lastAccessed1, now1, accuracy: 0.1)
   
   let now2 = Date().timeIntervalSinceReferenceDate
   XCTAssertEqual(snippet.status, .new)
   let lastAccessed2 = try XCTUnwrap(snippet.lastAccessedTimeStamp).timeIntervalSinceReferenceDate
   XCTAssertEqual(lastAccessed2, now2, accuracy: 0.1)
   XCTAssertGreaterThan(lastAccessed2, lastAccessed1)
   
   let now3 = Date().timeIntervalSinceReferenceDate
   snippet.priority = .high
   let lastModified = try XCTUnwrap(snippet.lastModifiedTimeStamp).timeIntervalSinceReferenceDate
   XCTAssertEqual(lastModified, now3, accuracy: 0.1)
   
  }
  
  let start = Date()
  let SUTS = try await createAllSnippets(persisted: true, block: block)
  let finish = Date()
  
  XCTAssertTrue(SUTS.allSatisfy{ $0.priority == .high })
  XCTAssertTrue(SUTS.allSatisfy{ $0.status == .privy })
  XCTAssertTrue(SUTS.allSatisfy{ $0.lastModifiedTimeStamp! > start && $0.lastModifiedTimeStamp! < finish })
  
  try await storageRemoveHelperAsync(for: SUTS)
  
 }
 
}

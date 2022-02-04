
import XCTest
import NewsmanCoreDataModel

enum SnippetTestError<T>: Error{
 case failed(snippet: T)
}

extension NMBaseSnippetsTests
{
 final func snippet_creation_with_checkup_helper<T: NMBaseSnippet>(objectType:T.Type,
                                                                   snippetType: NMBaseSnippet.SnippetType,
                                                                    handler: @escaping (T) -> () )
 {
  model.create(objectType: T.self) { [unowned self] result in
   DispatchQueue.main.async{
    switch result {
     case let .success(snippet):
      do {
       try snippet_base_cheking_helper(snippet, snippetType)
       handler(snippet)
      }
      catch {
       XCTFail(error.localizedDescription)
      }
    
     case let .failure(error):
      XCTFail(error.localizedDescription)
    }
    
   }
  }
 }
 
 final func snippet_base_cheking_helper(_ snippet: NMBaseSnippet,
                                        _ snippetType: NMBaseSnippet.SnippetType) throws
 {
  
  let accessed = try XCTUnwrap(snippet.lastAccessedTimeStamp, "Snippet Last Accessed Date Must be set up!")
  let created =  try XCTUnwrap(snippet.date, "Snippet Date Must be set up on creation")
  let modified = try XCTUnwrap(snippet.lastModifiedTimeStamp, "Snippet Last Modified Date Must be set up!")
  
  XCTAssertEqual(created, modified)
  XCTAssertTrue(created <= accessed) //! Id property already accessed in snippet create!
  
  XCTAssertNotNil(snippet.id)
  let now = Date().timeIntervalSinceReferenceDate
  XCTAssertNotNil(snippet.managedObjectContext)
  
  let snippetID = try XCTUnwrap(snippet.id, "Snippet Must have ID on creation").uuidString
 
  XCTAssertEqual(snippet.priority, .normal)
  XCTAssertTrue(snippet.type == snippetType)
  
  XCTAssertEqual(created.timeIntervalSinceReferenceDate, now, accuracy: 0.1)
  
  XCTAssertNil(snippet.trashedTimeStamp)
  XCTAssertNil(snippet.ck_metadata)
  
  if snippetType == .base {
   XCTAssertNil((snippet as? NMFileStorageManageable)?.url)
  } else {
   let storageURL = try XCTUnwrap((snippet as? NMFileStorageManageable)?.url)
   XCTAssertTrue(FileManager.default.fileExists(atPath: storageURL.path))
   XCTAssertEqual(snippetID, storageURL.lastPathComponent)
   let pathAttach = XCTAttachment(string: storageURL.path)
   pathAttach.lifetime = .keepAlways
   self.add(pathAttach)
  }
  
 }
  
 final func storageRemoveHelperSync(for snippets: [NMBaseSnippet])
 {
  let context = model.context
  
  let docsFolder = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
 
  let removeExpectations = snippets.compactMap { snippet -> XCTestExpectation? in
 
   let removeExpectation = XCTestExpectation(description: "Remove Snippet Storage Expectation")
   
   guard let fileStorageProvider = snippet as? NMFileStorageManageable else { return nil }
   
   fileStorageProvider.removeFileStorage{ result in
    context.perform {
     switch result {
      case .success():
       guard let snippet_id = snippet.id else {
        XCTFail("Snippet Must Have ID after file storage removal")
        break
       }
       
       let path = docsFolder.appendingPathComponent(snippet_id.uuidString).path
       XCTAssertFalse(FileManager.default.fileExists(atPath: path))
       removeExpectation.fulfill()
       
      case .failure(let error):  XCTFail(error.localizedDescription)
     }
    }
   }
   return removeExpectation
  }
  
  XCTAssertEqual(snippets.count - 1,  removeExpectations.count)
   // Minus 1 as the NMBaseSnippet has no file storage per se!

  let result = XCTWaiter.wait(for: removeExpectations, timeout: 0.1)
  XCTAssertEqual(result, .completed)
  
 }//final func storageRemoveHelper with callback...
  
}
 
 
 
 
 
 
 
 
 
 
 
 

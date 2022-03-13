import XCTest
import NewsmanCoreDataModel

@available(iOS 14.0, *)
extension NMBaseSnippetsCombineAPITests {
 final func snippet_creation_with_checkup_helper<T: NMBaseSnippet>(objectType:T.Type,
                                                                   persist: Bool,
                                                                   updates: ((T) -> ())? = nil,
                                                                   snippetType: NMBaseSnippet.SnippetType,
                                                                   handler: @escaping (T) -> () ) {
  
   model.create(persist: persist, objectType: T.self, with: updates)
   .subscribe(on: DispatchQueue.global(qos: .utility))
   .receive(on: DispatchQueue.main)
   .sink { completion in
     switch completion {
      case .finished: break
      case .failure(let error): XCTFail(error.localizedDescription)
     }
   } receiveValue: { [unowned self] snippet in
   
     do {
      try snippet_base_cheking_helper(snippet, snippetType, persist, handler)
     } catch {
      XCTFail(error.localizedDescription)
     }
    
   }.store(in: &disposeBag)
  
 
 }
 
 final func snippet_background_creation_with_checkup_helper<T: NMBaseSnippet>(objectType:T.Type,
                                                                              persist: Bool,
                                                                              updates: ((T) -> ())? = nil,
                                                                              snippetType: NMBaseSnippet.SnippetType,
                                                                              handler: @escaping (T) -> () ) {
  
  model.backgroundCreate(persist: persist, objectType: T.self, with: updates)
   .subscribe(on: DispatchQueue.global(qos: .utility))
   .receive(on: DispatchQueue.main)
   .sink { completion in
    switch completion {
     case .finished: break
     case .failure(let error): XCTFail(error.localizedDescription)
    }
   } receiveValue: { [unowned self] snippet in
    
    do {
     try snippet_base_cheking_helper(snippet, snippetType, persist, handler)
    } catch {
     XCTFail(error.localizedDescription)
    }
    
   }.store(in: &disposeBag)
  
  
 }
 
 final func snippet_base_cheking_helper<T: NMBaseSnippet>(_ snippet: T,
                                        _ snippetType: NMBaseSnippet.SnippetType,
                                        _ persisted: Bool,
                                        _ handler:  @escaping (T) -> ()) throws {
  
  let context = try XCTUnwrap(snippet.managedObjectContext, "Snippet Must be associated with main MOC!")
  
  XCTAssertEqual(context, model.context)
  
  context.perform {
   defer { handler(snippet) }
   do {
    let accessed = try XCTUnwrap(snippet.lastAccessedTimeStamp, "Snippet Last Accessed Date Must be set up!")
    let created =  try XCTUnwrap(snippet.date, "Snippet Date Must be set up on creation")
    let modified = try XCTUnwrap(snippet.lastModifiedTimeStamp, "Snippet Last Modified Date Must be set up!")
    
    XCTAssertEqual(created.timeIntervalSinceReferenceDate,
                   modified.timeIntervalSinceReferenceDate, accuracy: 1)
    
    XCTAssertTrue(created <= accessed) //! Id property already accessed in snippet create!
    
    if persisted {
     XCTAssertFalse (snippet.objectID.isTemporaryID)
    } else {
     XCTAssertTrue (snippet.objectID.isTemporaryID)
    }
    
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
   } catch {
    XCTFail(error.localizedDescription)
   }
  }
  
 }
 

 final func snippet_throwing_modification_helper<T: NMBaseSnippet>(objectType:T.Type,
                                                                   snippetType: NMBaseSnippet.SnippetType,
                                                                   expectationHandler: @escaping () -> () ) {
  
  model.create(persist: true, objectType: T.self) {
   throw SnippetTestError.failed(snippet: $0)
  }.sink { completion in
    switch completion {
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
      
      expectationHandler()
      
     default: XCTFail("UNEXPECTED TEST RESULT \(completion)")
    }
   } receiveValue: { snippet in
     XCTFail("Snippet \(snippet) must be removed from context!")
   }.store(in: &disposeBag)
  
  
  
  
 }
 
}

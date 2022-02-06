
import XCTest
import NewsmanCoreDataModel
import CoreData

@available(iOS 15.0, *) @available(macOS 12.0.0, *)
extension NMBaseSnippetsAsyncTests
{

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
 }//final func snippet_base_cheking_helper...
 
 final func snippet_creation_helper<T: NMBaseSnippet>(objectType: T.Type,
                                                      persist: Bool = false,
                                                      snippetType: NMBaseSnippet.SnippetType) async throws -> T
 {
  let snippet = try await model.create(persist: persist, objectType: T.self)
  
  try await model.context.perform {
   try self.snippet_base_cheking_helper(snippet, snippetType)
  }
  
  return snippet
  
 }//final func snippet_creation_helper<T: NMBaseSnippet>....
 
 final func createAllSnippets(persisted: Bool = true,
                              block: ((NMBaseSnippet) throws -> ())? = nil) async throws -> [NMBaseSnippet]
 {
  async let s1 = model.create(persist: persisted, objectType: NMBaseSnippet.self,  with: block)
  async let s2 = model.create(persist: persisted, objectType: NMPhotoSnippet.self, with: block)
  async let s3 = model.create(persist: persisted, objectType: NMAudioSnippet.self, with: block)
  async let s4 = model.create(persist: persisted, objectType: NMTextSnippet.self,  with: block)
  async let s5 = model.create(persist: persisted, objectType: NMVideoSnippet.self, with: block)
  async let s6 = model.create(persist: persisted, objectType: NMMixedSnippet.self, with: block)
  
  return try await [s1,s2,s3,s4,s5,s6]
  
 }// final func createAllSnippets(persisted: Bool = true)...
 
 final func createAllSnippetsWithGeoLocations(persisted: Bool = true,
                            block: ((NMBaseSnippet) throws -> ())? = nil) async throws -> [NMBaseSnippet]
 {
   async let s1 = model.create(persisted: persisted,
                               of: NMBaseSnippet.self,
                               with: NMLocationsGeocoderMock.self,
                               using: NMNetworkWaiterMock.self,
                               updated: block)
  
   async let s2 = model.create(persisted: persisted,
                               of: NMPhotoSnippet.self,
                               with: NMLocationsGeocoderMock.self,
                               using: NMNetworkWaiterMock.self,
                               updated: block)

   async let s3 = model.create(persisted: persisted,
                               of: NMAudioSnippet.self,
                               with: NMLocationsGeocoderMock.self,
                               using: NMNetworkWaiterMock.self,
                               updated: block)

   async let s4 = model.create(persisted: persisted,
                               of: NMTextSnippet.self,
                               with: NMLocationsGeocoderMock.self,
                               using: NMNetworkWaiterMock.self,
                               updated: block)

   async let s5 = model.create(persisted: persisted,
                               of: NMVideoSnippet.self,
                               with: NMLocationsGeocoderMock.self,
                               using: NMNetworkWaiterMock.self,
                               updated: block)

   async let s6 = model.create(persisted: persisted,
                               of: NMMixedSnippet.self,
                               with: NMLocationsGeocoderMock.self,
                               using: NMNetworkWaiterMock.self,
                               updated: block)
  
  return  try await [ s1,s2,s3,s4,s5,s6 ]
  
 }// final func createAllSnippetsWithGeoLocations(...)
 
 
 final func storageRemoveHelperAsync(for snippets: [NMBaseSnippet]) async throws
 {
  let ids = try await withThrowingTaskGroup(of: NMFileStorageManageable.self, returning: [UUID].self)
  { group in
   snippets.compactMap{$0 as? NMFileStorageManageable}.forEach{ snippet in
    group.addTask{
     try await snippet.removeFileStorage()
     return snippet
    }
   }
   return try await group.reduce(into: []) {$0.append($1.id)}.compactMap{$0}
  }
  
  XCTAssertEqual(snippets.count - 1, ids.count) // Minus 1 as the NMBaseSnippet has no file storage per se!
  
  let docsFolder = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
  let paths = ids.map{ docsFolder.appendingPathComponent($0.uuidString).path }
  
  XCTAssertTrue(paths.allSatisfy{!FileManager.default.fileExists(atPath: $0)})
  
 }//final func storageRemoveHelperAsync...
 
 
 final func snippetsPersistanceCheckHelperAsync(for snippets: [NMBaseSnippet]) async throws
 {
  let modelContext = model.context
  
  try await modelContext.perform {
   for snippet in snippets
   {
    XCTAssertNotNil(snippet.id)
    let snippetContext = try XCTUnwrap (snippet.managedObjectContext)
    XCTAssertFalse(snippet.objectID.isTemporaryID)
    XCTAssertEqual(snippetContext, modelContext)
    XCTAssertFalse(snippet.hasChanges)
    let type = try XCTUnwrap (snippet.type)
    let pred = NSPredicate(format: "SELF == %@", snippet)
    switch type {
     case .base:
      let fr = NSFetchRequest<NMBaseSnippet>(entityName: "NMBaseSnippet")
      fr.predicate = pred
      let result = try XCTUnwrap(modelContext.fetch(fr).first)
      XCTAssertEqual(result, snippet)
      XCTAssertEqual(result.id, snippet.id)
      XCTAssertEqual(result.objectID, snippet.objectID)
      
     case .photo:
      let fr = NSFetchRequest<NMPhotoSnippet>(entityName: "NMPhotoSnippet")
      fr.predicate = pred
      let result = try XCTUnwrap(modelContext.fetch(fr).first)
      XCTAssertEqual(result.id, snippet.id)
      XCTAssertEqual(result.objectID, snippet.objectID)
      
     case .video:
      let fr = NSFetchRequest<NMVideoSnippet>(entityName: "NMVideoSnippet")
      fr.predicate = pred
      let result = try XCTUnwrap(modelContext.fetch(fr).first)
      XCTAssertEqual(result.id, snippet.id)
      XCTAssertEqual(result.objectID, snippet.objectID)
      
     case .audio:
      let fr = NSFetchRequest<NMAudioSnippet>(entityName: "NMAudioSnippet")
      fr.predicate = pred
      let result = try XCTUnwrap(modelContext.fetch(fr).first)
      XCTAssertEqual(result.id, snippet.id)
      XCTAssertEqual(result.objectID, snippet.objectID)
     case .text:
      let fr = NSFetchRequest<NMTextSnippet>(entityName: "NMTextSnippet")
      fr.predicate = pred
      let result = try XCTUnwrap(modelContext.fetch(fr).first)
      XCTAssertEqual(result.id, snippet.id)
      XCTAssertEqual(result.objectID, snippet.objectID)
      
     case .mixed:
      let fr = NSFetchRequest<NMMixedSnippet>(entityName: "NMMixedSnippet")
      fr.predicate = pred
      let result = try XCTUnwrap(modelContext.fetch(fr).first)
      XCTAssertEqual(result.id, snippet.id)
      XCTAssertEqual(result.objectID, snippet.objectID)
      
    }
   }
  }
  
 }//func snippetsPersistanceCheckHelperAsync...
 
 
}

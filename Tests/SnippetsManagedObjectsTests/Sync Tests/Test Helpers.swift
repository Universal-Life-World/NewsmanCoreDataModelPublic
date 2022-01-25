
import XCTest
import NewsmanCoreDataModel

enum SnippetTestError<T>: Error{
 case failed(snippet: T)
}

extension NMBaseSnippetsTests
{
 final func snippet_creation_helper<T: NMBaseSnippet>(objectType:T.Type,
                                                      snippetType: NMBaseSnippet.SnippetType,
                                                      handler: @escaping (T) -> () )
 {
  Self.model.create(objectType: T.self) { [unowned self] result in
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
 
 
// private func snippetDefaultPropertiesInitialSetupCheckup(for sut: NMBaseSnippet) throws
// {
//  let moc = try XCTUnwrap(sut.managedObjectContext)
//  let psc = try XCTUnwrap(moc.persistentStoreCoordinator)
//  let mom = psc.managedObjectModel
//  let sutEntityName = String(describing: type(of: sut))
//  let sut_entity = try XCTUnwrap(mom.entities.first{$0.name == sutEntityName})
//
//  sut_entity.attributesByName.filter{!$0.value.isOptional}.forEach
//  {
//
//   let attrDefaultValue = $0.value.defaultValue
//
//   let sutValue = sut.value(forKey: $0.key)
//
//   switch (attrDefaultValue, sutValue)
//   {
//    case (let modValue as Bool,    let sutValue as Bool):    XCTAssertEqual(modValue, sutValue)
//    case (let modValue as Int16,   let sutValue as Int16):   XCTAssertEqual(modValue, sutValue)
//    case (let modValue as UUID,    let sutValue as UUID):    XCTAssertEqual(modValue, sutValue)
//    case (let modValue as NSValue, let sutValue as NSValue): XCTAssertEqual(modValue, sutValue)
//    case (let modValue as Double,  let sutValue as Double):  XCTAssertEqual(modValue, sutValue)
//    case (let modValue as String,  let sutValue as String):  XCTAssertEqual(modValue, sutValue)
//    case (let modValue as Date,    let sutValue as Date):    XCTAssertEqual(modValue, sutValue)
//    case ( nil , nil ) : break
//    default:
//     XCTFail("UNKNOWN MODEL ATTRIBUTE TYPE!")
//
//   }
//
//  }
// }
//
 
}

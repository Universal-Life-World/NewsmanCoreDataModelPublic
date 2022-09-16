import NewsmanCoreDataModel
import XCTest

@available(iOS 15.0, macOS 12.0, *)
extension NMSnippetsManipulationAsyncTests {
 
 final func test_JSON_Serialization_of_content_elements() async throws {
  
   //ARRANGE...
  
  let PERSISTED = true // WITH PERSISTANCE!
  let modelMainContext = await model.mainContext // GET ASYNC MAIN MODEL CONTEXT!
  
   //CREATE SOURCE SNIPPET...
  let SUT_SNIPPET = try await model.create(persist: PERSISTED,
                                           objectType: NMPhotoSnippet.self){ [ unowned self ] in
   $0.nameTag = "SUT Source Photo Snippet"
   self.SUTS.append($0) //Added to weak refs container for memory leaks check-up!
  }
  
  
  let SUT_FOLDER = try await SUT_SNIPPET.createFolder(persist: PERSISTED){ [ unowned self ] in
   $0.tag = "SUT Source Folder"
   $0.geoLocation = .init(location: .init(latitude: 10, longitude: 10))
   $0.location = "Some Location"
   $0.priority = .hottest
   $0.colorFlag = .brown
   $0.arrowMenuPosition = .init(x: 100, y: 100)
   $0.arrowMenuTouchPoint = .init(x: 50, y: 50)
   $0[.plain(sortedBy: .ascending(keyPath: \.priority))] = 1
   $0[.dateGroups(sortedBy: .ascending(keyPath: \.priority))] = 0
   self.SUTS.append($0) //Added to weak refs container for memory leaks check-up!
  }
  
  
  let SUT = try await SUT_SNIPPET.createSingle(persist: PERSISTED,
                                               in: SUT_FOLDER){ [ unowned self ] in
   $0.tag = "SUT"
   $0.colorFlag = #colorLiteral(red: 0, green: 0.9810667634, blue: 0.5736914277, alpha: 1)
   self.SUTS.append($0) //Added to weak refs container for memory leaks check-up!
  }
  
  let SUT2 = try await SUT_SNIPPET.createSingle(persist: PERSISTED,
                                                in: SUT_FOLDER){ [ unowned self ] in
   $0.tag = "SUT2"
   $0.colorFlag = #colorLiteral(red: 0.8793543782, green: 0.2253175287, blue: 0.1012533999, alpha: 1)
   self.SUTS.append($0) //Added to weak refs container for memory leaks check-up!
  }
  
   //ASSERT BEFORE CODING...
  
  await modelMainContext.perform {
   XCTAssertNotNil(SUT_SNIPPET.id)
   XCTAssertNotNil(SUT_FOLDER.id)
   XCTAssertNotNil(SUT.id)
   XCTAssertNotNil(SUT2.id)
   XCTAssertEqual(SUT_SNIPPET, SUT_FOLDER.snippet)
   XCTAssertEqual(SUT_SNIPPET, SUT.snippet)
   XCTAssertEqual(SUT_SNIPPET, SUT2.snippet)
   XCTAssertEqual(SUT_FOLDER, SUT.folder)
   XCTAssertEqual(SUT_FOLDER, SUT2.folder)
   XCTAssertEqual(SUT_FOLDER.folderedPhotos, NSSet(array: [SUT, SUT2]))
   XCTAssertEqual(SUT_SNIPPET.photoFolders,  NSSet(object: SUT_FOLDER))
   XCTAssertEqual(SUT_SNIPPET.photos,        NSSet(array: [SUT, SUT2]))
   XCTAssertEqual(SUT_FOLDER[.plain     (sortedBy: .ascending(keyPath: \.priority))], 1)
   XCTAssertEqual(SUT_FOLDER[.dateGroups(sortedBy: .ascending(keyPath: \.priority))], 0)
   
  }
  
  
   //ASSERT AFTER CODING...
  
  let SUT_DATA = try await SUT.jsonEncodedData
  let SUT_DTO = try await SUT.asyncDTO
  try await SUT.delete(withFileStorageRecovery: true, persisted: PERSISTED)
  let DECODED_SUT = try await NMPhoto.jsonDecoded(from: SUT_DATA, using: modelMainContext)
  let DECODED_SUT_DTO = try await DECODED_SUT.asyncDTO
  
  try await modelMainContext.perform {
   
   XCTAssertNotEqual(DECODED_SUT, SUT)
   XCTAssertEqual(DECODED_SUT_DTO, SUT_DTO)
   
   XCTAssertNotNil(DECODED_SUT.managedObjectContext)
   XCTAssertNil(SUT.managedObjectContext)
   XCTAssertNotNil(DECODED_SUT.recoveryURL)
   XCTAssertEqual(SUT_SNIPPET, DECODED_SUT.snippet)
   XCTAssertEqual(SUT_FOLDER, DECODED_SUT.folder)
   let decodedURL = try XCTUnwrap(DECODED_SUT.url)
   XCTAssertTrue(FileManager.default.fileExists(atPath: decodedURL.path))
   
  }
  
  
  let SUT2_DATA = try await SUT2.jsonEncodedData
  let SUT2_DTO = try await SUT2.asyncDTO
  try await SUT2.delete(withFileStorageRecovery: true, persisted: PERSISTED)
  let DECODED_SUT2 = try await NMPhoto.jsonDecoded(from: SUT2_DATA, using: modelMainContext)
  let DECODED_SUT2_DTO = try await DECODED_SUT2.asyncDTO
  
  try await modelMainContext.perform {
   
   XCTAssertNotEqual(DECODED_SUT2, SUT2)
   XCTAssertEqual(DECODED_SUT2_DTO, SUT2_DTO)
   
   XCTAssertNil(SUT2.managedObjectContext)
   XCTAssertNotNil(DECODED_SUT2.managedObjectContext)
   XCTAssertNil(SUT2.managedObjectContext)
   XCTAssertNotNil(DECODED_SUT.recoveryURL)
   XCTAssertEqual(SUT_SNIPPET, DECODED_SUT2.snippet)
   XCTAssertEqual(SUT_FOLDER, DECODED_SUT2.folder)
   let decodedURL = try XCTUnwrap(DECODED_SUT2.url)
   XCTAssertTrue(FileManager.default.fileExists(atPath: decodedURL.path))
   
  }
  
  let SUT_FOLDER_DATA = try await SUT_FOLDER.jsonEncodedData
  let SUT_FOLDER_DTO = try await SUT_FOLDER.asyncDTO
  try await SUT_FOLDER.delete(withFileStorageRecovery: true, persisted: false)
  let DECODED_SUT_FOLDER = try await NMPhotoFolder.jsonDecoded(from: SUT_FOLDER_DATA, using: modelMainContext)
  let DECODED_SUT_FOLDER_DTO = try await DECODED_SUT_FOLDER.asyncDTO
  
  try await modelMainContext.perform {
   
   XCTAssertEqual(SUT_FOLDER_DTO, DECODED_SUT_FOLDER_DTO)
   XCTAssertNotEqual  (SUT_FOLDER, DECODED_SUT_FOLDER)
   XCTAssertNil       (SUT_FOLDER.snippet)
   XCTAssertTrue      (SUT_FOLDER.folderedElements.isEmpty)
   
   let decodedURL = try XCTUnwrap(DECODED_SUT_FOLDER.url)
   XCTAssertTrue(FileManager.default.fileExists(atPath: decodedURL.path))
   
   let decodedFoldered = DECODED_SUT_FOLDER.folderedElements
   XCTAssertEqual(decodedFoldered.count, 2)
   XCTAssertEqual(Set(decodedFoldered.compactMap(\.id)),
                  Set([SUT_DTO[NMBaseContent.IdentityKeys.id] as? UUID,
                       SUT2_DTO[NMBaseContent.IdentityKeys.id] as? UUID]))
   
   XCTAssertEqual(DECODED_SUT_FOLDER[.plain     (sortedBy: .ascending(keyPath: \.priority))], 1)
   XCTAssertEqual(DECODED_SUT_FOLDER[.dateGroups(sortedBy: .ascending(keyPath: \.priority))], 0)
   
   
  }
  
 }
}//extension NMSnippetsManipulationAsyncTests{...}

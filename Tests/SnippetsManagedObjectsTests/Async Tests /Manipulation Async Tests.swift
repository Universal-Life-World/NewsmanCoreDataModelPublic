import NewsmanCoreDataModel
import XCTest
 
 //MARK: ALL SNIPPETS CONTAINERRS & THEIR CONTENT OBJECT MANIPULATION UNIT TESTS.

@available(iOS 15.0, macOS 12.0, *)
final class NMSnippetsManipulationAsyncTests: NMBaseSnippetsAsyncTests {
 
//MARK: Test when SINGLE content (SUT) (NMContentElement) element moved async from source Parent snippet to destination snippet this object finishes in correct context and underlying file storage state. The source Folder (if Any) is auto deleted with empty file folder as empty folder or as an only contained element folder.
 
 final func test_when_SINGLE_content_element_MOVED_from_source_snippet_to_destination_snippet() async throws {
  
  //ARRANGE...
 
  let PERSISTED = true // WITH PERSISTANCE!
  let modelMainContext = await model.mainContext // GET ASYNC MAIN MODEL CONTEXT!
  
  //CREATE SOURCE SNIPPET...
  let SOURCE_SNIPPET = try await model.create(persist: PERSISTED,
                                              objectType: NMPhotoSnippet.self){ [ unowned self ] in
   $0.nameTag = "SUT Source Photo Snippet"
   self.SUTS.append($0) //Added to weak refs container for memory leaks check-up!
  }
  
  
  let SUT_FOLDER = try await SOURCE_SNIPPET.createFolder(persist: PERSISTED){ [ unowned self ] in
   $0.tag = "SUT Source Folder"
   self.SUTS.append($0) //Added to weak refs container for memory leaks check-up!
  }
  
 
  let SUT = try await SOURCE_SNIPPET.createSingle(persist: PERSISTED,
                                                  in: SUT_FOLDER){ [ unowned self ] in
   $0.tag = "SUT"
   self.SUTS.append($0) //Added to weak refs container for memory leaks check-up!
  }
  
  let SUT2 = try await SOURCE_SNIPPET.createSingle(persist: PERSISTED,
                                                  in: SUT_FOLDER){ [ unowned self ] in
   $0.tag = "SUT2"
   self.SUTS.append($0) //Added to weak refs container for memory leaks check-up!
  }
  
   //CREATE SOURCE SNIPPET...
  let DEST_SNIPPET = try await model.create(persist: PERSISTED,
                                            objectType: NMPhotoSnippet.self){ [ unowned self ] in
   $0.nameTag = "SUT Destination Photo Snippet"
   self.SUTS.append($0) //Added to weak refs container for memory leaks check-up!
  }
  
  let _SUT_resourceURL = try await SUT.resourceContentURL
  
  // ASSERT BEFORE MOVE!
  
  let SUT_FOLDER_URL = await modelMainContext.perform { SUT_FOLDER.url }
  
  XCTAssertNotNil(SUT_FOLDER_URL)
  XCTAssertTrue(FileManager.default.fileExists(atPath: SUT_FOLDER_URL!.path))
  
  await modelMainContext.perform {
   
   XCTAssertNotNil(_SUT_resourceURL)
   XCTAssertTrue(FileManager.default.fileExists(atPath: _SUT_resourceURL.path))
   XCTAssertEqual(_SUT_resourceURL.pathComponents.last, SUT.id?.uuidString)
   XCTAssertEqual(_SUT_resourceURL.pathComponents.dropLast().last, SUT_FOLDER.id?.uuidString)
   XCTAssertEqual(_SUT_resourceURL.pathComponents.dropLast(2).last, SOURCE_SNIPPET.id?.uuidString)
  }
  
  //ASSERT UNDO/REDO STATE BEFORE MOVE...
  
  let openUndoSession = await NMUndoSession.current
  XCTAssertNil(openUndoSession)
  
  let canUndoSession = await SUT.undoManager.canUndo
  XCTAssertFalse(canUndoSession)
  
  let canRedoSession = await SUT.undoManager.canRedo
  XCTAssertFalse(canRedoSession)
  
  
  
  //ACTION...
  try await SUT.move(to: DEST_SNIPPET, persist: PERSISTED) { $0.tag = "MOVED SUT" }
  
 
  //ASSERT...
  let SOURCE_resourceURL = try await SOURCE_SNIPPET.resourceSnippetURL
  //XCTAssertNotNil(SOURCE_resourceURL)
  XCTAssertTrue(FileManager.default.fileExists(atPath: SOURCE_resourceURL.path))
  
  let DEST_resourceURL = try await DEST_SNIPPET.resourceSnippetURL
  //XCTAssertNotNil(DEST_resourceURL)
  XCTAssertTrue(FileManager.default.fileExists(atPath: DEST_resourceURL.path))
  
  XCTAssertFalse(FileManager.default.fileExists(atPath: SUT_FOLDER_URL!.path))
  try await XCTAssertThrowsErrorAsync(try await SUT_FOLDER.resourceFolderURL)
  
//  let FOLDER_resourceURL = try await SUT_FOLDER.resourceFolderURL
//  XCTAssertNil(FOLDER_resourceURL)
//  XCTAssertTrue(FileManager.default.fileExists(atPath: FOLDER_resourceURL.path))
  
  let SUT_resourceURL = try await SUT.resourceContentURL
  XCTAssertNotNil(SUT_resourceURL)
  XCTAssertTrue(FileManager.default.fileExists(atPath: SUT_resourceURL.path))
  
  try await modelMainContext.perform {
   XCTAssertEqual(SUT.snippet, DEST_SNIPPET)
   XCTAssertEqual(SOURCE_SNIPPET.singleContentElements.count, 1)
   XCTAssertEqual(SOURCE_SNIPPET.singleContentElements.first, SUT2)
   XCTAssertEqual(DEST_SNIPPET.singleContentElements.count, 1)
   XCTAssertTrue(SUT_FOLDER.folderedElements.isEmpty)
   XCTAssertTrue(SUT_FOLDER.isDeleted)
   XCTAssertNil(SUT_FOLDER.url)
   XCTAssertNotNil (SUT.managedObjectContext)
   XCTAssertFalse(SUT.isDeleted)
   XCTAssertEqual (SUT.snippet, DEST_SNIPPET)
   XCTAssertNil (SUT.folder)
   XCTAssertNil (SUT2.folder)
   XCTAssertEqual(SUT.tag, "MOVED SUT")
   let URL = try XCTUnwrap(SUT.url?.path)
   XCTAssertTrue(FileManager.default.fileExists(atPath: URL))
   XCTAssertEqual(SUT_resourceURL.path, URL)
   XCTAssertEqual(SUT_resourceURL.pathComponents.last, SUT.id?.uuidString)
   XCTAssertEqual(SUT_resourceURL.pathComponents.dropLast().last, DEST_SNIPPET.id?.uuidString)
 
  }
  
  //ASSERT UNDO/REDO STATE AFTER MOVE...
  do {
   let openUndoSession = await NMUndoSession.current
   XCTAssertNil(openUndoSession)
   
   let canUndoSession = await SUT.undoManager.canUndo
   XCTAssertTrue(canUndoSession)
   
   let canRedoSession = await SUT.undoManager.canRedo
   XCTAssertFalse(canRedoSession)
   
  }
  
  //UNDO ACTION...
  
   try await SUT.undoManager.undo()
  
  //ASSERT AFTER UNDO...
  
  do {
   let openUndoSession = await NMUndoSession.current
   XCTAssertNil(openUndoSession)
   
   let canUndoSession = await SUT.undoManager.canUndo
   XCTAssertFalse(canUndoSession)
   
   let canRedoSession = await SUT.undoManager.canRedo
   XCTAssertTrue(canRedoSession)
   
  }
  
  try await modelMainContext.perform {
   
   XCTAssertEqual(SOURCE_SNIPPET.singleContentElements.count, 2)
   XCTAssertEqual(DEST_SNIPPET.singleContentElements.count, 0)
//   let SUT_FOLDER = try XCTUnwrap(SOURCE_SNIPPET.folders.first)
//   XCTAssertEqual(SUT_FOLDER.folderedElements.count, 2)
//   XCTAssertFalse(SUT_FOLDER.isDeleted)
//   XCTAssertNotNil(SUT_FOLDER.url)
//   XCTAssertNotNil (SUT.managedObjectContext)
 XCTAssertFalse(SUT.isDeleted)
//   XCTAssertEqual (SUT.snippet, SOURCE_SNIPPET)
//   XCTAssertEqual (SUT.folder, SUT_FOLDER)
//   XCTAssertEqual(SUT2.folder, SUT_FOLDER)
//   XCTAssertEqual(SUT.tag, "MOVED SUT")
//   let URL = try XCTUnwrap(SUT.url?.path)
//   XCTAssertTrue(FileManager.default.fileExists(atPath: URL))
//   XCTAssertEqual(SUT_resourceURL.path, URL)
//   XCTAssertEqual(SUT_resourceURL.pathComponents.last, SUT.id?.uuidString)
//   XCTAssertEqual(SUT_resourceURL.pathComponents.dropLast().last, DEST_SNIPPET.id?.uuidString)
//
  }
  
   //REDO ACTION...
  
//  try await SUT.undoManager.redo()
//
//   //ASSERT AFTER REDO...
//
//  do {
//   let openUndoSession = await NMUndoSession.current
//   XCTAssertNil(openUndoSession)
//
//   let canUndoSession = await SUT.undoManager.canUndo
//   XCTAssertTrue(canUndoSession)
//
//   let canRedoSession = await SUT.undoManager.canRedo
//   XCTAssertFalse(canRedoSession)
//
//  }
  
  
  //FINALLY - STORAGE CLEAN-UP!
  //try await storageRemoveHelperAsync(for: [SOURCE_SNIPPET, DEST_SNIPPET])
  
 }//test...
 
 //MARK: Test when SINGLE content (SUT) (NMContentElement) element moved async within its own Parent Snippet this object finishes in correct context and underlying file storage state. The source Folder (if Any) is auto deleted with empty file folder as empty folder or as an only contained element folder.
 
 final func test_when_SINGLE_content_element_MOVED_within_its_snippet() async throws {
  
   //ARRANGE...
  
  let PERSISTED = true // WITH PERSISTANCE!
  let modelMainContext = await model.mainContext // GET ASYNC MAIN MODEL CONTEXT!
  
   //CREATE SOURCE SNIPPET...
  let SNIPPET = try await model.create(persist: PERSISTED, objectType: NMPhotoSnippet.self){ [ unowned self ] in
   $0.nameTag = "SUT Source Photo Snippet"
   self.SUTS.append($0) //Added to weak refs container for memory leaks check-up!
  }
  
  
  let SUT_FOLDER = try await SNIPPET.createFolder(persist: PERSISTED){ [ unowned self ] in
   $0.tag = "SUT Source Folder"
   self.SUTS.append($0) //Added to weak refs container for memory leaks check-up!
  }
  
  
  let SUT = try await SNIPPET.createSingle(persist: PERSISTED, in: SUT_FOLDER){ [ unowned self ] in
   $0.tag = "SUT"
   self.SUTS.append($0) //Added to weak refs container for memory leaks check-up!
  }
  
  let SUT2 = try await SNIPPET.createSingle(persist: PERSISTED, in: SUT_FOLDER){ [ unowned self ] in
   $0.tag = "SUT2"
   self.SUTS.append($0) //Added to weak refs container for memory leaks check-up!
  }
  
  
  
  let _SUT_resourceURL = try await SUT.resourceContentURL
  
   // ASSERT BEFORE MOVE!
  
  let SUT_FOLDER_URL = await modelMainContext.perform { SUT_FOLDER.url }
  
  XCTAssertNotNil(SUT_FOLDER_URL)
  XCTAssertTrue(FileManager.default.fileExists(atPath: SUT_FOLDER_URL!.path))
  
  await modelMainContext.perform {
   
   XCTAssertNotNil(_SUT_resourceURL)
   XCTAssertTrue(FileManager.default.fileExists(atPath: _SUT_resourceURL.path))
   XCTAssertEqual(_SUT_resourceURL.pathComponents.last, SUT.id?.uuidString)
   XCTAssertEqual(_SUT_resourceURL.pathComponents.dropLast().last, SUT_FOLDER.id?.uuidString)
   XCTAssertEqual(_SUT_resourceURL.pathComponents.dropLast(2).last, SNIPPET.id?.uuidString)
  }
  
  
   //ACTION...
  try await SUT.move(to: SNIPPET, persist: PERSISTED) { $0.tag = "MOVED SUT" }
  
  
   //ASSERT...
  let SOURCE_resourceURL = try await SNIPPET.resourceSnippetURL
  XCTAssertTrue(FileManager.default.fileExists(atPath: SOURCE_resourceURL.path))
  
  
  XCTAssertFalse(FileManager.default.fileExists(atPath: SUT_FOLDER_URL!.path))
  try await XCTAssertThrowsErrorAsync(try await SUT_FOLDER.resourceFolderURL)
  
  let SUT_resourceURL = try await SUT.resourceContentURL
  XCTAssertTrue(FileManager.default.fileExists(atPath: SUT_resourceURL.path))
  
  try await modelMainContext.perform {
   
   XCTAssertEqual(SNIPPET.singleContentElements.count, 2)
   XCTAssertEqual(SNIPPET.folderedContentElements.count, 0)
   XCTAssertEqual(SNIPPET.unfolderedContentElements.count, 2)
   XCTAssertEqual(SNIPPET.folders.count, 0)
   XCTAssertTrue(SUT_FOLDER.folderedElements.isEmpty)
   XCTAssertTrue(SUT_FOLDER.isDeleted)
   XCTAssertNil(SUT_FOLDER.url)
   XCTAssertNotNil (SUT.managedObjectContext)
   XCTAssertFalse(SUT.isDeleted)
   XCTAssertEqual (SUT.snippet, SNIPPET)
   XCTAssertNil (SUT.folder)
   XCTAssertNil (SUT2.folder)
   XCTAssertEqual(SUT.tag, "MOVED SUT")
   let URL = try XCTUnwrap(SUT.url?.path)
   XCTAssertTrue(FileManager.default.fileExists(atPath: URL))
   XCTAssertEqual(SUT_resourceURL.path, URL)
   XCTAssertEqual(SUT_resourceURL.pathComponents.last, SUT.id?.uuidString)
   XCTAssertEqual(SUT_resourceURL.pathComponents.dropLast().last, SNIPPET.id?.uuidString)
   
  }
  
   //FINALLY - STORAGE CLEAN-UP!
  try await storageRemoveHelperAsync(for: [SNIPPET])
  
 }//test...
 
 //MARK: Test when SINGLE content (SUT) (NMContentElement) element moved async from source snippet to destination snippet FOLDER this object finishes in correct context and underlying file storage state. The source Folder (if Any) is auto deleted with empty file folder as empty folder or as an only contained element folder.
 
 final func test_when_SINGLE_content_element_MOVED_from_source_snippet_to_destination_FOLDER() async throws {
  
   //ARRANGE...
  
  let PERSISTED = true // WITH PERSISTANCE!
  let modelMainContext = await model.mainContext // GET ASYNC MAIN MODEL CONTEXT!
  
   //CREATE SOURCE SNIPPET...
  let SOURCE_SNIPPET = try await model.create(persist: PERSISTED,
                                              objectType: NMPhotoSnippet.self){ [ unowned self ] in
   $0.nameTag = "SUT Source Photo Snippet"
   self.SUTS.append($0) //Added to weak refs container for memory leaks check-up!
  }
  
  
  let SUT_FOLDER = try await SOURCE_SNIPPET.createFolder(persist: PERSISTED){ [ unowned self ] in
   $0.tag = "SUT Source Folder"
   self.SUTS.append($0) //Added to weak refs container for memory leaks check-up!
  }
  
  
  let SUT = try await SOURCE_SNIPPET.createSingle(persist: PERSISTED,
                                                  in: SUT_FOLDER){ [ unowned self ] in
   $0.tag = "SUT"
   self.SUTS.append($0) //Added to weak refs container for memory leaks check-up!
  }
  
  let SUT2 = try await SOURCE_SNIPPET.createSingle(persist: PERSISTED,
                                                   in: SUT_FOLDER){ [ unowned self ] in
   $0.tag = "SUT2"
   self.SUTS.append($0) //Added to weak refs container for memory leaks check-up!
  }
  
  let DEST_SNIPPET = try await model.create(persist: PERSISTED,
                                            objectType: NMPhotoSnippet.self){ [ unowned self ] in
   $0.nameTag = "SUT Destination Photo Snippet"
   self.SUTS.append($0) //Added to weak refs container for memory leaks check-up!
  }
  
  let DEST_FOLDER = try await DEST_SNIPPET.createFolder(persist: PERSISTED){ [ unowned self ] in
   $0.tag = "SUT Destination Folder"
   self.SUTS.append($0) //Added to weak refs container for memory leaks check-up!
  }
  
  let _SUT_resourceURL = try await SUT.resourceContentURL
  
   // ASSERT BEFORE MOVE!
  
  let SUT_FOLDER_URL = await modelMainContext.perform { SUT_FOLDER.url }
  
  XCTAssertNotNil(SUT_FOLDER_URL)
  XCTAssertTrue(FileManager.default.fileExists(atPath: SUT_FOLDER_URL!.path))
  
  await modelMainContext.perform {
   
   XCTAssertNotNil(_SUT_resourceURL)
   XCTAssertTrue(FileManager.default.fileExists(atPath: _SUT_resourceURL.path))
   XCTAssertEqual(_SUT_resourceURL.pathComponents.last, SUT.id?.uuidString)
   XCTAssertEqual(_SUT_resourceURL.pathComponents.dropLast().last, SUT_FOLDER.id?.uuidString)
   XCTAssertEqual(_SUT_resourceURL.pathComponents.dropLast(2).last, SOURCE_SNIPPET.id?.uuidString)
  }
  
  
   //ACTION...
  try await SUT.move(to: DEST_FOLDER, persist: PERSISTED) { $0.tag = "MOVED SUT" }
  
  
   //ASSERT...
  let SOURCE_resourceURL = try await SOURCE_SNIPPET.resourceSnippetURL
   //XCTAssertNotNil(SOURCE_resourceURL)
  XCTAssertTrue(FileManager.default.fileExists(atPath: SOURCE_resourceURL.path))
  
  let DEST_resourceURL = try await DEST_SNIPPET.resourceSnippetURL
   //XCTAssertNotNil(DEST_resourceURL)
  XCTAssertTrue(FileManager.default.fileExists(atPath: DEST_resourceURL.path))
  
  XCTAssertFalse(FileManager.default.fileExists(atPath: SUT_FOLDER_URL!.path))
  try await XCTAssertThrowsErrorAsync(try await SUT_FOLDER.resourceFolderURL)
  
   //  let FOLDER_resourceURL = try await SUT_FOLDER.resourceFolderURL
   //  XCTAssertNil(FOLDER_resourceURL)
   //  XCTAssertTrue(FileManager.default.fileExists(atPath: FOLDER_resourceURL.path))
  
  let SUT_resourceURL = try await SUT.resourceContentURL
  XCTAssertNotNil(SUT_resourceURL)
  XCTAssertTrue(FileManager.default.fileExists(atPath: SUT_resourceURL.path))
  
  try await modelMainContext.perform {
   
   XCTAssertEqual(SOURCE_SNIPPET.singleContentElements.count, 1)
   XCTAssertEqual(SOURCE_SNIPPET.singleContentElements.first, SUT2)
   XCTAssertEqual(DEST_SNIPPET.singleContentElements.count, 1)
   XCTAssertEqual(DEST_SNIPPET.folderedContentElements.count, 1)
   XCTAssertEqual(DEST_FOLDER.folderedElements.count, 1)
   XCTAssertTrue(SUT_FOLDER.folderedElements.isEmpty)
   XCTAssertTrue(SUT_FOLDER.isDeleted)
   XCTAssertNil(SUT_FOLDER.url)
   XCTAssertNotNil (SUT.managedObjectContext)
   XCTAssertFalse(SUT.isDeleted)
   XCTAssertEqual (SUT.snippet, DEST_SNIPPET)
   XCTAssertEqual (SUT.folder, DEST_FOLDER)
   XCTAssertNil (SUT2.folder)
   XCTAssertEqual(SUT.tag, "MOVED SUT")
   let URL = try XCTUnwrap(SUT.url?.path)
   XCTAssertTrue(FileManager.default.fileExists(atPath: URL))
   XCTAssertEqual(SUT_resourceURL.path, URL)
   XCTAssertEqual(SUT_resourceURL.pathComponents.last, SUT.id?.uuidString)
   XCTAssertEqual(SUT_resourceURL.pathComponents.dropLast().last, DEST_FOLDER.id?.uuidString)
   XCTAssertEqual(SUT_resourceURL.pathComponents.dropLast(2).last, DEST_SNIPPET.id?.uuidString)
   
  }
  
   //FINALLY - STORAGE CLEAN-UP!
  try await storageRemoveHelperAsync(for: [SOURCE_SNIPPET, DEST_SNIPPET])
  
 }//test...
 
 
  //MARK: Test when SINGLE content (SUT) (NMContentElement) element moved async from source snippet to source snippet FOLDER this object finishes in correct context and underlying file storage state. The source Folder (if Any) is auto deleted with empty file folder as empty folder or as an only contained element folder.
 
 final func test_when_SINGLE_content_element_MOVED_from_source_snippet_to_the_same_SNIPPET_FOLDER() async throws {
  
   //ARRANGE...
  
  let PERSISTED = true // WITH PERSISTANCE!
  let modelMainContext = await model.mainContext // GET ASYNC MAIN MODEL CONTEXT!
  
   //CREATE SOURCE SNIPPET...
  let SNIPPET = try await model.create(persist: PERSISTED,
                                              objectType: NMPhotoSnippet.self){ [ unowned self ] in
   $0.nameTag = "SUT Source Photo Snippet"
   self.SUTS.append($0) //Added to weak refs container for memory leaks check-up!
  }
  
  
  let SUT_FOLDER = try await SNIPPET.createFolder(persist: PERSISTED){ [ unowned self ] in
   $0.tag = "SUT Source Folder"
   self.SUTS.append($0) //Added to weak refs container for memory leaks check-up!
  }
  
  
  let SUT = try await SNIPPET.createSingle(persist: PERSISTED,
                                           in: SUT_FOLDER){ [ unowned self ] in
   $0.tag = "SUT"
   self.SUTS.append($0) //Added to weak refs container for memory leaks check-up!
  }
  
  let SUT2 = try await SNIPPET.createSingle(persist: PERSISTED,
                                            in: SUT_FOLDER){ [ unowned self ] in
   $0.tag = "SUT2"
   self.SUTS.append($0) //Added to weak refs container for memory leaks check-up!
  }
  
  
  let DEST_FOLDER = try await SNIPPET.createFolder(persist: PERSISTED){ [ unowned self ] in
   $0.tag = "SUT Destination Folder"
   self.SUTS.append($0) //Added to weak refs container for memory leaks check-up!
  }
  
  let _SUT_resourceURL = try await SUT.resourceContentURL
  
   // ASSERT BEFORE MOVE!
  
  let SUT_FOLDER_URL = await modelMainContext.perform { SUT_FOLDER.url }
  
  XCTAssertNotNil(SUT_FOLDER_URL)
  XCTAssertTrue(FileManager.default.fileExists(atPath: SUT_FOLDER_URL!.path))
  
  await modelMainContext.perform {
   
   XCTAssertNotNil(_SUT_resourceURL)
   XCTAssertTrue(FileManager.default.fileExists(atPath: _SUT_resourceURL.path))
   XCTAssertEqual(_SUT_resourceURL.pathComponents.last, SUT.id?.uuidString)
   XCTAssertEqual(_SUT_resourceURL.pathComponents.dropLast().last, SUT_FOLDER.id?.uuidString)
   XCTAssertEqual(_SUT_resourceURL.pathComponents.dropLast(2).last, SNIPPET.id?.uuidString)
  }
  
  
   //ACTION...
  try await SUT.move(to: DEST_FOLDER, persist: PERSISTED) { $0.tag = "MOVED SUT" }
  
  
   //ASSERT...
  let SOURCE_resourceURL = try await SNIPPET.resourceSnippetURL
  XCTAssertTrue(FileManager.default.fileExists(atPath: SOURCE_resourceURL.path))
  
  
  XCTAssertFalse(FileManager.default.fileExists(atPath: SUT_FOLDER_URL!.path))
  try await XCTAssertThrowsErrorAsync(try await SUT_FOLDER.resourceFolderURL)
  
  
  let SUT_resourceURL = try await SUT.resourceContentURL
  XCTAssertTrue(FileManager.default.fileExists(atPath: SUT_resourceURL.path))
  
  try await modelMainContext.perform {
   
   XCTAssertEqual(SNIPPET.singleContentElements.count, 2)
   XCTAssertEqual(SNIPPET.unfolderedContentElements.count, 1)
   XCTAssertEqual(SNIPPET.folderedContentElements.count, 1)
   XCTAssertEqual(DEST_FOLDER.folderedElements.count, 1)
   XCTAssertTrue(SUT_FOLDER.folderedElements.isEmpty)
   XCTAssertTrue(SUT_FOLDER.isDeleted)
   XCTAssertNil(SUT_FOLDER.url)
   XCTAssertNotNil (SUT.managedObjectContext)
   XCTAssertFalse(SUT.isDeleted)
   XCTAssertEqual (SUT.snippet, SNIPPET)
   XCTAssertEqual (SUT.folder, DEST_FOLDER)
   XCTAssertNil (SUT2.folder)
   XCTAssertEqual(SUT.tag, "MOVED SUT")
   let URL = try XCTUnwrap(SUT.url?.path)
   XCTAssertTrue(FileManager.default.fileExists(atPath: URL))
   XCTAssertEqual(SUT_resourceURL.path, URL)
   XCTAssertEqual(SUT_resourceURL.pathComponents.last, SUT.id?.uuidString)
   XCTAssertEqual(SUT_resourceURL.pathComponents.dropLast().last, DEST_FOLDER.id?.uuidString)
   XCTAssertEqual(SUT_resourceURL.pathComponents.dropLast(2).last, SNIPPET.id?.uuidString)
   
  }
  
   //FINALLY - STORAGE CLEAN-UP!
  try await storageRemoveHelperAsync(for: [SNIPPET])
  
 }//test...
 
 //MARK: Test when SINGLE content (SUT) (NMContentElement) element moved  from source snippet to destination snippet multiple times async this object finishes in correct context and underlying file storage state.
 
 final func test_when_SINGLE_content_element_MOVED_MULTIPLE_times_among_Snippets() async throws {
  
  //ARRANGE...
 
  let PERSISTED = true // WITH PERSISTANCE!
  let modelMainContext = await model.mainContext // GET ASYNC MAIN MODEL CONTEXT!
  let N_SNIPPETS = Int.random(in: 20...100)
  
   //CREATE A SET OF HOMOGENOUS SNIPPETS...
  let SNIPPETS = try await model.create(persist: PERSISTED,
                                        objectType: NMPhotoSnippet.self,
                                        objectCount: N_SNIPPETS){ [ unowned self ] in
   $0.enumerated().forEach{ $0.element.nameTag = "Snippet - \($0.offset)"}
   SUTS.append(contentsOf: $0) //Added to weak refs container for memory leaks check-up!
  }
  
  let SOURCE_SNIPPET = try XCTUnwrap(SNIPPETS.randomElement())
  
  let SUT_FOLDER = try await SOURCE_SNIPPET.createFolder(persist: PERSISTED){ [ unowned self ] in
   $0.tag = "SUT Source Folder"
   SUTS.append($0) //Added to weak refs container for memory leaks check-up!
  }
  
  let SUT = try await SOURCE_SNIPPET.createSingle(persist: PERSISTED,
                                                  in: SUT_FOLDER){ [ unowned self ] in
   $0.tag = "SUT"
   SUTS.append($0) //Added to weak refs container for memory leaks check-up!
  }
  
  let _SUT_resourceURL = try await SUT.resourceContentURL
  
 // ASSERT BEFORE MOVE!
  
  await modelMainContext.perform {
   
   XCTAssertNotNil(_SUT_resourceURL)
   XCTAssertTrue(FileManager.default.fileExists(atPath: _SUT_resourceURL.path))
   XCTAssertEqual(_SUT_resourceURL.pathComponents.last, SUT.id?.uuidString)
   XCTAssertEqual(_SUT_resourceURL.pathComponents.dropLast().last, SUT.folder?.id?.uuidString)
   XCTAssertEqual(_SUT_resourceURL.pathComponents.dropLast(2).last, SUT.snippet?.id?.uuidString)
  }
  
  
  //ACTION...
  try await withThrowingTaskGroup(of: Void.self, returning: Void.self) { group in
   
   SNIPPETS.filter{ $0 != SOURCE_SNIPPET }.shuffled().forEach { (DEST_SNIPPET) -> () in
    
    let nameTag =  modelMainContext.performAndWait { DEST_SNIPPET.nameTag ?? "" }
    
    group.addTask {
      try await SUT.move(to: DEST_SNIPPET, persist: PERSISTED) { $0.tag = "MOVED TO \(nameTag)" }
    }
   
   
   }
   
   try await group.waitForAll()
   
  }//group...
  
 
  //ASSERT AFTER...
  
  let SUT_resourceURL = try await SUT.resourceContentURL
  XCTAssertNotNil(SUT_resourceURL)
  XCTAssertTrue(FileManager.default.fileExists(atPath: SUT_resourceURL.path))
  
  try await modelMainContext.perform {
   
   let DEST_SNIPPET = try XCTUnwrap(SUT.snippet)
   XCTAssertTrue(SOURCE_SNIPPET.singleContentElements.isEmpty)
   XCTAssertEqual(DEST_SNIPPET.singleContentElements.count, 1)
   XCTAssertTrue(SUT_FOLDER.folderedElements.isEmpty)
   XCTAssertNotNil (SUT.managedObjectContext)
   XCTAssertNil (SUT.folder)
   XCTAssertEqual(SUT.tag, "MOVED TO \(DEST_SNIPPET.nameTag ?? "")")
   let URL = try XCTUnwrap(SUT.url?.path)
   XCTAssertTrue(FileManager.default.fileExists(atPath: URL))
   XCTAssertEqual(SUT_resourceURL.path, URL)
   XCTAssertEqual(SUT_resourceURL.pathComponents.last, SUT.id?.uuidString)
   XCTAssertEqual(SUT_resourceURL.pathComponents.dropLast().last, DEST_SNIPPET.id?.uuidString)
   
  }
  
  //try await storageRemoveHelperAsync(for: SNIPPETS)
  
 }//test...
 
  //MARK: Test when SINGLE content (SUT) (NMContentElement) element moved within its Parent Snippet between folders multiple times async this object finishes in correct context and underlying file storage state.
 
 final func test_when_SINGLE_content_element_MOVED_MULTIPLE_times_among_its_Snippet_FOLDERS() async throws {
  
   //ARRANGE...
  
  let PERSISTED = true // WITH PERSISTANCE!
  let modelMainContext = await model.mainContext // GET ASYNC MAIN MODEL CONTEXT!
  let N_FOLDERS = Int.random(in: 20...100)
  
   //CREATE A SET OF HOMOGENOUS SNIPPETS...
  let SNIPPET = try await model.create(persist: PERSISTED,
                                       objectType: NMPhotoSnippet.self){ [ unowned self ] in
   
   $0.nameTag = "Parent Snippet"
   SUTS.append($0) //Added to weak refs container for memory leaks check-up!
  }
  
  
  let SUT_FOLDERS = try await SNIPPET.createFolders(N_FOLDERS, persist: PERSISTED){ [ unowned self ] in
   $0.enumerated().forEach{ $0.element.tag = "Folder - \($0.offset)"}
   SUTS.append(contentsOf: $0) //Added to weak refs container for memory leaks check-up!
  }
  
  let SUT_FOLDER = try XCTUnwrap(SUT_FOLDERS.randomElement())
  
  let SUT = try await SNIPPET.createSingle(persist: PERSISTED,
                                           in: SUT_FOLDER){ [ unowned self ] in
   $0.tag = "SUT"
   SUTS.append($0) //Added to weak refs container for memory leaks check-up!
  }
  
  let _SUT_resourceURL = try await SUT.resourceContentURL
  
   // ASSERT BEFORE MOVE!
  
  await modelMainContext.perform {
   
   XCTAssertNotNil(_SUT_resourceURL)
   XCTAssertTrue(FileManager.default.fileExists(atPath: _SUT_resourceURL.path))
   XCTAssertEqual(_SUT_resourceURL.pathComponents.last, SUT.id?.uuidString)
   XCTAssertEqual(_SUT_resourceURL.pathComponents.dropLast().last, SUT_FOLDER.id?.uuidString)
   XCTAssertEqual(_SUT_resourceURL.pathComponents.dropLast(2).last, SNIPPET.id?.uuidString)
  }
  
  
   //ACTION...
  try await withThrowingTaskGroup(of: Void.self, returning: Void.self) { group in
   
   SUT_FOLDERS.filter{ $0 != SUT_FOLDER }.shuffled().forEach { (DEST_FOLDER) -> () in
    
    let nameTag =  modelMainContext.performAndWait { DEST_FOLDER.tag ?? "" }
    
    group.addTask {
     try await SUT.move(to: DEST_FOLDER, persist: PERSISTED) { $0.tag = "MOVED TO \(nameTag)" }
    }
    
    
   }
   
   try await group.waitForAll()
   
  }//group...
  
  
   //ASSERT AFTER...
  
  let SUT_resourceURL = try await SUT.resourceContentURL
  XCTAssertNotNil(SUT_resourceURL)
  XCTAssertTrue(FileManager.default.fileExists(atPath: SUT_resourceURL.path))
  
  try await modelMainContext.perform {
   
   XCTAssertEqual(SNIPPET.singleContentElements.count, 1)
   XCTAssertEqual(SNIPPET.folderedContentElements.count, 1)
   XCTAssertEqual(SNIPPET.unfolderedContentElements.count, 0)
   XCTAssertEqual(SNIPPET.folders.count, 1)
   XCTAssertTrue(SUT_FOLDER.folderedElements.isEmpty)
   XCTAssertNotNil (SUT.managedObjectContext)
   XCTAssertNotNil (SUT.folder)
   XCTAssertEqual(SUT.tag, "MOVED TO \(SUT.folder?.tag ?? "")")
   let URL = try XCTUnwrap(SUT.url?.path)
   XCTAssertTrue(FileManager.default.fileExists(atPath: URL))
   XCTAssertEqual(SUT_resourceURL.path, URL)
   XCTAssertEqual(SUT_resourceURL.pathComponents.last, SUT.id?.uuidString)
   XCTAssertEqual(SUT_resourceURL.pathComponents.dropLast().last, SUT.folder?.id?.uuidString)
   XCTAssertEqual(SUT_resourceURL.pathComponents.dropLast(2).last, SNIPPET.id?.uuidString)
   
  }
  
   //try await storageRemoveHelperAsync(for: SNIPPETS)
  
 }//test...
 
 
 
}//final class NMSnippetsManipulationAsyncTests...

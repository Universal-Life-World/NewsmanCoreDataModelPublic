import XCTest
import NewsmanCoreDataModel

//MARK: ALL SNIPPETS CREATION UNIT TESTS EXTENSION.
@available(iOS 15.0, macOS 12.0, *)
final class NMBaseSnippetsCreationAsyncTests: NMBaseSnippetsAsyncTests {
 
  //MARK: Test that when all snippets are created in MAIN MOC without persistance they have not NIL ID field!
 final func test_Snippets_CREATED_Correctly_with_NO_Persistance() async throws {
  
 
  //ARRANGE...
  let SUTS_COUNT = 6
  let PERSISTED = false // NO PERSISTANCE!
  let modelMainContext = await model.mainContext // GET ASYNC MAIN MODEL CONTEXT!
  
  //ACTION...
  let SUTS = try await createAllSnippets(persisted: PERSISTED)
  
 
  //ASSERT (IN MAIN QUEUE CONTEXT)...
  await modelMainContext.perform {
  //await MainActor.run{
   XCTAssertEqual(SUTS.count, SUTS_COUNT)
   XCTAssertTrue(SUTS.allSatisfy{ $0.objectID.isTemporaryID }) //Assert that all snippets are not persisted yet!

   let ids = SUTS.compactMap{ $0.id }
   XCTAssertEqual(ids.count, SUTS_COUNT) // Assert that all snippets have id!

   let contexts = SUTS.compactMap{$0.managedObjectContext}
   XCTAssertEqual(contexts.count, SUTS_COUNT) // Assert that all snippets have MOC!

   XCTAssertEqual(Set(contexts).count, 1) // Assert that all snippets have the same unique MOC!
   XCTAssertEqual(Set(contexts).first, modelMainContext) // Assert that snippets' MOC is model main MOC!
  //}
  }

  //FINALLY - STORAGE CLEAN-UP!
   try await storageRemoveHelperAsync(for: SUTS)
  
  
  
  
 }
 
 //MARK: Test that when all snippets are created in MAIN MOC with persistance they have not NIL ID field!
 final func test_Snippets_CREATED_Correctly_WITH_Persistance() async throws{
  
  //ARRANGE...
  let SUTS_COUNT = 6
  let PERSISTED = true // WITH PERSISTANCE!
  let modelMainContext = await model.mainContext // GET ASYNC MAIN MODEL CONTEXT!
  
  
  //ACTION...
  let SUTS = try await createAllSnippets(persisted: PERSISTED)
  
 
  
  //ASSERT (IN MAIN QUEUE CONTEXT)...
  await modelMainContext.perform {
   XCTAssertEqual(SUTS.count, SUTS_COUNT)
   XCTAssertFalse(SUTS.allSatisfy{ $0.objectID.isTemporaryID }) //Assert that all snippets are persisted in PS!
   
   let ids = SUTS.compactMap{ $0.id }
   XCTAssertEqual(ids.count, SUTS_COUNT) // Assert that all snippets have id!
   
   let contexts = SUTS.compactMap{$0.managedObjectContext}
   XCTAssertEqual(contexts.count, SUTS_COUNT) // Assert that all snippets have MOC!
   
   XCTAssertEqual(Set(contexts).count, 1) // Assert that all snippets have the same unique MOC!
   XCTAssertEqual(Set(contexts).first, modelMainContext) // Assert that snippets' MOC is model main MOC!
   
  }
  
  //FINALLY - STORAGE CLEAN-UP!
  try await storageRemoveHelperAsync(for: SUTS)
  
 }
 
  //MARK: Test that when all snippets are created in MAIN MOC with corresponding child MO!
 final func test_Snippets_CREATED_Correctly_WITH_Persistance_WITH_CHILDREN() async throws {
  
   //ARRANGE...
  let SUTS_COUNT = 6
  let CHILDREN_COUNT = Int.random(in: 1...100)
  let FOLDERS_COUNT = 1 //Int.random(in: 1...100)
  let PERSISTED = true // WITH PERSISTANCE!
  let modelMainContext = await model.mainContext // GET ASYNC MAIN MODEL CONTEXT!
  let folderName = "Folder"
  
  func assertChildren<E: NMContentElement,
                      C: NMContentElementsContainer>(children: [E],
                                                     in container: C,
                                                     _ CHILDREN_COUNT: Int) async throws
  {
   await modelMainContext.perform {
    XCTAssertFalse(children.allSatisfy{ $0.objectID.isTemporaryID })
    XCTAssertTrue(children.allSatisfy{ $0.id != nil })
     // Assert that all snippets single elements have id!
    
    let contexts = children.compactMap{$0.managedObjectContext}
    XCTAssertEqual(contexts.count, CHILDREN_COUNT)
     // Assert that all snippets single elements have MOC!
    
    XCTAssertEqual(Set(contexts).count, 1)
     // Assert that all snippets single elements have the same unique MOC!
    XCTAssertEqual(Set(contexts).first, modelMainContext)
     // Assert that snippets' single elements  MOC is model main MOC!
    
    XCTAssertEqual(container.singleContentElements.count, CHILDREN_COUNT)
    XCTAssertEqual(Set(container.singleContentElements), Set(children))
    XCTAssertFalse(children.allSatisfy{ $0.isNew })
    XCTAssertTrue(children.allSatisfy{ $0.isFoldered })
    XCTAssertTrue(children.allSatisfy{ $0.folder?.tag == folderName })
    XCTAssertTrue(children.allSatisfy{ $0.folder?.container == container })
    XCTAssertTrue(children.allSatisfy{ $0.isValid })
    let P1 = NSPredicate(format: "SELF.container == %@", container)
    let P2 = NSPredicate(format: "SELF.mixedSnippet == %@", container)
    let XOR = NSCompoundPredicate(xorPredicateWithSubpredicates: [P1, P2])
    XCTAssertTrue(children.allSatisfy{ XOR.evaluate(with: $0)})
    
   }
  }
  
  func assertFolders <F: NMContentFolder,
                      C: NMContentElementsContainer>(folders: [F],
                                                     in container: C,
                                                     _ FOLDERS_COUNT: Int) async throws
  {
   await modelMainContext.perform {
    XCTAssertFalse(folders.allSatisfy{ $0.objectID.isTemporaryID })
    XCTAssertTrue(folders.allSatisfy{ $0.id != nil })
     // Assert that all snippets folders have id!
    
    let contexts = folders.compactMap{$0.managedObjectContext}
    XCTAssertEqual(contexts.count, FOLDERS_COUNT)
     // Assert that all snippets folders have MOC!
    
    XCTAssertEqual(Set(contexts).count, 1)
     // Assert that all snippets folders have the same unique MOC!
    XCTAssertEqual(Set(contexts).first, modelMainContext)
     // Assert that snippets' folders MOC is model main MOC!
    
    XCTAssertEqual(container.folders.count, FOLDERS_COUNT)
    XCTAssertEqual(Set(container.folders), Set(folders))
    XCTAssertFalse(folders.allSatisfy{ $0.isNew })
    XCTAssertTrue(folders.allSatisfy{ $0.isValid })
    let P1 = NSPredicate(format: "SELF.container == %@", container)
    let P2 = NSPredicate(format: "SELF.mixedSnippet == %@", container)
    let XOR = NSCompoundPredicate(xorPredicateWithSubpredicates: [P1, P2])
    XCTAssertTrue(folders.allSatisfy{ XOR.evaluate(with: $0)})
    
   }
  }
  
  
   //ACTION...
  let SUTS = try await createAllSnippets(persisted: PERSISTED)
  
  for SUT in SUTS {
   
   switch SUT {
    case let photoSnippet as NMPhotoSnippet:
     
     let photoFolders = try await photoSnippet.createFolders(FOLDERS_COUNT,
                                                             persist: PERSISTED){ $0[0].tag = folderName }
     
     try await assertFolders(folders: photoFolders, in: photoSnippet, FOLDERS_COUNT )
     
     let photos = try await photoSnippet.createSingles(CHILDREN_COUNT,
                                                       persist: PERSISTED,
                                                       in: photoFolders[0])
     
     try await assertChildren(children: photos, in: photoSnippet, CHILDREN_COUNT)
     
     
    case let audioSnippet as NMAudioSnippet:
     
     let audioFolders = try await audioSnippet.createFolders(FOLDERS_COUNT,
                                                             persist: PERSISTED){ $0[0].tag = folderName }
     
     try await assertFolders(folders: audioFolders, in: audioSnippet, FOLDERS_COUNT)
     
     let audios = try await audioSnippet.createSingles(CHILDREN_COUNT,
                                                       persist: PERSISTED,
                                                       in: audioFolders[0])
     
     try await assertChildren(children: audios, in: audioSnippet, CHILDREN_COUNT)
     
     
    case let textSnippet as NMTextSnippet:
     
     let textFolders = try await textSnippet.createFolders(FOLDERS_COUNT,
                                                           persist: PERSISTED) { $0[0].tag = folderName }
     
     try await assertFolders(folders: textFolders, in: textSnippet, FOLDERS_COUNT)

     
     let texts = try await textSnippet.createSingles(CHILDREN_COUNT,
                                                     persist: PERSISTED,
                                                     in: textFolders[0])
     
     try await assertChildren(children: texts, in: textSnippet, CHILDREN_COUNT)
     
     
    case let videoSnippet as NMVideoSnippet:
     
     let videoFolders = try await videoSnippet.createFolders(FOLDERS_COUNT,
                                                             persist: PERSISTED){ $0[0].tag = folderName }
     
     try await assertFolders(folders: videoFolders, in: videoSnippet, FOLDERS_COUNT)
     
     let videos = try await videoSnippet.createSingles(CHILDREN_COUNT,
                                                       persist: PERSISTED,
                                                       in: videoFolders[0])
     
     try await assertChildren(children: videos, in: videoSnippet, CHILDREN_COUNT)
     
     

    case let mixedSnippet as NMMixedSnippet:

     let photoFolders = try await mixedSnippet.createFolders(FOLDERS_COUNT,
                                                             of: NMPhotoFolder.self,
                                                             persist: PERSISTED){ $0[0].tag = folderName }

     try await assertFolders(folders: photoFolders as! [NMPhotoFolder], in: mixedSnippet, FOLDERS_COUNT)

     let photos = try await mixedSnippet.createSingles(CHILDREN_COUNT,
                                                       of: NMPhoto.self,
                                                       in: photoFolders[0] as? NMPhotoFolder,
                                                       persist: PERSISTED)

     try await assertChildren(children: photos, in: mixedSnippet, CHILDREN_COUNT)

    
     
     
     
    default: break
   }
  
  }
  
  
   //ASSERT (IN MAIN QUEUE CONTEXT)...
  await modelMainContext.perform {
   XCTAssertEqual(SUTS.count, SUTS_COUNT)
   XCTAssertFalse(SUTS.allSatisfy{ $0.objectID.isTemporaryID }) //Assert that all snippets are persisted in PS!
   
   let ids = SUTS.compactMap{ $0.id }
   XCTAssertEqual(ids.count, SUTS_COUNT) // Assert that all snippets have id!
   
   let contexts = SUTS.compactMap{$0.managedObjectContext}
   XCTAssertEqual(contexts.count, SUTS_COUNT) // Assert that all snippets have MOC!
   
   XCTAssertEqual(Set(contexts).count, 1) // Assert that all snippets have the same unique MOC!
   XCTAssertEqual(Set(contexts).first, modelMainContext) // Assert that snippets' MOC is model main MOC!
   
  
  }
  
   //FINALLY - STORAGE CLEAN-UP!
  try await storageRemoveHelperAsync(for: SUTS)
  
 }
 
 //MARK: Test that when all 6 defined types of Snippets are created in BG MOC with persistance they have not NIL ID field when fetched in main context!
 final func test_Snippets_CREATED_IN_BACKGROUND_MOC_Correctly_with_Persistance() async throws {
  
  //ARRANGE...
  let SUTS_COUNT = 6
  let PERSISTED = true // WITH PERSISTANCE!
  let modelMainContext = await model.mainContext // GET ASYNC MAIN MODEL CONTEXT!
  
  //ACTION...
  let SUTS = try await backgroundCreateAllSnippets(persisted: PERSISTED)
  
  //ASSERT (IN MAIN QUEUE CONTEXT)...
  await modelMainContext.perform {
   XCTAssertEqual(SUTS.count, SUTS_COUNT)
   XCTAssertEqual(SUTS.compactMap{ $0.id }.count,  SUTS_COUNT)
   XCTAssertFalse(SUTS.allSatisfy(\.objectID.isTemporaryID))
   let contexts = Set(SUTS.compactMap(\.managedObjectContext))
   XCTAssertTrue(contexts.first! == modelMainContext)
   XCTAssertTrue(contexts.count == 1)
   XCTAssertTrue(contexts.first!.concurrencyType == .mainQueueConcurrencyType)
   
  }
  
  //FINALLY - STORAGE CLEAN-UP!
  try await storageRemoveHelperAsync(for: SUTS)
  
 }
 
 //MARK: Test that when all snippets are created in BG MOC without persistance they have NIL ID field when fetched in main context!
 
 final func test_HOMOGENEOUS_Snippets_CREATED_IN_BACKGROUND_MOC_Correctly_with_NO_Persistance() async throws{
  
  //ARRANGE...
  let SUTS_COUNT = 10
  let nameTag = "Random Named"
  let PERSISTED = false // NO PERSISTANCE!
  let modelMainContext = await model.mainContext // GET ASYNC MAIN MODEL CONTEXT!
  
  //ACTION...
  let SUTS = try await model.backgroundCreate(persist: PERSISTED,
                                              objectType: NMBaseSnippet.self,
                                              objectCount: SUTS_COUNT) {
   XCTAssertTrue($0.count == SUTS_COUNT)
   $0.randomElement()?.nameTag = nameTag
  }
 
  //ASSERT...
  await modelMainContext.perform {
   XCTAssertTrue(SUTS.allSatisfy{$0.objectID.isTemporaryID})
   let contexts = Set(SUTS.compactMap(\.managedObjectContext))
   XCTAssertTrue(contexts.count == 1)
   XCTAssertTrue(contexts.first!.concurrencyType == .mainQueueConcurrencyType)
   XCTAssertTrue(contexts.first! == modelMainContext)
   XCTAssertEqual(SUTS.compactMap{ $0.id }.count, 0) //no data in row PSC row cache yet!
   XCTAssertFalse(SUTS.contains{ $0.nameTag == nameTag }) //no data in row PSC row cache yet!
  }
  
  //FINALLY - STORAGE CLEAN-UP!
  try await storageRemoveHelperAsync(for: SUTS)
  
 }
 
 //MARK: Test that when all snippets are created in BG MOC with persistance they have not NIL ID field when fetched in main context!
 
 final func test_HOMOGENEOUS_Snippets_CREATED_IN_BACKGROUND_MOC_Correctly_with_Persistance() async throws{
  
  //ARRANGE...
  let SUTS_COUNT = 10
  let nameTag = "Random Named"
  let PERSISTED = true // NO PERSISTANCE!
  let modelMainContext = await model.mainContext // GET ASYNC MAIN MODEL CONTEXT!
  
  let SUTS = try await model.backgroundCreate(persist: PERSISTED,
                                              objectType: NMBaseSnippet.self,
                                              objectCount: SUTS_COUNT){
   XCTAssertTrue($0.count == SUTS_COUNT)
   $0.randomElement()?.nameTag = nameTag
  }
 
   //ASSERT...
  await modelMainContext.perform {
   XCTAssertFalse(SUTS.allSatisfy{$0.objectID.isTemporaryID})
   let contexts = Set(SUTS.compactMap(\.managedObjectContext))
   XCTAssertTrue(contexts.count == 1)
   XCTAssertTrue(contexts.first!.concurrencyType == .mainQueueConcurrencyType)
   XCTAssertTrue(contexts.first! == modelMainContext)
   XCTAssertEqual(SUTS.compactMap{ $0.id }.count, SUTS_COUNT) //data in row PSC row cache now!
   XCTAssertTrue(SUTS.contains{ $0.nameTag == nameTag }) //data in row PSC row cache now!
  }
  
   //FINALLY - STORAGE CLEAN-UP!
  try await storageRemoveHelperAsync(for: SUTS)
  
 }
 
 /* MARK: Test that when 1 random snippet out of predefined types of Snippets are created in MAIN MOC using entity descriptions with persistance it has not NIL ID field! */
 
 final func test_Random_Snippet_CREATED_IN_MAIN_MOC_USING_NSEntityDescriptions_Correctly_with_Persistance() async throws{
   //ARRANGE...
  let nameTag = "Random Named"
  let PERSISTED = true // PERSISTANCE!
  let modelMainContext = await model.mainContext // GET ASYNC MAIN MODEL CONTEXT!
  
  let randomEntity = [NMBaseSnippet.self,
                      NMTextSnippet.self,
                      NMPhotoSnippet.self,
                      NMVideoSnippet.self,
                      NMAudioSnippet.self,
                      NMMixedSnippet.self].randomElement()!
  
   //ACTION...
  
  let SUT = try await model.create(persist: PERSISTED, entityType: randomEntity){
   ($0 as? NMBaseSnippet)?.nameTag = nameTag
  }
  
   //ASSERT...
  
  try await modelMainContext.perform {
   let context = try XCTUnwrap(SUT.managedObjectContext)
   XCTAssertTrue(context.concurrencyType == .mainQueueConcurrencyType)
   XCTAssertTrue(context == modelMainContext)
   XCTAssertFalse(SUT.objectID.isTemporaryID )
   XCTAssertNotNil((SUT as? NMBaseSnippet)?.id )
   XCTAssertTrue((SUT as? NMBaseSnippet)?.nameTag == nameTag )
  }
  
  try await storageRemoveHelperAsync(for: [SUT] as! [NMBaseSnippet])
 
 }
 
 /* MARK: Test that when all 6 defined types of Snippets are created in MAIN MOC using entity descriptions with persistance they have not NIL ID! */
 
 final func test_Snippets_CREATED_IN_MAIN_MOC_USING_NSEntityDescriptions_Correctly_with_Persistance() async throws{
  
   //ARRANGE...
  let nameTag = "Random Named"
  let PERSISTED = true // PERSISTANCE!
  let modelMainContext = await model.mainContext // GET ASYNC MAIN MODEL CONTEXT!
  
  let entitites = [NMBaseSnippet.self,
                   NMTextSnippet.self,
                   NMPhotoSnippet.self,
                   NMVideoSnippet.self,
                   NMAudioSnippet.self,
                   NMMixedSnippet.self]
  
   //ACTION...
  
  let SUTS = try await model.create(persist: PERSISTED, entityTypes: entitites){
   XCTAssertTrue($0.count == entitites.count)
   ($0.randomElement() as? NMBaseSnippet)?.nameTag = nameTag
  }
  
   //ASSERT...
  
  await modelMainContext.perform {
   let contexts = Set(SUTS.compactMap(\.managedObjectContext))
   XCTAssertTrue(contexts.count == 1)
   XCTAssertTrue(contexts.first!.concurrencyType == .mainQueueConcurrencyType)
   XCTAssertTrue(contexts.first! == modelMainContext)
   XCTAssertFalse(SUTS.allSatisfy{ $0.objectID.isTemporaryID })
   XCTAssertEqual(SUTS.compactMap{ ($0 as? NMBaseSnippet)?.id }.count, entitites.count)
   XCTAssertTrue(SUTS.contains{ ($0 as? NMBaseSnippet)?.nameTag == nameTag })
  }
  
  try await storageRemoveHelperAsync(for: SUTS as! [NMBaseSnippet])
 }
 
 //MARK: Test that when all 6 defined types of Snippets are created in BG MOC using entity descriptions with persistance they have not NIL ID field when fetched in main context!
 final func test_Snippets_CREATED_IN_BACKGROUND_MOC_USING_NSEntityDescriptions_Correctly_with_Persistance() async throws{
  
  //ARRANGE...
  let nameTag = "Random Named"
  let PERSISTED = true // NO PERSISTANCE!
  let modelMainContext = await model.mainContext // GET ASYNC MAIN MODEL CONTEXT!

  let entitites = [NMBaseSnippet.self,
                   NMTextSnippet.self,
                   NMPhotoSnippet.self,
                   NMVideoSnippet.self,
                   NMAudioSnippet.self,
                   NMMixedSnippet.self]
  
  //ACTION...
  
  let SUTS = try await model.backgroundCreate(persist: PERSISTED, entityTypes: entitites){
   XCTAssertTrue($0.count == entitites.count)
   ($0.randomElement() as? NMBaseSnippet)?.nameTag = nameTag
  }
  
  //ASSERT...
  
  await modelMainContext.perform {
   let contexts = Set(SUTS.compactMap(\.managedObjectContext))
   XCTAssertTrue(contexts.count == 1)
   XCTAssertTrue(contexts.first!.concurrencyType == .mainQueueConcurrencyType)
   XCTAssertTrue(contexts.first! == modelMainContext)
   XCTAssertFalse(SUTS.allSatisfy{ $0.objectID.isTemporaryID })
   XCTAssertEqual(SUTS.compactMap{ ($0 as? NMBaseSnippet)?.id }.count, entitites.count)
   XCTAssertTrue(SUTS.contains{ ($0 as? NMBaseSnippet)?.nameTag == nameTag })
  }
  
  try await storageRemoveHelperAsync(for: SUTS as! [NMBaseSnippet])
 }
 
 //MARK: Test that when all snippets are created with task cancellation error!
 final func test_Snippets_CREATED_WITH_CANCELLATION () async throws {
  
  //ARRANGE...
  let PERSISTED = true // WITH PERSISTANCE!
  
  //ACTION...
  let SUTS_task = Task { try await createAllSnippets(persisted: PERSISTED) }
  SUTS_task.cancel()
  
  //ASSERT...
  try await XCTAssertThrowsErrorAsync(try await SUTS_task.value,
                                      errorType: CancellationError.self)
 
 }
 
 //MARK: Test that when all snippets are created with task cancellation error in background context!
 final func test_Snippets_CREATED_IN_BACKGROUND_MOC_WITH_CANCELLATION () async throws {
  
  //ARRANGE...
  let PERSISTED = true // WITH PERSISTANCE!
  
  //ACTION...
  let SUTS_task = Task { try await backgroundCreateAllSnippets(persisted: PERSISTED) }
  SUTS_task.cancel() // CANCELL TOP LEVEL TASK!
  
  //ASSERT...
  try await XCTAssertThrowsErrorAsync(try await SUTS_task.value,
                                      errorType: CancellationError.self)
  
  
 }
 
 //MARK: Test that when all snippets are created and persisted they can be fetched from MOC.
 final func test_Snippets_CREATED_correctly_With_Persistance() async throws{
  
  //ARRANGE...
  let PERSISTED = true // WITH PERSISTANCE!
  
  //ACTION...
  let SUTS = try await createAllSnippets(persisted: PERSISTED)
  
  //ASSERT...
  try await snippetsPersistanceCheckHelperAsync(for: SUTS) //FETCH SNIPPETS...
  
  //STORAGE CLEAN-UP...
  try await storageRemoveHelperAsync(for: SUTS)
  
 }
 
//MARK: Test that when all snippets are created in BGMOC and persisted they can be fetched from main MOC.
 final func test_Snippets_CREATED_IN_BACKGROUND_MOC_correctly_With_Persistance() async throws{
  
  //ARRANGE...
  let PERSISTED = true // WITH PERSISTANCE!
  
  //ACTION...
  let SUTS = try await backgroundCreateAllSnippets(persisted: PERSISTED)
  
  //ASSERT...
  try await snippetsPersistanceCheckHelperAsync(for: SUTS) //FETCH SNIPPETS IN MAIN MOC...
  
  //STORAGE CLEAN-UP...
  try await storageRemoveHelperAsync(for: SUTS)
  
 }

//MARK: Test that all snippets are created and persisted with modification block and last access & modification time stamps are updated properly.
 
 final func test_Snippets_CREATED_correctly_WITH_Persistance_and_modification_block() async throws {
  
  //ARRANGE...

  let PERSISTED = true // WITH PERSISTANCE!
  let modelMainContext = await model.mainContext // GET ASYNC MAIN MODEL CONTEXT!
  
  @Sendable func block( _ snippet: NMBaseSnippet) throws {
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
  
  //ACTION...
  let start = Date()
  let SUTS = try await createAllSnippets(persisted: PERSISTED, block: block)
  let finish = Date()
  
  //ASSERT...
  await modelMainContext.perform {
   XCTAssertTrue(SUTS.allSatisfy{ $0.priority == .high })
   XCTAssertTrue(SUTS.allSatisfy{ $0.status == .privy })
   XCTAssertTrue(SUTS.allSatisfy{ $0.lastModifiedTimeStamp! > start && $0.lastModifiedTimeStamp! < finish })
  }
  
  //FILE STORAGE CLEAN-UP...
  try await storageRemoveHelperAsync(for: SUTS)
  
 }
 
}

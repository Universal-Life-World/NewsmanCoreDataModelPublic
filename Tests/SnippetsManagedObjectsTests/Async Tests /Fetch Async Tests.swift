import XCTest
import NewsmanCoreDataModel

public func zip<A, B, C>(_ a: A, _ b: B, _ c: C) -> [(A.Element, B.Element, C.Element)]
               where A: Sequence, B: Sequence, C: Sequence {
 
 zip(a, zip(b,c)).map{($0.0, $0.1.0, $0.1.1)}
}

 //MARK: ALL SNIPPETS CREATION UNIT TESTS EXTENSION.
@available(iOS 15.0, macOS 12.0, *)
final class NMBaseSnippetsFetchingAsyncTests: NMBaseSnippetsAsyncTests {
 
 @MainActor lazy var window: UIWindow! = { () -> UIWindow in
  let window = UIWindow(frame: UIScreen.main.bounds)
  window.makeKeyAndVisible()
  return window
 }()
 
 // Service method to be called on main thread setting window ROOT VC property with SUTS (snippets) table VC
 @MainActor func makeRootViewController(_ vc: UIViewController)  { window.rootViewController = vc }
 @MainActor func releaseRootViewController()  { window.rootViewController = nil; window = nil }
 
 /* MARK: ---- ACRONYMS USED FOR TEST CASE DESCRIPTIONS BELOW -------
    MARK: (1) Diffable Data Source Snashot (NSDiffableDataSourceSnapshot) - DDSS
    MARK: (2) Snapshot Fetch Controller - SFC
    MARK: (3) CoreData NSFetchResultsController - FRC
    MARK: (4) Main thread NSManagedObjectContext - MMOC
    MARK: (5) Background thread NSManagedObjectContext - BGMOC
    MARK: (6) SUTS = NMBaseSnippet(s)
    MARK: (7) SUTS TVC = UIViewController with view == NMSnippetsTestableTableView
  
  */
 
 /* MARK: This test case tests that first DDSS is generated properly once the SFC is instantiated and queried for snapshots flow. The first DDSS should reflect the initial data state after initial fetch from MMOC. This test does not perform state reconcilation with associated table view!*/
 
 final func test_that_when_all_snippets_fetched_FIRST_DDSS_generated_properly_once() async throws {
  
  //ARRANGE...
  let SUTS_COUNT = 6
  let PERSISTED = true // WITH PERSISTANCE!
  let modelMainContext = await model.mainContext // GET ASYNC MAIN MODEL CONTEXT!
  let SUTS = try await createAllSnippets(persisted: PERSISTED)

  await modelMainContext.perform { SUTS.forEach{ $0.nameTag = String(describing: $0) } }
  
  let sortDescriptors = [NSSortDescriptor(keyPath: \NMBaseSnippet.nameTag, ascending: true)]
  
  let fetcher = NMSnapshotFetchController<NMBaseSnippet>(context: modelMainContext,
                                                         sortDescriptors: sortDescriptors)
  
  //ACTION...
  
  let snapshot = try await fetcher.first! //wait for 1st snapshot and finish...

  
  //ASSERT...
  XCTAssertTrue(snapshot.numberOfItems == SUTS_COUNT)
  XCTAssertTrue(snapshot.numberOfSections == 1)
 
  //CLEAN-UP...
  //try await storageRemoveHelperAsync(for: SUTS)
  
 }
 
 /* MARK: This test case tests that first DDSS is generated properly once the SFC is instantiated and queried for snapshots flow. The first DDSS should reflect the initial data state after initial fetch from MMOC. This test does perform state reconcilation with associated table view!*/
 
 final func test_when_FIRST_DDSS_fetched_and_applied_to_SUTS_TV_with_properly() async throws {
  
   //ARRANGE...
  let SUTS_COUNT = 6
  let PERSISTED = true // WITH PERSISTANCE!
  let modelMainContext = await model.mainContext // GET ASYNC MAIN MODEL CONTEXT!
  let SUTS = try await createAllSnippets(persisted: PERSISTED)
  
   
  await modelMainContext.perform { SUTS.forEach{ $0.nameTag = String(describing: $0) } }
  
  let sortDescriptors = [NSSortDescriptor(keyPath: \NMBaseSnippet.nameTag, ascending: true)]
  
  let fetcher = NMSnapshotFetchController<NMBaseSnippet>(context: modelMainContext,
                                                         sortDescriptors: sortDescriptors)
  
  let SUTS_TVC = await NMSnippetsTestableTableViewController(context: modelMainContext, fetcher: fetcher)
  { @MainActor ( tv, snapshot ) -> Bool in
  
   //ASSERT...
   XCTAssertTrue(snapshot.numberOfItems == SUTS_COUNT)
   XCTAssertTrue(snapshot.numberOfSections == 1)
   
   let TV_DDS = tv.dataSource as? NMSnippetsTestableTableViewDiffableDataSource
   let dds = try XCTUnwrap(TV_DDS, "Testable TV must have diffable data source!")
   
   let tv_snapshot = dds.snapshot()
 
   XCTAssertEqual(tv_snapshot, snapshot)
   
   let TV_NS = dds.numberOfSections(in: tv)

   XCTAssertEqual(TV_NS, 1, "Testable TV must have only 1 section this test!")

   let itemsN =  dds.tableView(tv, numberOfRowsInSection: 0)

   XCTAssertEqual(itemsN, SUTS_COUNT, "Testable TV must have \(SUTS_COUNT) cells in this test!")
   
   let SUTS_TV_CELLS = ((0..<SUTS_COUNT)
    .compactMap{tv.cellForRow(at: IndexPath(row: $0, section: 0)) as? NMSnippetsTestableTableViewCell})
   
   XCTAssertLessThanOrEqual(SUTS_TV_CELLS.count, SUTS_COUNT)
   
   let cellNameTags = Set(SUTS_TV_CELLS.compactMap{ $0.nameTagLabelText })
   let SUTS_NameTags = Set(SUTS.compactMap{ $0.nameTag })
   
   XCTAssertTrue(cellNameTags.isSubset(of: SUTS_NameTags))
   
   return true
   
  }
  
  //PLACE TVC INTO UI!!!
  await makeRootViewController(SUTS_TVC)
  
  // WAIT FOR RESULT SNAPSHOTS...
  try await SUTS_TVC.waitForSnapshots()
   
   //CLEAN-UP...
  try await storageRemoveHelperAsync(for: SUTS)
 }
 
 final func test_when_fetched_the_snapshot_generated_properly_once_with_sections () async throws {
  
   //ARRANGE...
  let SUTS_COUNT = 6
  let PERSISTED = true // WITH PERSISTANCE!
  let modelMainContext = await model.mainContext // GET ASYNC MAIN MODEL CONTEXT!
  let SUTS = try await createAllSnippets(persisted: PERSISTED)
  let SECTIONS_COUNT = 6
  
  await modelMainContext.perform { SUTS.forEach{ $0.nameTag = String(describing: $0) } }
  
  let sortDescriptors = [NSSortDescriptor(key: #keyPath(NMBaseSnippet.nameTag), ascending: true)]
  
  let fetcher = NMSnapshotFetchController<NMBaseSnippet>(context: modelMainContext,
                                                         sortDescriptors: sortDescriptors,
                                                         sectionNameKeyPath: #keyPath(NMBaseSnippet.nameTag)
  )
  
  
  
   //ACTION...
  
  let snapshot = try await fetcher.first!
  
   //ASSERT...
  
  XCTAssertTrue(snapshot.numberOfItems == SUTS_COUNT)
  XCTAssertTrue(snapshot.numberOfSections == SECTIONS_COUNT)
  
  try await modelMainContext.perform {
   for SUT in SUTS {
    
    let nameTag = try XCTUnwrap(SUT.nameTag)
    
//    print(nameTag)
    let sectionName = try XCTUnwrap(snapshot.sectionIdentifier(containingItem: SUT.objectID))
    XCTAssertEqual(nameTag, sectionName)
    XCTAssertEqual(snapshot.numberOfItems(inSection: sectionName), 1)
    let SUT_ID = try XCTUnwrap(snapshot.itemIdentifiers(inSection: sectionName).first)
    XCTAssertEqual(SUT_ID, SUT.objectID)
   }
  }
  
 
  
   //CLEAN-UP...
  try await storageRemoveHelperAsync(for: SUTS)
 }
 
 final func test_when_1st_DDSS_fetched_and_applied_to_SUTS_TV_DDS_with_section_name_equal_SUT_nameTag() async throws {
  
   //ARRANGE...
  let SUTS_COUNT = 6
  let PERSISTED = true // WITH PERSISTANCE!
  let modelMainContext = await model.mainContext // GET ASYNC MAIN MODEL CONTEXT!
  let SUTS = try await createAllSnippets(persisted: PERSISTED)
  let SECTIONS_COUNT = 6
  
  await modelMainContext.perform { SUTS.forEach{ $0.nameTag = String(describing: $0) } }
  
  let sortDescriptors = [NSSortDescriptor(key: #keyPath(NMBaseSnippet.nameTag), ascending: true)]
  
  let fetcher = NMSnapshotFetchController<NMBaseSnippet>(context: modelMainContext,
                                                         sortDescriptors: sortDescriptors,
                                                         sectionNameKeyPath: #keyPath(NMBaseSnippet.nameTag))
  
   //ACTION...
  
  let SUTS_TVC = await NMSnippetsTestableTableViewController(context: modelMainContext, fetcher: fetcher)
  { @MainActor ( tv, snapshot ) -> Bool in
   
    //ASSERT...
   XCTAssertTrue(snapshot.numberOfItems == SUTS_COUNT)
   XCTAssertTrue(snapshot.numberOfSections == SECTIONS_COUNT)
   
   let TV_DDS = tv.dataSource as? NMSnippetsTestableTableViewDiffableDataSource
   let dds = try XCTUnwrap(TV_DDS, "Testable TV must have diffable data source!")
   
   let tv_snapshot = dds.snapshot()
   
   XCTAssertEqual(tv_snapshot, snapshot, "SUTS TV snapshot must be the the same as this one!")
   
   let TV_NS = dds.numberOfSections(in: tv)
   
   XCTAssertEqual(TV_NS, SECTIONS_COUNT, "Testable TV must \(SECTIONS_COUNT) sections in this test!")
   
   try await modelMainContext.perform {
    for SUT in SUTS {
     
     let nameTag = try XCTUnwrap(SUT.nameTag)
     
     let sectionName = try XCTUnwrap(snapshot.sectionIdentifier(containingItem: SUT.objectID))
     XCTAssertEqual(nameTag, sectionName)
     
     let section = try XCTUnwrap(snapshot.indexOfSection(sectionName))
     
     let tv_section_title = dds.tableView(tv, titleForHeaderInSection: section)
     XCTAssertEqual(tv_section_title, nameTag)
     
     let cellIndexPath = IndexPath(row: 0, section: section)
     
     
     guard let cell = tv.cellForRow(at: cellIndexPath) as? NMSnippetsTestableTableViewCell else { return }
     //print (cell)
     let cellNameTag = try XCTUnwrap(cell.nameTagLabelText)
     
     XCTAssertEqual(nameTag, cellNameTag)
     
     XCTAssertEqual(snapshot.numberOfItems(inSection: sectionName), 1)
     let SUT_ID = try XCTUnwrap(snapshot.itemIdentifiers(inSection: sectionName).first)
     XCTAssertEqual(SUT_ID, SUT.objectID)
    }
   }
   
   return true
  }
   //PLACE TVC INTO UI!!!
  await makeRootViewController(SUTS_TVC)
  
   // WAIT FOR RESULT SNAPSHOTS...
  try await SUTS_TVC.waitForSnapshots()
  
   //CLEAN-UP...
  try await storageRemoveHelperAsync(for: SUTS)
 }

 final func test_when_fetched_the_snapshot_generated_properly_once_with_alfa_sections () async throws {
  
   //ARRANGE...
  let SUTS_COUNT = 6
  let PERSISTED = true // WITH PERSISTANCE!
  let modelMainContext = await model.mainContext // GET ASYNC MAIN MODEL CONTEXT!
  let SUTS = try await createAllSnippets(persisted: PERSISTED)
  let SECTIONS_COUNT = 6
  let SUTS_NAMES = ["Audio", "Base", "Mixed", "Photo", "Text", "Video"]
  
  await modelMainContext.perform { zip(SUTS, SUTS_NAMES).forEach { pair in pair.0.nameTag = pair.1 } }
  
  let sortDescriptors = [NSSortDescriptor(key: #keyPath(NMBaseSnippet.nameTag), ascending: true)]
  
  let fetcher = NMSnapshotFetchController<NMBaseSnippet>(context: modelMainContext,
                                                         sortDescriptors: sortDescriptors,
                                                         sectionNameKeyPath: #keyPath(NMBaseSnippet.sectionAlphaIndex))
 
  
   //ACTION...
  
  let snapshot = try await fetcher.first!
  
  
   //ASSERT...
  
  XCTAssertTrue(snapshot.numberOfItems == SUTS_COUNT)
  XCTAssertTrue(snapshot.numberOfSections == SECTIONS_COUNT)
  
  try await modelMainContext.perform {
   for SUT in SUTS {
    let nameTag = try XCTUnwrap(SUT.nameTag)
    let sectionName = try XCTUnwrap(snapshot.sectionIdentifier(containingItem: SUT.objectID))
    XCTAssertEqual(sectionName, String(nameTag.prefix(1)))
    XCTAssertEqual(snapshot.numberOfItems(inSection: sectionName), 1)
    let SUT_ID = try XCTUnwrap(snapshot.itemIdentifiers(inSection: sectionName).first)
    XCTAssertEqual(SUT_ID, SUT.objectID)
    let sectionIndex =  try XCTUnwrap(snapshot.indexOfSection(sectionName))
    let nameTagIndex = try XCTUnwrap(SUTS_NAMES.firstIndex(of:nameTag))
    XCTAssertEqual(sectionIndex, nameTagIndex)
   }
  }
  
  
  
   //CLEAN-UP...
  try await storageRemoveHelperAsync(for: SUTS)
 }
 
 
 final func test_when_1st_DDSS_fetched_with_ALFA_sections_TV_with_DDS_has_proper_state() async throws {
  
  
   //ARRANGE...
  let SUTS_COUNT = 6
  let PERSISTED = true // WITH PERSISTANCE!
  let modelMainContext = await model.mainContext // GET ASYNC MAIN MODEL CONTEXT!
  let SUTS = try await createAllSnippets(persisted: PERSISTED)
  let SECTIONS_COUNT = 6
  let SUTS_NAMES = ["Audio", "Base", "Mixed", "Photo", "Text", "Video"]
  
  //let WEAK_SUTS = WeakContainer(sequence: SUTS)
  
  
  await modelMainContext.perform { zip(SUTS, SUTS_NAMES).forEach { pair in pair.0.nameTag = pair.1 } }
  
  let sortDescriptors = [NSSortDescriptor(key: #keyPath(NMBaseSnippet.nameTag), ascending: true)]
  
  let fetcher = NMSnapshotFetchController<NMBaseSnippet>(context: modelMainContext,
                                                         sortDescriptors: sortDescriptors,
                                                         sectionNameKeyPath: #keyPath(NMBaseSnippet.sectionAlphaIndex))
  
  //ASSERT FETCHER IS NOT LEAKED!
  addTeardownBlock { [weak fetcher] in XCTAssertNil(fetcher) }
  
 
  //ACTION...
  let SUTS_TVC = await NMSnippetsTestableTableViewController(context: modelMainContext, fetcher: fetcher)
  { @MainActor [ unowned modelMainContext ]( tv, snapshot ) -> Bool in
   
    //ASSERT...
   XCTAssertTrue(snapshot.numberOfItems == SUTS_COUNT)
   XCTAssertTrue(snapshot.numberOfSections == SECTIONS_COUNT)
   
   let TV_DDS = tv.dataSource as? NMSnippetsTestableTableViewDiffableDataSource
   
   let dds = try XCTUnwrap(TV_DDS, "Testable TV must have diffable data source!")
   
   let tv_snapshot = dds.snapshot()
   
   XCTAssertEqual(tv_snapshot, snapshot, "SUTS TV snapshot must be the the same as this one!")
   
   let TV_NS = dds.numberOfSections(in: tv)
   
   XCTAssertEqual(TV_NS, SECTIONS_COUNT, "Testable TV must \(SECTIONS_COUNT) sections in this test!")
   
   
   try await modelMainContext.perform { 
    for SUT in SUTS {
     
     let nameTag = try XCTUnwrap(SUT.nameTag)
     let sectionTitle = String(nameTag.prefix(1))
     let sectionName = try XCTUnwrap(snapshot.sectionIdentifier(containingItem: SUT.objectID))
     
     //print (SUT.sectionAlphaIndex)

     XCTAssertEqual(sectionName, sectionTitle)
     XCTAssertEqual(snapshot.numberOfItems(inSection: sectionName), 1)
     let SUT_ID = try XCTUnwrap(snapshot.itemIdentifiers(inSection: sectionName).first)
     XCTAssertEqual(SUT_ID, SUT.objectID)
     let sectionIndex =  try XCTUnwrap(snapshot.indexOfSection(sectionName))
     let nameTagIndex = try XCTUnwrap(SUTS_NAMES.firstIndex(of:nameTag))
     XCTAssertEqual(sectionIndex, nameTagIndex)

     let tv_section_title = dds.tableView(tv, titleForHeaderInSection: sectionIndex)
     XCTAssertEqual(tv_section_title, sectionTitle)

     let cellIndexPath = IndexPath(row: 0, section: sectionIndex)


     guard let cell = tv.cellForRow(at: cellIndexPath) as? NMSnippetsTestableTableViewCell else { return }
     let cellNameTag = try XCTUnwrap(cell.nameTagLabelText)

     XCTAssertEqual(nameTag, cellNameTag)

    }
   }
  
   return true
  }
  
  //ASSERT SUTS TVC & MAIN WINDOW ARE NOT LEAKED!
  addTeardownBlock { [weak SUTS_TVC, unowned self, weak window = await self.window ] in
   
   await releaseRootViewController()
   try await Task.sleep(milliseconds: 1)
   XCTAssertNil(window)
   XCTAssertNil(SUTS_TVC)
   
  }
  
   //PLACE TVC INTO UI!!!
  await makeRootViewController(SUTS_TVC)
  
   // WAIT FOR RESULT SNAPSHOTS...
  try await SUTS_TVC.waitForSnapshots()
  
   //CLEAN-UP...
  try await storageRemoveHelperAsync(for: SUTS)
  
 }
 
 final func test_when_context_did_change_with_alfa_sections () async throws {
  
   //ARRANGE...
  let SUTS_COUNT = 6
  let PERSISTED = true // WITH PERSISTANCE!
  let modelMainContext = await model.mainContext // GET ASYNC MAIN MODEL CONTEXT!
  let SUTS = try await createAllSnippets(persisted: PERSISTED)
  let SECTIONS_COUNT = 6
  let SUTS_NAMES = ["Audio", "Base", "Mixed", "Photo", "Text", "Video"]
  
  await modelMainContext.perform { zip(SUTS, SUTS_NAMES).forEach { pair in pair.0.nameTag = pair.1 } }
  
  let sortDescriptors = [NSSortDescriptor(key: #keyPath(NMBaseSnippet.nameTag), ascending: true)]
  
  let fetcher = NMSnapshotFetchController<NMBaseSnippet>(context: modelMainContext,
                                                         sortDescriptors: sortDescriptors,
                                                         sectionNameKeyPath: #keyPath(NMBaseSnippet.sectionAlphaIndex))
 
  
   //ACTION...
  
  var count = 0
  
  let SUTS_TVC = await NMSnippetsTestableTableViewController(context: modelMainContext, fetcher: fetcher)
  { @MainActor ( tv, snapshot ) -> Bool in
   defer { count += 1 }
   
   let TV_DDS = tv.dataSource as? NMSnippetsTestableTableViewDiffableDataSource
   
   let dds = try XCTUnwrap(TV_DDS, "Testable TV must have diffable data source!")
   
   return try await modelMainContext.perform {
    switch count {
     case 0:
      XCTAssertTrue(snapshot.numberOfItems == SUTS_COUNT)
      
      for SUT in SUTS {
       let nameTag = try XCTUnwrap(SUT.nameTag)
       let sectionName = try XCTUnwrap(snapshot.sectionIdentifier(containingItem: SUT.objectID))
       let alphaIndex = String(nameTag.prefix(1))
       XCTAssertEqual(sectionName, alphaIndex )
       XCTAssertEqual(snapshot.numberOfItems(inSection: sectionName), 1)
       let SUT_ID = try XCTUnwrap(snapshot.itemIdentifiers(inSection: sectionName).first)
       XCTAssertEqual(SUT_ID, SUT.objectID)
       let sectionIndex =  try XCTUnwrap(snapshot.indexOfSection(sectionName))
       let nameTagIndex = try XCTUnwrap(SUTS_NAMES.firstIndex(of:nameTag))
       XCTAssertEqual(sectionIndex, nameTagIndex)
       
       if alphaIndex == "A" {
        Task.detached {
         try await Task.sleep(milliseconds: 100)
         await modelMainContext.perform { SUT.nameTag = "Video" }
         
        }
       }
      }
      
      
     case 1:
      XCTAssertEqual(snapshot.numberOfSections, SECTIONS_COUNT - 1)
      
      for SUT in SUTS {
       let nameTag = try XCTUnwrap(SUT.nameTag)
       let sectionName = try XCTUnwrap(snapshot.sectionIdentifier(containingItem: SUT.objectID))
       let alphaIndex = String(nameTag.prefix(1))
       XCTAssertEqual(sectionName, alphaIndex )
       if alphaIndex == "V" {
        XCTAssertEqual(snapshot.numberOfItems(inSection: sectionName), 2)
       } else {
        XCTAssertEqual(snapshot.numberOfItems(inSection: sectionName), 1)
        
       }
       
       Task.detached {
        try await Task.sleep(milliseconds: 100)
        await modelMainContext.perform { SUTS.forEach{ $0.nameTag = "A" } }
  
       }
       
      }
      
      case 2:
       XCTAssertEqual(snapshot.numberOfSections, 1)
       let sectionName = try XCTUnwrap(snapshot.sectionIdentifiers.first)
       XCTAssertEqual(sectionName, "A")
       XCTAssertEqual(snapshot.numberOfItems(inSection: sectionName), SUTS_COUNT)
       let cells = (0..<SUTS_COUNT)
                    .map{ IndexPath(row: $0, section: 0) }
                    .compactMap{ tv.cellForRow(at: $0) as? NMSnippetsTestableTableViewCell }
       
       XCTAssertLessThanOrEqual(cells.count, SUTS_COUNT, "The number of visible cells must less or equal \(SUTS_COUNT)")
       XCTAssertTrue(cells.allSatisfy{ $0.nameTagLabelText == "A" })
      
       let tv_section_title = dds.tableView(tv, titleForHeaderInSection: 0)
       XCTAssertEqual(tv_section_title, "A")
       
       
     default: break
    }
    
    return count == 2
   }
  }
  
  
  
   //PLACE TVC INTO UI!!!
  await makeRootViewController(SUTS_TVC)
  
   // WAIT FOR RESULT SNAPSHOTS...
  try await SUTS_TVC.waitForSnapshots()
 
   //CLEAN-UP...
  try await storageRemoveHelperAsync(for: SUTS)
  
  
 }//final func test_when_context_did_change_with_alfa_sections...
 
 final func test_when_fetched_the_snapshot_generated_properly_once_with_PRIORITY_sections () async throws {
  
   //ARRANGE...
  let SUTS_COUNT = 6
  let PERSISTED = true // WITH PERSISTANCE!
  let modelMainContext = await model.mainContext // GET ASYNC MAIN MODEL CONTEXT!
  let SUTS = try await createAllSnippets(persisted: PERSISTED)
  let SECTIONS_COUNT = 6
  let SUTS_PRIORITIES: [NMBaseSnippet.SnippetPriority] = [.hottest, .hot, .high, .normal, .medium, .low]

  
  await modelMainContext.perform {
   zip(SUTS, SUTS_PRIORITIES).forEach { pair in
    pair.0.nameTag = pair.1.rawValue
    pair.0.priority = pair.1
   }
  }
  
  let sortDescriptors = [NSSortDescriptor(key: #keyPath(NMBaseSnippet.nameTag), ascending: true)]
  
  let fetcher = NMSnapshotFetchController<NMBaseSnippet>(context: modelMainContext,
                                                         sortDescriptors: sortDescriptors,
                                                         sectionNameKeyPath: NMBaseSnippet.priorityKey)
  
  
  
   //ACTION...
  
  let snapshot = try await fetcher.first!
  
  
   //ASSERT...
  
  XCTAssertTrue(snapshot.numberOfItems == SUTS_COUNT)
  XCTAssertTrue(snapshot.numberOfSections == SECTIONS_COUNT)
  
  try await modelMainContext.perform {
   for SUT in SUTS {
    let nameTag = try XCTUnwrap(SUT.nameTag)
    let sectionName = try XCTUnwrap(snapshot.sectionIdentifier(containingItem: SUT.objectID))
    XCTAssertEqual(sectionName, nameTag)
    XCTAssertEqual(snapshot.numberOfItems(inSection: sectionName), 1)
    let SUT_ID = try XCTUnwrap(snapshot.itemIdentifiers(inSection: sectionName).first)
    XCTAssertEqual(SUT_ID, SUT.objectID)
    
    
    let sectionIndex =  try XCTUnwrap(snapshot.indexOfSection(sectionName))
    //print (sectionName, sectionIndex)
    let nameTagIndex = try XCTUnwrap(SUTS_PRIORITIES.firstIndex(of: SUT.priority))
    XCTAssertEqual(sectionIndex, nameTagIndex)
   }
  }
  
  
  
   //CLEAN-UP...
  try await storageRemoveHelperAsync(for: SUTS)
 }
 
 final func test_when_fetched_the_snapshot_generated_properly_once_with_TYPES_sections () async throws {
  
   //ARRANGE...
  let SUTS_COUNT = 6
  let PERSISTED = true // WITH PERSISTANCE!
  let modelMainContext = await model.mainContext // GET ASYNC MAIN MODEL CONTEXT!
  let SUTS = try await createAllSnippets(persisted: PERSISTED)
  let SECTIONS_COUNT = 6
  
  let sortDescriptors = [NSSortDescriptor(key: #keyPath(NMBaseSnippet.sectionTypeIndex), ascending: true)]
  
  let fetcher = NMSnapshotFetchController<NMBaseSnippet>(context: modelMainContext,
                                                         sortDescriptors: sortDescriptors,
                                                         sectionNameKeyPath: #keyPath(NMBaseSnippet.sectionTypeIndex))
  
  
  
   //ACTION...
  
  let snapshot = try await fetcher.first!
  
  
   //ASSERT...
  
  XCTAssertTrue(snapshot.numberOfItems == SUTS_COUNT)
  XCTAssertTrue(snapshot.numberOfSections == SECTIONS_COUNT)
  
  try await modelMainContext.perform {
   for SUT in SUTS {
    let typeTitle = try XCTUnwrap(SUT.sectionTypeIndex)
    let sectionName = try XCTUnwrap(snapshot.sectionIdentifier(containingItem: SUT.objectID))
    XCTAssertEqual(sectionName, typeTitle)
    XCTAssertEqual(snapshot.numberOfItems(inSection: sectionName), 1)
    
    let SUT_ID = try XCTUnwrap(snapshot.itemIdentifiers(inSection: sectionName).first)
    XCTAssertEqual(SUT_ID, SUT.objectID)
    
    
    let sectionIndex =  try XCTUnwrap(snapshot.indexOfSection(sectionName))
    let typeIndex = Int(SUT.type.rawValue)
    XCTAssertEqual(sectionIndex, typeIndex)
    
    let titlePrefix = try XCTUnwrap(Int(typeTitle.prefix(1)))
    XCTAssertEqual(sectionIndex, titlePrefix)
   }
  }
  
  
  
   //CLEAN-UP...
  try await storageRemoveHelperAsync(for: SUTS)
 }
 
 
 final func test_when_context_did_change_with_DATE_GROUP_sections () async throws {
 
  let SUTS_COUNT = 6
  let PERSISTED = true // WITH PERSISTANCE!
  let modelMainContext = await model.mainContext // GET ASYNC MAIN MODEL CONTEXT!
  let SUTS = try await createAllSnippets(persisted: PERSISTED)
  let SECTIONS_COUNT = 1
  let SUTS_NAMES = ["A", "B", "C", "D", "E", "F"]
  
  let NOW = Date()
  let CC = Calendar.current
  let EOY = try XCTUnwrap(CC.dateInterval(of: .year, for: NOW)?.end)
  let DAYS_COUNT = try XCTUnwrap(CC.dateComponents([.day], from: NOW, to: EOY).day) + 1
  
  
  await modelMainContext.perform {
   zip(SUTS, SUTS_NAMES).forEach { pair in pair.0.nameTag = pair.1 }
  }
  
  let sortDescriptors = [NSSortDescriptor(key: NMBaseSnippet.sectionDateIndexKey, ascending: true)]
  let SKP = NMBaseSnippet.sectionDateIndexKey
  let fetcher = NMDateGroupTestableSnapshotFetchController<NMBaseSnippet>(context: modelMainContext,
                                                                          sortDescriptors: sortDescriptors,
                                                                          sectionNameKeyPath: SKP)
  
  //ACTION...
  
  var SNAPSHOT_COUNT = 0
  
  let randomSnapshot = Int.random(in: 1..<DAYS_COUNT)

  for try await snapshot in fetcher  {
   
   XCTAssertEqual(snapshot.numberOfItems, SUTS_COUNT)
   XCTAssertEqual(snapshot.numberOfSections, SECTIONS_COUNT)
   
   let sectionIDs = Set(snapshot.sectionIdentifiers)
   
   XCTAssertEqual(sectionIDs.count, SECTIONS_COUNT)
   
   let sectionID = try XCTUnwrap(sectionIDs.first)
   let dateGroup = try XCTUnwrap(NMBaseSnippet.DateGroup(rawValue: sectionID))
   
   if SNAPSHOT_COUNT == randomSnapshot {
    await modelMainContext.perform { SUTS.randomElement()?.nameTag = "X" }
   }
   
   if SNAPSHOT_COUNT > randomSnapshot  {
    await modelMainContext.perform {
     let SUTS = snapshot.itemIdentifiers.compactMap{ modelMainContext.object(with: $0) as? NMBaseSnippet}
     XCTAssertTrue(SUTS.contains{ $0.nameTag == "X" })
    }
   }
   
   
   if dateGroup == .lastYear {
    XCTAssertEqual(SNAPSHOT_COUNT, DAYS_COUNT + 1)
    break
   }
   
   SNAPSHOT_COUNT += 1

  }
  
  
   //CLEAN-UP...
  try await storageRemoveHelperAsync(for: SUTS)
  
  
 }//final func test_when_context_did_change_with_alfa_sections...
 
 /* MARK: Thest that when all 6 snippet types date group fields are periodically modified on day by day basis the new diffable data source snapshots are emitted properly by async stream fetcher object and thereafter when new objects inserted and deleted. */
 
 final func test_when_context_did_change_with_DATE_GROUP_sections_INSERTIONS_and_DELETIONS () async throws {

  let SUTS_COUNT = 6
  let PERSISTED = true // WITH PERSISTANCE!
  let modelMainContext = await model.mainContext // GET ASYNC MAIN MODEL CONTEXT!
  let SUTS = try await createAllSnippets(persisted: PERSISTED)
  let SECTIONS_COUNT = 1
  let SUTS_NAMES = ["A", "B", "C", "D", "E", "F"]

  let NOW = Date()
  let CC = Calendar.current
  let EOY = try XCTUnwrap(CC.dateInterval(of: .year, for: NOW)?.end)
  let DAYS_COUNT = try XCTUnwrap(CC.dateComponents([.day], from: NOW, to: EOY).day) + 1

  let randomEntity = [NMBaseSnippet.self,
                      NMTextSnippet.self,
                      NMPhotoSnippet.self,
                      NMVideoSnippet.self,
                      NMAudioSnippet.self,
                      NMMixedSnippet.self].randomElement()!



  await modelMainContext.perform {
   zip(SUTS, SUTS_NAMES).forEach { pair in pair.0.nameTag = pair.1 }
  }

  let sortDescriptors = [NSSortDescriptor(key: NMBaseSnippet.sectionDateIndexKey, ascending: true)]

  let SKP = NMBaseSnippet.sectionDateIndexKey

  let fetcher = NMDateGroupTestableSnapshotFetchController<NMBaseSnippet>(context: modelMainContext,
                                                                          sortDescriptors: sortDescriptors,
                                                                          sectionNameKeyPath: SKP)

   //ACTION...

  var SNAPSHOT_COUNT = 0

  let insertSnapshot = Int.random(in: 1...DAYS_COUNT / 2)
  let deleteSnapshot = Int.random(in: DAYS_COUNT / 2 + 2..<DAYS_COUNT + 2)

  for try await snapshot in fetcher  {

   let sectionIDs = Set(snapshot.sectionIdentifiers)

   switch SNAPSHOT_COUNT {
    case 0..<insertSnapshot, (deleteSnapshot + 1)... :
     XCTAssertEqual(sectionIDs.count, SECTIONS_COUNT)
     XCTAssertEqual(snapshot.numberOfItems, SUTS_COUNT)
     XCTAssertEqual(snapshot.numberOfSections, SECTIONS_COUNT)

    case insertSnapshot:
     try await model.create(persist: true, entityType: randomEntity) {
      ($0 as? NMBaseSnippet)?.nameTag = "INS"
      ($0 as? NMBaseSnippet)?.date = Date() + .oneDay * TimeInterval(insertSnapshot)
     }
     
     
    case insertSnapshot + 1:
     //print (SNAPSHOT_COUNT, snapshot.sectionIdentifiers)
     XCTAssertEqual(snapshot.numberOfItems, SUTS_COUNT + 1)
     XCTAssertEqual(snapshot.numberOfSections, SECTIONS_COUNT + 1)
     
     
    case insertSnapshot + 2:
     await modelMainContext.perform {
      let SUTS = snapshot.itemIdentifiers.compactMap{modelMainContext.object(with: $0) as? NMBaseSnippet}
      XCTAssertTrue(SUTS.contains{ $0.nameTag == "INS" })
     }
     
    case deleteSnapshot:
     try await modelMainContext.perform {
      let SUT_INS = try XCTUnwrap(snapshot.itemIdentifiers
                                          .compactMap{modelMainContext.object(with: $0) as? NMBaseSnippet}
                                          .first{$0.nameTag == "INS"})
      modelMainContext.delete(SUT_INS)
     }
     
   
  
    default: break
   }




   let sectionID = try XCTUnwrap(sectionIDs.first)
   let dateGroup = try XCTUnwrap(NMBaseSnippet.DateGroup(rawValue: sectionID))

   
   if dateGroup == .lastYear {
    XCTAssertEqual(SNAPSHOT_COUNT, DAYS_COUNT + 2)
    break
   }

   SNAPSHOT_COUNT += 1

  }


   //CLEAN-UP...
  try await storageRemoveHelperAsync(for: SUTS)


 }//final func test_when_context_did_change_with_alfa_sections...
 
 
 final func test_when_SORT_ORDER_TOGGLED_with_alfa_sections () async throws {
  
   //ARRANGE...
 
  let SUTS_COUNT = 6
  let PERSISTED = true // WITH PERSISTANCE!
  let modelMainContext = await model.mainContext // GET ASYNC MAIN MODEL CONTEXT!
  let SUTS = try await createAllSnippets(persisted: PERSISTED) {
   
   switch $0 {
    case let SUT as NMPhotoSnippet:
     
     let photo = NMPhoto(context: modelMainContext)
     photo.tag = String(describing: NMPhoto.self)
     SUT.addToPhotos(photo)
     
    case let SUT as NMTextSnippet:
     let text = NMText(context: modelMainContext)
     text.tag = String(describing: NMText.self)
     SUT.addToTexts(text)
     
    case let SUT as NMAudioSnippet:
     let audio = NMAudio(context: modelMainContext)
     audio.tag = String(describing: NMAudio.self)
     SUT.addToAudios(audio)
     
    case let SUT as NMVideoSnippet:
     let video = NMVideo(context: modelMainContext)
     video.tag = String(describing: NMVideo.self)
     SUT.addToVideos(video)
    
    case let SUT as NMMixedSnippet:
     let photo = NMPhoto(context: modelMainContext)
     photo.tag = "Mixed"
     SUT.addToPhotos(photo)
     
     let text = NMText(context: modelMainContext)
     text.tag = "Mixed"
     SUT.addToTexts(text)
     
     let audio = NMAudio(context: modelMainContext)
     audio.tag = "Mixed"
     SUT.addToAudios(audio)
     
     let video = NMVideo(context: modelMainContext)
     video.tag = "Mixed"
     SUT.addToVideos(video)
    
     
    default: break
   }
  
   
  }
//  
//  let ps = SUTS.compactMap{$0 as? NMAudioSnippet }.first!
//  let ph = try await model.create(in: ps, contained: NMAudio.self)
//  
  let SUTS_TV_ROW_HEIGHT: CGFloat = 200
  
  

  let SUTS_NAMES = ["Aaaa", "Abbb", "Accc", "Addd", "Aeee", "Afff"]
  
  await modelMainContext.perform { zip(SUTS, SUTS_NAMES).forEach { pair in pair.0.nameTag = pair.1 } }
  

  
  let sortDescriptors = [NSSortDescriptor(key: #keyPath(NMBaseSnippet.nameTag), ascending: true)]
  
  let fetcher = NMSnapshotFetchController<NMBaseSnippet>(context: modelMainContext,
                                                         sortDescriptors: sortDescriptors,
                                                         sectionNameKeyPath: #keyPath(NMBaseSnippet.sectionAlphaIndex))
  
  
   //ACTION...
  
  var count = 0
  
  let SUTS_TVC = await NMSnippetsTestableTableViewController(context: modelMainContext,
                                                             fetcher: fetcher,
                                                             tableViewRowHeight: SUTS_TV_ROW_HEIGHT)
  { @MainActor ( tv, snapshot ) -> Bool in
   
   defer { count += 1 }
   
   //let TV_DDS = tv.dataSource as? NMSnippetsTestableTableViewDiffableDataSource
   
   //let dds = try XCTUnwrap(TV_DDS, "Testable TV must have diffable data source!")
   
   return try await modelMainContext.perform {
    
    
    let snippetsTVCells = ((0..<SUTS_COUNT)
     .compactMap{tv.cellForRow(at: IndexPath(row: $0, section: 0)) as? NMSnippetsTestableTableViewCell})
    
    let visibleCount = snippetsTVCells.count
    
    snippetsTVCells.map(\.frame).forEach{ print($0) }
    
    XCTAssertLessThanOrEqual(snippetsTVCells.count, SUTS_COUNT)
    
    let snapshotSnippets = snapshot.itemIdentifiers.compactMap{ modelMainContext.object(with: $0) as? NMBaseSnippet}
    
    let snapshotItemsTags = snapshotSnippets.compactMap(\.nameTag)
    let cellNameTags = snippetsTVCells.compactMap(\.nameTagLabelText)
    
    let orderedAbouts = Array(1...SUTS_COUNT).map{ String($0)}
    
    let snapshotAbouts = snapshotSnippets.compactMap(\.about)
    
    let cellsAbouts = snippetsTVCells.compactMap(\.aboutLabelText)
    
    switch count {
      
     case 0: //MARK: Initial DDSS!
      
      XCTAssertTrue(snapshot.numberOfItems == SUTS_COUNT)
      XCTAssertTrue(snapshot.numberOfSections == 1)
      
      XCTAssertEqual(snapshotItemsTags, SUTS_NAMES)
      XCTAssertEqual(cellNameTags, Array(SUTS_NAMES[0..<visibleCount]))
                        
      // MARK: NEXT TASK (1)...
      Task.detached {
       try await Task.sleep(milliseconds: 100)
       await fetcher.toggleSortOrder()
      }
     
      // MARK: (1) Test next DDSS after Toggling sort ordering.
     case 1:
      
      XCTAssertTrue(snapshot.numberOfItems == SUTS_COUNT)
      XCTAssertTrue(snapshot.numberOfSections == 1)
      
      XCTAssertEqual(snapshotItemsTags,
                     SUTS_NAMES.reversed(),
                     "The DDSS SUTS <.nameTag> fields must be equal to the reversed ordered ones")
      
       //Assert using only visible cells in the current testable device!
      XCTAssertEqual(cellNameTags,
                     Array(SUTS_NAMES.reversed()[0..<visibleCount]),
                     "The visible cells <nameTag> labels must be equal to the subset of the reversed ordered ones")
     
      
      // MARK: NEXT TASK (2)...
      Task.detached {
       try await Task.sleep(milliseconds: 100)
       await modelMainContext.perform {
     
        while true {
         let shuffled = orderedAbouts.shuffled()
         if ( shuffled != orderedAbouts ) {
          zip(SUTS, shuffled).forEach{ $0.0.nameTag = "A"; $0.0.about = $0.1 }
          break
         }
        }
       }
      }
     
     // MARK: (2) Test next DDSS after assigning random values to SUTS.about fields.
      
     case 2:
      
      XCTAssertTrue(snapshot.numberOfItems == SUTS_COUNT)
      XCTAssertTrue(snapshot.numberOfSections == 1)
      
      XCTAssertNotEqual(snapshotAbouts,
                        orderedAbouts,
                        "The DDSS SUTS <.about> fields are random and must not be equal to ordered ones")
      
      //Assert using only visible cells in the current testable device!
      XCTAssertNotEqual(cellsAbouts,
                        Array(orderedAbouts[0..<visibleCount]),
                        "The visible cells <about> labels are random and must not be equal to ordered ones subset")
     
      // MARK: NEXT TASK (3)...
      Task.detached {
       try await Task.sleep(milliseconds: 100)
       await fetcher.apply(sortOrder: .descending(keyPath: \NMBaseSnippet.about))
       
      }
      
     
     // MARK: (3) Test next DDSS after applying descending ordering to SUTS.about fields.
      
     case 3:
      
      XCTAssertTrue(snapshot.numberOfItems == SUTS_COUNT)
      XCTAssertTrue(snapshot.numberOfSections == 1)
      
      
      XCTAssertEqual(snapshotAbouts,
                     orderedAbouts.reversed(),
                     "The DDSS SUTS <.about> fields must be equal to the resersed ordered ones")
      
       //Assert using only visible cells in the current testable device!
      XCTAssertEqual(cellsAbouts,
                     Array(orderedAbouts.reversed()[0..<visibleCount]),
                     "The visible cells <about> labels must be equal to the subset of the reversed ordered ones")
      
      // MARK: NEXT TASK (4)...
      Task.detached {
       try await Task.sleep(milliseconds: 100)
       await fetcher.apply(searchString: "1 2 3", keyPaths: #keyPath(NMBaseSnippet.about))
       
      }
      
     case 4:
      
      // MARK: (4) Test next DDSS after applying filtering predicate to <about> field.
      
      XCTAssertTrue(snapshot.numberOfItems == 3)
      XCTAssertTrue(snapshot.numberOfSections == 1)
      
      let filteredAbouts = Array(["1", "2", "3"].reversed())
      
      XCTAssertEqual(snapshotAbouts, filteredAbouts,
                     "The DDSS SUTS <.about> fields must be equal to the filtred reversed ordered ones")
      
       //Assert using only visible cells in the current testable device!
      XCTAssertEqual(cellsAbouts, Array(filteredAbouts[0..<visibleCount]),
                     "The visible cells <about> labels must be equal to the subset of the reversed ordered ones")
     
      
       // MARK: NEXT TASK (5)...
      Task.detached {
       try await Task.sleep(milliseconds: 100)
       await fetcher.apply(searchString: "1 2 a",
                           keyPaths: #keyPath(NMBaseSnippet.about), #keyPath(NMBaseSnippet.nameTag))
       
      }
      
     case 5:
      
       // MARK: (5) Test next DDSS after applying new filtering predicate to <.about> & <.nameTag> field.
      
      XCTAssertTrue(snapshot.numberOfItems == SUTS_COUNT)
      XCTAssertTrue(snapshot.numberOfSections == 1)
      
      let filteredAbouts = Array(orderedAbouts.reversed())
      
      XCTAssertEqual(snapshotAbouts, filteredAbouts,
                     "The DDSS SUTS <.about> fields must be equal to the filtred reversed ordered ones")
      
       //Assert using only visible cells in the current testable device!
      XCTAssertEqual(cellsAbouts, Array(filteredAbouts[0..<visibleCount]),
                     "The visible cells <about> labels must be equal to the subset of the reversed ordered ones")
      
       // MARK: NEXT TASK (6)...
      Task.detached {
       try await Task.sleep(milliseconds: 100)
       await fetcher.apply(overallSearchString: "1 2 Å")
       
      }
     
     case 6:
      
       // MARK: (6) Test next DDSS after applying new overall filtering predicate to normalized search fields!
      
      XCTAssertTrue(snapshot.numberOfItems == SUTS_COUNT)
      XCTAssertTrue(snapshot.numberOfSections == 1)
      
      let filteredAbouts = Array(orderedAbouts.reversed())
      
      XCTAssertEqual(snapshotAbouts, filteredAbouts,
                     "The DDSS SUTS <.about> fields must be equal to the filtred reversed ordered ones")
      
       //Assert using only visible cells in the current testable device!
      XCTAssertEqual(cellsAbouts, Array(filteredAbouts[0..<visibleCount]),
                     "The visible cells <about> labels must be equal to the subset of the reversed ordered ones")
      
      
       // MARK: NEXT TASK (7)...
      
      Task.detached {
       try await Task.sleep(milliseconds: 100)
       await fetcher.apply(overallSearchString: "phòt vïdè tèx åùd Mix")
     
      }
      
     case 7:
      
       // MARK: (7) Test next DDSS after applying new overall filtering predicate to normalized children search fields!
      
      XCTAssertEqual(snapshot.numberOfItems, 5)
      XCTAssertEqual(snapshot.numberOfSections, 1)
      
      for SUT in snapshotSnippets{
       switch SUT {
        case let SUT as NMPhotoSnippet:
         let PHOTO = try XCTUnwrap(SUT.photos?.allObjects.first as? NMPhoto)
         let CSS = try XCTUnwrap(SUT.value(forKey: NMPhotoSnippet.normalizedSearchChildrenKey) as? String)
         XCTAssertEqual(PHOTO.tag, String(describing: type(of: PHOTO)))
         XCTAssertEqual(PHOTO.photoSnippet, SUT)
         XCTAssertEqual(CSS, PHOTO.tag?.normalizedForSearch)
         
          // MARK: NEXT TASK (8)...
         
         Task.detached {
          try await Task.sleep(milliseconds: 100)
           await modelMainContext.perform {
            modelMainContext.delete(PHOTO)
           }
          
         }
         
        case let SUT as NMTextSnippet:
         let TEXT = try XCTUnwrap(SUT.texts?.allObjects.first as? NMText)
         let CSS = try XCTUnwrap(SUT.value(forKey: NMTextSnippet.normalizedSearchChildrenKey) as? String)
         XCTAssertEqual(TEXT.tag, String(describing: type(of: TEXT)))
         XCTAssertEqual(TEXT.textSnippet, SUT)
         XCTAssertEqual(CSS, TEXT.tag?.normalizedForSearch)
         
        case let SUT as NMAudioSnippet:
         let AUDIO = try XCTUnwrap(SUT.audios?.allObjects.first as? NMAudio)
         let CSS = try XCTUnwrap(SUT.value(forKey: NMAudioSnippet.normalizedSearchChildrenKey) as? String)
         XCTAssertEqual(AUDIO.tag, String(describing: type(of: AUDIO)))
         XCTAssertEqual(AUDIO.audioSnippet, SUT)
         XCTAssertEqual(CSS, AUDIO.tag?.normalizedForSearch)
         
        case let SUT as NMVideoSnippet:
         let VIDEO = try XCTUnwrap(SUT.videos?.allObjects.first as? NMVideo)
         let CSS = try XCTUnwrap(SUT.value(forKey: NMVideoSnippet.normalizedSearchChildrenKey) as? String)
         XCTAssertEqual(VIDEO.tag, String(describing: type(of: VIDEO)))
         XCTAssertEqual(VIDEO.videoSnippet, SUT)
         XCTAssertEqual(CSS, VIDEO.tag?.normalizedForSearch)
         
        case let SUT as NMMixedSnippet:
         let VIDEO = try XCTUnwrap(SUT.videos?.allObjects.first as? NMVideo)
         XCTAssertEqual(VIDEO.tag, "Mixed")
         XCTAssertNil(VIDEO.videoSnippet)
         XCTAssertEqual(VIDEO.mixedSnippet, SUT)
         
         let AUDIO = try XCTUnwrap(SUT.audios?.allObjects.first as? NMAudio)
         XCTAssertEqual(AUDIO.tag, "Mixed")
         XCTAssertNil(AUDIO.audioSnippet)
         XCTAssertEqual(AUDIO.mixedSnippet, SUT)
         
         let TEXT =  try XCTUnwrap(SUT.texts?.allObjects.first  as? NMText)
         XCTAssertEqual(TEXT.tag, "Mixed")
         XCTAssertNil(TEXT.textSnippet)
         XCTAssertEqual(TEXT.mixedSnippet, SUT)
         
         let PHOTO = try XCTUnwrap(SUT.photos?.allObjects.first as? NMPhoto)
         XCTAssertEqual(PHOTO.tag, "Mixed")
         XCTAssertNil(PHOTO.photoSnippet)
         XCTAssertEqual(PHOTO.mixedSnippet, SUT)
         
         let CSS = try XCTUnwrap(SUT.value(forKey: NMMixedSnippet.normalizedSearchChildrenKey) as? String)
         
         XCTAssertEqual(CSS, "Mixed".normalizedForSearch)
         
        default: break
       }
      }
     
     case 8:
      XCTAssertEqual(snapshot.numberOfItems, 4)
      XCTAssertEqual(snapshot.numberOfSections, 1)
      
     default: break
      
      
      
      
    }
    
    return count == 8
   }
  }
  
  
  
   //PLACE TVC INTO UI!!!
  await makeRootViewController(SUTS_TVC)
  
   // WAIT FOR RESULT SNAPSHOTS...
  try await SUTS_TVC.waitForSnapshots()
  
   //CLEAN-UP...
  try await storageRemoveHelperAsync(for: SUTS)
  
  
 }//final func test_when_context_did_change_with_alfa_sections...
 
 
}//final class NMBaseSnippetsFetchingAsyncTests: NMBaseSnippetsAsyncTests

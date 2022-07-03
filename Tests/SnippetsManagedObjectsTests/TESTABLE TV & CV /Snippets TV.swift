
import NewsmanCoreDataModel
import Combine
import CoreData
#if !os(macOS)
import UIKit
#else
import AppKit
#endif

@available(iOS 14.0, *)
struct NMSnippetsTestableCellConfiguration: UIContentConfiguration, NMBaseSnippetUICellConfiguration {
 
 init?(with objectID: NSManagedObjectID, in context: NSManagedObjectContext){
  guard let snippet = context.registeredObject(for: objectID) as? NMBaseSnippet else { return nil }
  self.init(with: snippet)
 }
 
 init (with snippet: NMBaseSnippet){
  date = snippet.date
  nameTag = snippet.nameTag
  about = snippet.about
  isContentCopyable = snippet.isContentCopyable
  isContentEditable = snippet.isContentEditable
  isContentPublishable = snippet.isContentPublishable
  isContentSharable = snippet.isContentSharable
  isDeletable = snippet.isDeletable
  isDraggable = snippet.isDraggable
  isDragAnimating = snippet.isDragAnimating
  isHiddenFromSection = snippet.isHiddenFromSection
  isHideableFromSection = snippet.isHideableFromSection
  isMergeable = snippet.isMergeable
  isSelected = snippet.isSelected
  isShowingSnippetDetailedCell = snippet.isShowingSnippetDetailedCell
  isTrashable = snippet.isTrashable
  lastAccessedTimeStamp = snippet.lastAccessedTimeStamp
  lastModifiedTimeStamp = snippet.lastModifiedTimeStamp
  publishedTimeStamp = snippet.publishedTimeStamp
  location = snippet.location
  priority = snippet.priority
  status = snippet.status
  type = snippet.type
  connectedWithTopNews = snippet.connectedWithTopNews?.count
 }
 
 let date: Date?
 var nameTag: String?
 var location: String?
 var about: String?
 var priority: NMBaseSnippet.SnippetPriority?
 var status: NMBaseSnippet.SnippetStatus?
 var type: NMBaseSnippet.SnippetType?
 
 var isContentCopyable: Bool?
 var isContentEditable: Bool?
 var isContentPublishable: Bool?
 var isContentSharable: Bool?
 var isDeletable: Bool?
 var isDragAnimating: Bool?
 var isDraggable: Bool?
 var isHiddenFromSection: Bool?
 var isHideableFromSection: Bool?
 var isMergeable: Bool?
 var isSelected: Bool?
 var isShowingSnippetDetailedCell: Bool?
 var isTrashable: Bool?
 var lastAccessedTimeStamp: Date?
 var lastModifiedTimeStamp: Date?
 var publishedTimeStamp: Date?
 var connectedWithTopNews: Int?


 func makeContentView() -> UIView & UIContentView { NMSnippetsTestableCellContentView(configuration: self)}
 
 func updated(for state: UIConfigurationState) -> NMSnippetsTestableCellConfiguration { self }
 
 
}

@available(iOS 14.0, *)
final class NMSnippetsTestableCellContentView: UIView, UIContentView{
 
 init (configuration: NMSnippetsTestableCellConfiguration){
  self.configuration = configuration
  super.init(frame: .zero)
 }
 
 required init?(coder: NSCoder) {
  fatalError("init(coder:) has not been implemented")
 }
 
 var configuration: UIContentConfiguration {
  didSet{
   updateContentView()
  }
 }
 
 var intrinsicContentViewHeight: CGFloat = .zero {
  didSet{
   invalidateIntrinsicContentSize()
  }
 }
 
 override var intrinsicContentSize: CGSize {
  guard intrinsicContentViewHeight != .zero else { return super.intrinsicContentSize }
  return .init(width: super.intrinsicContentSize.width, height: intrinsicContentViewHeight)
 }
 
 fileprivate lazy var nameTagLabel = { () -> UILabel in
  let label = UILabel()
  addSubview(label)
  label.translatesAutoresizingMaskIntoConstraints = false
  label.topAnchor.constraint(equalTo: topAnchor, constant: 0).isActive = true
  label.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 0).isActive = true
  label.trailingAnchor.constraint(equalTo: trailingAnchor, constant: 0).isActive = true
  label.bottomAnchor.constraint(equalTo: aboutLabel.topAnchor, constant: 0).isActive = true
  return label
  
 }()
 
 fileprivate lazy var aboutLabel = { () -> UILabel in
  let label = UILabel()
  addSubview(label)
  label.translatesAutoresizingMaskIntoConstraints = false
  label.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 0).isActive = true
  label.trailingAnchor.constraint(equalTo: trailingAnchor, constant: 0).isActive = true
  label.bottomAnchor.constraint(equalTo: bottomAnchor, constant: 0).isActive = true
  return label
  
 }()
 
 

 
 private func updateContentView(){
  guard let configuration = configuration as? NMSnippetsTestableCellConfiguration else { return }
  
  if nameTagLabel.text != configuration.nameTag { nameTagLabel.text = configuration.nameTag }
  if aboutLabel.text != configuration.about     { aboutLabel.text = configuration.about     }
  
 }
}

@available(iOS 14.0, *)
final class NMSnippetsTestableTableViewCell: UITableViewCell, NMBaseSnippetUIStateObservable  {
 
 var nameTagLabelText: String? { (contentView as? NMSnippetsTestableCellContentView)?.nameTagLabel.text }
 var aboutLabelText:   String? { (contentView as? NMSnippetsTestableCellContentView)?.aboutLabel.text }
 var intrinsicContentViewHeight: CGFloat = .zero {
  didSet{
   (contentView as? NMSnippetsTestableCellContentView)?.intrinsicContentViewHeight = intrinsicContentViewHeight
  }
 }
 
 weak var snippet: NMBaseSnippet?{
  didSet{
   snippet?.publisher(for: \.nameTag, options: [.new]).sink{ [ unowned self ] in
    guard var currentConfiguration = contentConfiguration as? NMSnippetsTestableCellConfiguration else { return }
    currentConfiguration.nameTag = $0
    contentConfiguration = currentConfiguration
   }.store(in: &disposeBag)
  }
 }
 
 var disposeBag = Set<AnyCancellable>()

}
 
@available(iOS 14.0, *)
final class NMSnippetsTestableTableView: UITableView{
 
 let reuseID = "NMSnippetsTestableTableViewCell"
 weak var context: NSManagedObjectContext!
 let cellHeight: CGFloat
 
 
 required init?(coder: NSCoder) {
  fatalError("init(coder:) has not been implemented")
 }
 
 init(frame: CGRect,
      style: UITableView.Style,
      using context: NSManagedObjectContext, cellHeight: CGFloat) {
  
  self.cellHeight = cellHeight
  super.init(frame: frame, style: style)
  self.context = context
  self.separatorStyle = .none
 
 }
 
}

@available(iOS 14.0, *)
final class NMSnippetsTestableTableViewDiffableDataSource: UITableViewDiffableDataSource<String, NSManagedObjectID>, UITableViewDelegate {
 override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
  snapshot().sectionIdentifiers[section]
 }
 
 
}

@available(iOS 15.0, *)
final class NMSnippetsTestableTableViewController: UIViewController {
 
 weak var context: NSManagedObjectContext!
 weak var fetcher: NMSnapshotFetchController<NMBaseSnippet>?
 let animateSnapshots: Bool
 let testHandler: NMSnapshotsTestsHandler
 let tableViewRowHeight: CGFloat
 
 override func loadView() {
  //print(#function)
  //let frame = CGRect(x: 0, y: 0, width: 100, height: 1000)
  let tableView = NMSnippetsTestableTableView(frame: .zero,
                                              style: .plain,
                                              using: context,
                                              cellHeight: tableViewRowHeight)
  self.view = tableView
  snippetsTableView = tableView
 }
 
 private weak var snippetsTableView: NMSnippetsTestableTableView! {
  didSet { snippetsTableView.delegate = datasource }
 }
 
 lazy var datasource: NMSnippetsTestableTableViewDiffableDataSource = {
  print(#function)
  let reuseID = snippetsTableView.reuseID
  
  snippetsTableView.register(NMSnippetsTestableTableViewCell.self, forCellReuseIdentifier: reuseID)
  
  let datasource = NMSnippetsTestableTableViewDiffableDataSource(tableView: snippetsTableView){tv, ip, snippetID in
   
   guard let tv = tv as? NMSnippetsTestableTableView else {
    
    fatalError("Wrong Table View Class Type!!! \(String(describing: type(of: tv)))")
   }
   
   guard let cell = tv.dequeueReusableCell(withIdentifier: tv.reuseID, for: ip) as? NMSnippetsTestableTableViewCell
   else {
    fatalError("Unexpected Cell Class Type!!!")
   }
   
   print("NEW CELL CREATED \(cell)")
   cell.contentConfiguration = NMSnippetsTestableCellConfiguration(with: snippetID, in: tv.context)
   cell.intrinsicContentViewHeight = tv.cellHeight
   
   return cell
  }
  return datasource
 }()
  

 typealias NMTestSnapshot = NSDiffableDataSourceSnapshot<String, NSManagedObjectID>
 typealias NMSnapshotsTestsHandler = (NMSnippetsTestableTableView, NMTestSnapshot) async throws -> Bool
 
 
 
 init(context: NSManagedObjectContext,
      fetcher: NMSnapshotFetchController<NMBaseSnippet>,
      animateSnapshots: Bool = false,
      tableViewRowHeight: CGFloat = .zero,
      testHandler: @escaping  NMSnapshotsTestsHandler){
  
  self.context = context
  self.fetcher = fetcher
  self.animateSnapshots = animateSnapshots
  self.testHandler = testHandler
  self.tableViewRowHeight = tableViewRowHeight
  
  super.init(nibName: nil, bundle: nil)
  

  
 }
 
 required init?(coder: NSCoder) {
  fatalError("init(coder:) has not been implemented")
 }
 
 override func viewWillLayoutSubviews() {
  print (#function)
  super.viewWillLayoutSubviews()
 }
 
 private lazy var snapshotsAwaitHandle: Task<(), Error> = {

  loadViewIfNeeded()
  let handle = Task {
   guard let fetcher = fetcher else { return }
   print("START SNAPSHOTING...")
   for try await snapshot in fetcher {
    try Task.checkCancellation()
    print("New TV Snapshot to be applied to TV...")
    await datasource.apply(snapshot, animatingDifferences: animateSnapshots)
    if try await testHandler(snippetsTableView, snapshot) { return }
   }
  }
  return handle
 }()
 
 func waitForSnapshots() async throws { try await snapshotsAwaitHandle.value }
 
 func stopSnapshoting() { snapshotsAwaitHandle.cancel() }
 
 override func viewDidLoad() {
  super.viewDidLoad()

 }
 
}


 



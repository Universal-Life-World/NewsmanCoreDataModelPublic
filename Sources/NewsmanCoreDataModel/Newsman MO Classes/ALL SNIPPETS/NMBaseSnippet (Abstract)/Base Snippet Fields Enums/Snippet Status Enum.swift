
import Foundation

@available(iOS 13.0, *)
public extension NMBaseSnippet {
 enum SnippetStatus: String, Codable, CaseIterable, NMEnumCasesStringLocalizable, NMEnumOptionalCasesManageable {
  public static var isolationQueue = DispatchQueue(label: "Snippet Status")
  
  static public var enabled = Dictionary(uniqueKeysWithValues: allCases.map{($0, true)})
  
  case new = "New"
  /* Just created (newborn container for editorial material) and will be moved immediately to Privy state after first persistance in the context */
  
  case privy = "Privy"
  /* Privy - the snippet is visible only to the newsmen owner! When the spippet is first time persisted in the context it is set to the Privy state. Such material is only saved in local Core Data Model and Private iCloud DB and is not supposed to be exposed to the Vapor Server. */
  
  case published = "Published"
  /* Published - the Snippet content was Published by the newsman owner to only preview its contents and materials in the app UI. Published snippet material is searchable and can be seen as a Public Report Preview by the all the registered newsmen of the app. */
  
  case closed = "Closed"
  /* Closed - the snippet closed for publishing but was published before for public preview for registered app users (newsmen). Closed one can be only accessed by the newsman owner and the newsman who has been granted previously full access to its material by making it Shared. */
  
  case shared = "Shared"
  /* Shared - not Closed yet but fully accessed by one newsman or a group of newsmen who are granted access by this newsman owner of the snippet. Also accessed for public preview as if it is Published. If newsman wants to make it only accessable to the private group of one newman one can set its status to the Closed state. */
  
  case archived =  "Archived"
  /* Archived - Private + removed from Vapor Server and only accessable only from Cloud private DB. */
  
  case trashed = "Trashed"
  /* Trashed - Private and marked for further entire deletion as moved into the snippets recycle bin. */
  
 }
}

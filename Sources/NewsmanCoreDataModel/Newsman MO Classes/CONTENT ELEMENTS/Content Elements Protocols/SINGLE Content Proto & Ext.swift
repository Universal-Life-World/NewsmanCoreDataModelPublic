import Foundation

public protocol NMContentElement where Self: NMBaseContent {
 
 associatedtype Snippet: NMContentElementsContainer
 associatedtype Folder: NMContentFolder
 
 var snippet: Snippet?              { get }
 var folder: Folder?                { get }
 var mixedSnippet: NMMixedSnippet?  { get }
 var mixedFolder: NMMixedFolder?    { get }
 
 
 
}

extension NMContentElement {
 
 public var container: NMBaseSnippet?       { snippet ?? mixedSnippet }
 public var nestedContainer: NMBaseContent? { folder ?? mixedFolder   }
 public var isFoldered: Bool { nestedContainer != nil }
 public var hasSnippet: Bool { container != nil }
 public var isValid: Bool { managedObjectContext != nil && isDeleted == false }
 public var isNew: Bool { isValid && hasSnippet == false && isFoldered == false }
 public func canBeMoved(to destination: Snippet) -> Bool { isValid && hasSnippet && destination != self }


}




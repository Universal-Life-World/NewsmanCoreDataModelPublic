import Foundation

@available(iOS 15.0, macOS 12.0, *)
extension NMContentElementsContainer where Self: NMMixedSnippet {
 
 public var singleContentElementsAsync: [NMBaseContent]  {
  get async throws  {
   guard let context = self.managedObjectContext else {
    throw ContextError.noContext(object: self,
                                 entity: .mixedElementsContainer,
                                 operation: .gettingSnippetElements)
   }
   
   return await context.perform { self.singleContentElements }
  } //get async throws...
 } //snippet...
 
 public var foldersAsync: [NMBaseContent]  {
  get async throws  {
   guard let context = self.managedObjectContext else {
    throw ContextError.noContext(object: self,
                                 entity: .mixedElementsContainer,
                                 operation: .gettingSnippetElements)
   }
   
   return await context.perform { self.folders }
  } //get async throws...
 } //snippet...
 
 public var foldersIDsAsync: [UUID]  {
  get async throws  {
   guard let context = self.managedObjectContext else {
    throw ContextError.noContext(object: self,
                                 entity: .mixedContentFolder,
                                 operation: .gettingSnippetElementsIDs)
   }
   
   return await context.perform { self.folders.compactMap(\.id) }
  } //get async throws...
 } //snippet...
 
 public var folderedContentElementsAsync: [NMBaseContent]  {
  get async throws  {
   guard let context = self.managedObjectContext else {
    throw ContextError.noContext(object: self,
                                 entity: .mixedElementsContainer,
                                 operation: .gettingSnippetElements)
   }
   
   return await context.perform { self.folderedContentElements }
  } //get async throws...
 } //snippet...
 
 
 
 public var unfolderedContentElementsAsync: [Element]  {
  get async throws  {
   guard let context = self.managedObjectContext else {
    throw ContextError.noContext(object: self,
                                 entity: .mixedElementsContainer,
                                 operation: .gettingSnippetElements)
   }
   
   return await context.perform { self.unfolderedContentElements }
  } //get async throws...
 } //snippet...
 
 
 public var folderedContentElementsIDsAsync: [UUID]  {
  get async throws {
   
   guard let context = self.managedObjectContext else {
    throw ContextError.noContext(object: self,
                                 entity: .mixedElementsContainer,
                                 operation: .gettingSnippetElementsIDs)
   }
   
   return await context.perform { self.folderedContentElements.compactMap(\.id) }
  } //get async throws...
 } //snippet..
 
 
 public var unfolderedContentElementsIDsAsync: [UUID]  {
  get async throws {
   
   guard let context = self.managedObjectContext else {
    throw ContextError.noContext(object: self,
                                 entity: .mixedElementsContainer,
                                 operation: .gettingSnippetElementsIDs)
   }
   
   return await context.perform { self.unfolderedContentElements.compactMap(\.id) }
  } //get async throws...
 } //snippet..
 
}//extension scope...

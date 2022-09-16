

@available(iOS 15.0, *)
extension Collection where Self.Element: NMContentElementsContainer {
 public var DTOs: [SnippetDTO] {
  get async throws {
   try await withThrowingTaskGroup(of: SnippetDTO.self, returning: [SnippetDTO].self) { group in
    
    forEach { snippet in
     
      switch snippet {
       case let snippet as NMPhotoSnippet: group.addTask { try await snippet.asyncDTO }
       case let snippet as NMAudioSnippet: group.addTask { try await snippet.asyncDTO }
       case let snippet as NMVideoSnippet: group.addTask { try await snippet.asyncDTO }
       case let snippet as NMTextSnippet:  group.addTask { try await snippet.asyncDTO }
       case let snippet as NMMixedSnippet: group.addTask { try await snippet.asyncDTO }
       default: return
      }
     }
    
    return try await group.reduce(into: []) {$0.append($1)}
     
   }
    
  }
 }
}

@available(iOS 15.0, *)
extension Collection where Self.Element: NMContentFolder {
 public var DTOs: [FolderDTO] {
  get async throws {
   try await withThrowingTaskGroup(of: FolderDTO.self, returning: [FolderDTO].self) { group in
    
    forEach { folder in
     
     switch folder {
      case let folder as NMPhotoFolder: group.addTask { try await folder.asyncDTO }
      case let folder as NMAudioFolder: group.addTask { try await folder.asyncDTO }
      case let folder as NMVideoFolder: group.addTask { try await folder.asyncDTO }
      case let folder as NMTextFolder:  group.addTask { try await folder.asyncDTO }
      case let folder as NMMixedFolder: group.addTask { try await folder.asyncDTO }
      default: return
     }
    }
    
    return try await group.reduce(into: []) {$0.append($1)}
    
   }
   
  }
 }
}

@available(iOS 15.0, *)
extension Collection where Self.Element: NMContentElement {
 public var DTOs: [ContentElementDTO] {
  get async throws {
   try await withThrowingTaskGroup(of: ContentElementDTO.self, returning: [ContentElementDTO].self) { group in
    
    forEach { element in group.addTask { try await element.asyncDTO } }
    
    return try await group.reduce(into: []) {$0.append($1)}
    
   }
   
  }
 }
}

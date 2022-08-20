

public protocol MixedContentFolderElementsBuilderable {}

@available(iOS 15.0, macOS 12.0, *)
extension NMContentElementBuilder: MixedContentFolderElementsBuilderable {}

@available(iOS 15.0, macOS 12.0, *)
@resultBuilder public struct MixedContentFolderBuilder {
 
 public typealias TGroupBuilder = MixedContentFolderGroupBuilder
 public typealias TComponent = MixedContentFolderElementsBuilderable
 
 static public func buildBlock(_ components: TComponent...) -> TGroupBuilder {
  TGroupBuilder(elementsBuilders: components)
 }
 
 public static func buildArray(_ components: [TComponent]) -> TGroupBuilder {
  TGroupBuilder(elementsBuilders: components)
 }
 
}

@available(iOS 15.0, macOS 12.0, *)
public struct NMMixedFolderBuilder: ContentFoldersBuilderable {

 public typealias TMixedSinglesBuilder = () -> MixedContentFolderGroupBuilder

 let mixedFolderBuilder: MixedContentFolderGroupBuilder
 
 public let updates: (NMMixedFolder) throws -> ()
 
 public let persist: Bool
 
 public init (persist: Bool,
              updates: @escaping (NMMixedFolder) throws -> (),
              @MixedContentFolderBuilder elements: TMixedSinglesBuilder = { .empty }){
  
  self.persist = persist
  self.updates = updates
  self.mixedFolderBuilder = elements()
  
 }
 
 public typealias MixedNode = FolderBuilderNode<NMMixedFolder>
 
 public var build: @Sendable (NMMixedSnippet) async throws -> MixedNode {
  { mixedSnippet in
   let mixedFolder = try await mixedSnippet.createFolder(of: NMMixedFolder.self, persist: persist, with: updates)
   let mixedNodes = try await mixedFolderBuilder.build(mixedSnippet, mixedFolder)
   return FolderBuilderNode(parent: mixedFolder, childNodes: mixedNodes)
  }
 }
 
 public var buildMixed: @Sendable (NMMixedSnippet) async throws -> MixedNode { build }
 
}

@available(iOS 15.0, macOS 12.0, *)
public struct MixedContentFolderGroupBuilder: MixedContentFolderElementsBuilderable {
 
 public static var empty: Self { .init(elementsBuilders: []) }
 
 public let elementsBuilders: [ MixedContentFolderElementsBuilderable ]
 
 public var build: @Sendable (NMMixedSnippet, NMMixedFolder?) async throws -> [ BuilderTreeNodeRepresentable ]{
  
  { @Sendable (snippet: NMMixedSnippet, folder: NMMixedFolder?) async throws -> [ BuilderTreeNodeRepresentable ] in
   try await withThrowingTaskGroup(of: (Int, [BuilderTreeNodeRepresentable]?).self) { group in
    elementsBuilders.enumerated().forEach { (index, builder) in
     group.addTask {
      switch builder {
       case let builder as Photo: return (index, [try await builder.buildMixedFolder(snippet, folder)])
       case let builder as Audio: return (index, [try await builder.buildMixedFolder(snippet, folder)])
       case let builder as Text:  return (index, [try await builder.buildMixedFolder(snippet, folder)])
       case let builder as Video: return (index, [try await builder.buildMixedFolder(snippet, folder)])
       case let builder as Self:  return (index,  try await builder.build           (snippet, folder))
       default: return (index, nil)
      }
      
     }
    }
    
    return try await group.reduce(into: []){$0.append($1)}.sorted{$0.0 < $1.0}.compactMap{$0.1}.flatMap{$0}
   }
  }
 }
}

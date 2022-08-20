
@available(iOS 15.0, macOS 12.0, *)
public protocol FoldersGroupBuilderable: BaseContentElementsBuilderable {
 
 associatedtype S: NMContentElementsContainer
 associatedtype FolderBuilderType: ContentFoldersBuilderable
 
 typealias FNode = FolderBuilderNode<FolderBuilderType.F>
 
 var build: @Sendable (S) async throws -> [FNode] { get }
 var buildMixed: @Sendable (NMMixedSnippet) async throws -> [FNode] { get }
}


@available(iOS 15.0, macOS 12.0, *)
public protocol ContentFoldersBuilderable: BaseContentElementsBuilderable {
 
 associatedtype S: NMContentElementsContainer
 associatedtype F: NMContentFolder 
 
 var updates: (F) throws -> () { get }
 var persist: Bool { get }
 
 typealias FNode = FolderBuilderNode<F>
 
 var build: @Sendable (S) async throws -> FNode { get }
 var buildMixed: @Sendable (NMMixedSnippet) async throws -> FNode{ get }
}


@available(iOS 15.0, macOS 12.0, *)
public struct ContentFoldersGroupBuilder<FolderBuilderType>: FoldersGroupBuilderable
where FolderBuilderType: ContentFoldersBuilderable {
 
 public static var empty: Self { .init(foldersBuilders: []) }
 
 public let foldersBuilders: [ BaseContentElementsBuilderable ]
 
 public typealias FNode = FolderBuilderNode<FolderBuilderType.F>
 
 public var build: @Sendable (FolderBuilderType.S) async throws -> [FNode] {

  { @Sendable (snippet: FolderBuilderType.S) async throws -> [FNode] in
   try await withThrowingTaskGroup(of: (Int, [FNode]).self) { group in
    foldersBuilders.enumerated().forEach{ (index, builder) in
     switch builder {
      case let builder as FolderBuilderType: group.addTask { (index, [try await builder.build(snippet)]) }
      case let builder as Self             : group.addTask { (index,  try await builder.build(snippet))  }
      default: return
     }
    }

    return try await group.reduce(into: []){ $0.append($1)}.sorted{$0.0 < $1.0}.flatMap{$0.1}
   }
  }
 }

 public var buildMixed: @Sendable (NMMixedSnippet) async throws -> [FNode] {

  { @Sendable (snippet: NMMixedSnippet) async throws -> [FNode] in
   try await withThrowingTaskGroup(of: (Int, [FNode]).self) { group in
    foldersBuilders.enumerated().forEach{ (index, builder) in
     switch builder {
      case let builder as FolderBuilderType: group.addTask { (index, [try await builder.buildMixed(snippet)]) }
      case let builder as Self             : group.addTask { (index,  try await builder.buildMixed(snippet))  }
      default: return
     }
    }

    return try await group.reduce(into: []){ $0.append($1) }.sorted{$0.0 < $1.0}.flatMap{$0.1}
   }
  }
 }

}


@available(iOS 15.0, macOS 12.0, *)
@resultBuilder public struct ContainerFoldersBuilder<FolderBuilderType>
  where FolderBuilderType: ContentFoldersBuilderable {
 
 public typealias TGroupBuilder = ContentFoldersGroupBuilder<FolderBuilderType>
 public typealias TComponent = BaseContentElementsBuilderable
 
 static public func buildBlock(_ components: TComponent...) -> TGroupBuilder {
  TGroupBuilder(foldersBuilders: components)
 }
 
 public static func buildArray(_ components: [TComponent]) -> TGroupBuilder {
  TGroupBuilder(foldersBuilders: components)
 }
 
}


@available(iOS 15.0, macOS 12.0, *)
public struct NMFolderBuilder<F, SingleBuilderType>: ContentFoldersBuilderable
where SingleBuilderType: ContentElementsBuilderable,
      SingleBuilderType.S == F.Snippet,
      F.Element: NMContentElement,
      F.Element.Snippet == F.Snippet,
      F.Element.Folder == F.Snippet.Folder,
      F.Element == F.Snippet.Element,
      F == F.Element.Folder,
      F == SingleBuilderType.F
{
 
 public typealias TSinglesGroupBuilder = ContentSingleElementsGroupBuilder<SingleBuilderType>
 public typealias TSinglesBuilder = () -> TSinglesGroupBuilder
 public typealias SinglesBuilder = ContainerSingleElementsBuilder<SingleBuilderType>
 
 let singlesBuilder: TSinglesGroupBuilder
 
 public let updates: (F) throws -> ()
 public let persist: Bool
 
 public init (persist: Bool, updates: @escaping (F) throws -> (),
              @SinglesBuilder elements: TSinglesBuilder = { .empty }){
  
  self.persist = persist
  self.updates = updates
  self.singlesBuilder = elements()
  
 }
 
 public typealias FNode = FolderBuilderNode<F>
 
 public var build: @Sendable ( F.Snippet ) async throws -> FNode {
  { snippet in
   let folder = try await F.create(snippet: snippet, persist: persist, with: updates)
   let singlesNodes = try await singlesBuilder.build(snippet, folder)
   return FNode(parent: folder, childNodes: singlesNodes)
  }
 }

 public var buildMixed: @Sendable (NMMixedSnippet ) async throws -> FNode  {
  { snippet in
   let folder = try await snippet.createFolder(of: F.self, persist: persist, with: updates)
   let singlesNodes = try await singlesBuilder.buildMixed(snippet, folder)
   return FNode(parent: folder, childNodes: singlesNodes)
  }
 }
 
 
}





@available(iOS 15.0, *)
public typealias PhotoFolder = NMFolderBuilder<NMPhotoFolder, Photo>

@available(iOS 15.0, *)
public typealias VideoFolder = NMFolderBuilder<NMVideoFolder, Video>

@available(iOS 15.0, *)
public typealias TextFolder = NMFolderBuilder<NMTextFolder, Text>

@available(iOS 15.0, *)
public typealias AudioFolder = NMFolderBuilder<NMAudioFolder, Audio>

@available(iOS 15.0, *)
public typealias MixedFolder = NMMixedFolderBuilder


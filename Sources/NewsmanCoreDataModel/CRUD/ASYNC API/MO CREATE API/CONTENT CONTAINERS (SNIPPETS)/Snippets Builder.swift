
import CoreData

@available(iOS 15.0, macOS 12.0, *)
public protocol SnippetsBuilder {
 var build: @Sendable () async throws -> [BuilderTreeNodeRepresentable] { get }
}

@available(iOS 15.0, macOS 12.0, *)
public struct SnippetGroupBuilder: SnippetsBuilder {
 
 let snippetBuilders: [SnippetsBuilder]
 
 public var build: @Sendable () async throws -> [BuilderTreeNodeRepresentable] {
  
  { @Sendable () async throws -> [ BuilderTreeNodeRepresentable ] in
   try await withThrowingTaskGroup(of: (Int, [BuilderTreeNodeRepresentable]).self) { group in
    snippetBuilders.enumerated().forEach { (index, builder) in
     group.addTask{ (index, try await builder.build()) }
    }
    return try await group.reduce(into: []) { $0.append($1) }.sorted{ $0.0 < $1.0 }.flatMap{$0.1}
   }
  }
  
 }
 
}

@available(iOS 15.0, macOS 12.0, *)
@resultBuilder public struct ModelBuilder {
 
 static public func buildBlock(_ components: SnippetsBuilder...) -> SnippetsBuilder {
  SnippetGroupBuilder(snippetBuilders: components)
 }
 
 public static func buildArray(_ components: [SnippetsBuilder]) -> SnippetsBuilder {
  SnippetGroupBuilder(snippetBuilders: components)
 }
}


@available(iOS 15.0, macOS 12.0, *)
public typealias TTopBuilder = (NSManagedObjectContext) -> SnippetsBuilder

@available(iOS 15.0, macOS 12.0, *)
public struct CoreDataModel {
 let modelBuilder: SnippetsBuilder
 let snippetsTree: SnippetsBuilderTree
 
 @discardableResult
 public init (model: NMCoreDataModel, @ModelBuilder builder: TTopBuilder) async throws {
  
  let context = await model.mainContext
  let modelBuilder = builder(context)
  self.modelBuilder = modelBuilder
  let snippetNodes = try await modelBuilder.build()
  self.snippetsTree = .init(nodes: snippetNodes)
  
 }
}


extension NMCoreDataModel{
 @available(iOS 15.0, macOS 12.0, *)
 public func callAsFunction(@ModelBuilder builder: TTopBuilder) async throws -> SnippetsBuilderTree {
  let context = await mainContext
  let modelBuilder = builder(context)
  let snippetNodes = try await modelBuilder.build()
  return .init(nodes: snippetNodes)
 }
}



@available(iOS 15.0, macOS 12.0, *)
public struct NMSnippetBuilder<FolderBuilderType, SingleBuilderType>: SnippetsBuilder
 where FolderBuilderType: ContentFoldersBuilderable,
       SingleBuilderType: ContentElementsBuilderable,
       FolderBuilderType.S == SingleBuilderType.S
{
 
 public typealias TUpdateBlock = (FolderBuilderType.S) throws -> ()
 public typealias TFoldersGroupBuilder = ContentFoldersGroupBuilder<FolderBuilderType>
 public typealias TSinglesGroupBuilder = ContentSingleElementsGroupBuilder<SingleBuilderType>
 
 let updates: TUpdateBlock?
 let context: NSManagedObjectContext
 let persist: Bool
 
 let foldersBuilder: TFoldersGroupBuilder
 let singlesBuilder: TSinglesGroupBuilder
 
 public typealias TFoldersBuilder = () -> TFoldersGroupBuilder
 public typealias TSinglesBuilder = () -> TSinglesGroupBuilder
 
 public typealias FoldersBuilder = ContainerFoldersBuilder<FolderBuilderType>
 public typealias SinglesBuilder = ContainerSingleElementsBuilder<SingleBuilderType>
 
 public init(context: NSManagedObjectContext,
             persist: Bool = true,
             updates: TUpdateBlock? = nil ,
             @FoldersBuilder folders:  TFoldersBuilder = { .empty },
             @SinglesBuilder elements: TSinglesBuilder = { .empty }) {
  
  self.context = context
  self.persist = persist
  self.updates = updates
  self.foldersBuilder = folders() //as! ContentFoldersGroupBuilder<S>
  self.singlesBuilder = elements() //as! ContentSingleElementsGroupBuilder<S>
  
 }
 
 public var build: @Sendable () async throws -> [BuilderTreeNodeRepresentable] {
  { @Sendable () async throws -> [BuilderTreeNodeRepresentable] in
   let snippet = try await FolderBuilderType.S.create(in: context, persist: persist, with: updates)
   let foldersNodes = try await foldersBuilder.build(snippet)
   let singlesNodes = try await singlesBuilder.build(snippet, nil)
   let childNodes = foldersNodes as [BuilderTreeNodeRepresentable] +
                    singlesNodes as [BuilderTreeNodeRepresentable]
   return [SnippetBuilderNode(parent: snippet, childNodes: childNodes)]
  }
 }
 
}

@available(iOS 15.0, macOS 12.0, *)
public typealias PhotoContainer = NMSnippetBuilder<PhotoFolder, Photo>

@available(iOS 15.0, macOS 12.0, *)
public typealias VideoContainer = NMSnippetBuilder<VideoFolder, Video>

@available(iOS 15.0, macOS 12.0, *)
public typealias TextContainer = NMSnippetBuilder<TextFolder, Text>

@available(iOS 15.0, macOS 12.0, *)
public typealias AudioContainer = NMSnippetBuilder<AudioFolder, Audio>

//@available(iOS 15.0, macOS 12.0, *)
//public typealias MixedContainer = NMSnippetBuilder<NMMixedSnippet, MixedFolder, >





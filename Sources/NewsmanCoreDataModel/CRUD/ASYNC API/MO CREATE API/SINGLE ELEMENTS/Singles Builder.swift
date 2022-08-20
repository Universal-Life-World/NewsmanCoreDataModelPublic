

public protocol BaseContentElementsBuilderable {}

@available(iOS 15.0, macOS 12.0, *)
public protocol ContentElementsGroupBuilderable: BaseContentElementsBuilderable {
 
 associatedtype S: NMContentElementsContainer
 associatedtype F: NMContentFolder
 associatedtype SingleBuilderType: ContentElementsBuilderable
 
 typealias ENode = ElementBuilderNode<SingleBuilderType.E>
 
 var build: @Sendable (S, F?) async throws -> [ENode] { get }
 var buildMixed: @Sendable (NMMixedSnippet, F?) async throws -> [ENode]  { get }
 
}


@available(iOS 15.0, macOS 12.0, *)
public protocol ContentElementsBuilderable: BaseContentElementsBuilderable {
 
 associatedtype E: NMContentElement
 
 var updates: (E) throws -> () { get }
 var persist: Bool { get }
 
 associatedtype S: NMContentElementsContainer
 associatedtype F: NMContentFolder
 
 typealias ENode = ElementBuilderNode<E>
 
 var build: @Sendable (S, F?) async throws -> ENode  { get }
 var buildMixed: @Sendable (NMMixedSnippet, F?) async throws -> ENode { get }


}


@available(iOS 15.0, macOS 12.0, *)
public struct ContentSingleElementsGroupBuilder<SingleBuilderType>: ContentElementsGroupBuilderable
 where SingleBuilderType: ContentElementsBuilderable
{
 
 public static var empty: Self { .init(elementsBuilders: []) }
 
 public let elementsBuilders: [ BaseContentElementsBuilderable ]
 
 public typealias ENode =  ElementBuilderNode<SingleBuilderType.E>
 
 public var build: @Sendable (SingleBuilderType.S, SingleBuilderType.F?) async throws -> [ENode]  {

  { @Sendable (snippet: SingleBuilderType.S, folder: SingleBuilderType.F?) async throws -> [ENode] in
   try await withThrowingTaskGroup(of: (Int, [ENode]).self) { group in
    elementsBuilders.enumerated().forEach{ (index, builder) in
     switch builder {
      case let builder as SingleBuilderType:
       group.addTask { (index, [try await builder.build(snippet, folder)])}
      case let builder as Self:
       group.addTask { (index,  try await builder.build(snippet, folder)) }
      default: return
     }
     
    }

    return try await group.reduce(into: []){ $0.append($1)}.sorted{$0.0 < $1.0}.flatMap{$0.1}
   }
  }//@Sendable...
 }//public var build..

 public var buildMixed: @Sendable (NMMixedSnippet, SingleBuilderType.F?) async throws -> [ENode]  {

  { @Sendable (snippet: NMMixedSnippet, folder: SingleBuilderType.F?) async throws -> [ENode] in
   try await withThrowingTaskGroup(of: (Int, [ENode]).self) { group in
    elementsBuilders.enumerated().forEach{ (index, builder) in
     switch builder {
      case let builder as SingleBuilderType:
       group.addTask { (index, [try await builder.buildMixed(snippet, folder)]) }
       
      case let builder as Self:
       group.addTask { (index, try await builder.buildMixed(snippet, folder)) }
      default: return
     }
    }

    return try await group.reduce(into: []){ $0.append($1)}.sorted{$0.0 < $1.0}.flatMap{$0.1}
   }
  }//@Sendable...
 }//public var build..
 
 
}




@available(iOS 15.0, macOS 12.0, *)
@resultBuilder public struct ContainerSingleElementsBuilder<SingleBuilderType>
  where SingleBuilderType: ContentElementsBuilderable
{
 
 public typealias TGroupBuilder = ContentSingleElementsGroupBuilder<SingleBuilderType>
 public typealias TComponent = BaseContentElementsBuilderable
 
 public static func buildBlock(_ components: TComponent...) -> TGroupBuilder {
  .init(elementsBuilders: components)
 }
 
 
 public static func buildArray(_ components: [TComponent]) -> TGroupBuilder {
  .init(elementsBuilders: components)
 }
 
 
}


@available(iOS 15.0, macOS 12.0, *)
public struct NMContentElementBuilder<E: NMContentElement>: ContentElementsBuilderable
  where E.Folder.Snippet == E.Snippet,
        E.Folder == E.Snippet.Folder,
        E == E.Folder.Element,
        E == E.Snippet.Element {
 

 public let updates: (E) throws -> ()
 public let persist: Bool
 
 public init(persist: Bool, updates: @escaping (E) throws -> ()){
  self.persist = persist
  self.updates = updates
 }
 
 public typealias ENode =  ElementBuilderNode<E>
 
 public var build: @Sendable (E.Snippet, E.Folder?) async throws -> ENode  {
  { .init(parent: try await E.create(snippet: $0, folder: $1, persist: persist, with: updates)) }
 }

 public var buildMixed: @Sendable (NMMixedSnippet, E.Folder?) async throws -> ENode  {
  { .init(parent: try await $0.createSingle(of: E.self, in: $1, persist: persist, with: updates)) }
 }
 
 public var buildMixedFolder: @Sendable (NMMixedSnippet, NMMixedFolder?) async throws -> ENode  {
  { .init(parent: try await $0.createSingle(of: E.self, into: $1, persist: persist, with: updates)) }
 }
 
}


@available(iOS 15.0, *)
public typealias Photo = NMContentElementBuilder<NMPhoto>

@available(iOS 15.0, *)
public typealias Video = NMContentElementBuilder<NMVideo>

@available(iOS 15.0, *)
public typealias Text = NMContentElementBuilder<NMText>

@available(iOS 15.0, *)
public typealias Audio = NMContentElementBuilder<NMAudio>



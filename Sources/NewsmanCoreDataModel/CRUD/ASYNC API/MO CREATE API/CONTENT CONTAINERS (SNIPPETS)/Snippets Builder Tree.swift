
public protocol BuilderTreeNodeRepresentable {}

public struct FolderBuilderNode<F: NMContentFolder>: BuilderTreeNodeRepresentable{
 public let parent: F
 public let childNodes: [BuilderTreeNodeRepresentable]
}

public struct ElementBuilderNode<E: NMContentElement>: BuilderTreeNodeRepresentable {
 public let parent: E
}

public struct SnippetBuilderNode<S: NMContentElementsContainer>: BuilderTreeNodeRepresentable {
 let parent: S
 let childNodes: [BuilderTreeNodeRepresentable]
}

public struct SnippetsBuilderTree {
 let nodes: [BuilderTreeNodeRepresentable]
 
 public var photoSnippets: [NMPhotoSnippet] {
  nodes.compactMap{($0 as? SnippetBuilderNode<NMPhotoSnippet>)?.parent}
 }
 
 public var audioSnippets: [NMAudioSnippet] {
  nodes.compactMap{($0 as? SnippetBuilderNode<NMAudioSnippet>)?.parent}
 }
 
 public var textSnippets: [NMTextSnippet] {
  nodes.compactMap{($0 as? SnippetBuilderNode<NMTextSnippet>)?.parent}
 }
 
 public var videoSnippets: [NMVideoSnippet] {
  nodes.compactMap{($0 as? SnippetBuilderNode<NMVideoSnippet>)?.parent}
 }
 
 public var mixedSnippets: [NMMixedSnippet] {
  nodes.compactMap{($0 as? SnippetBuilderNode<NMMixedSnippet>)?.parent}
 }
 
 public var snippets: [NMBaseSnippet] {
  photoSnippets as [NMBaseSnippet] + textSnippets  as [NMBaseSnippet] +
  audioSnippets as [NMBaseSnippet] + videoSnippets as [NMBaseSnippet] +
  mixedSnippets as [NMBaseSnippet]
 }
 
 public subscript<S: NMContentElementsContainer> (si: Int) -> S?{
  guard si >= 0 && si < nodes.count else { return nil }
  return (nodes[si] as? SnippetBuilderNode<S>)?.parent
 }
 
 public subscript(si: Int) -> NMBaseSnippet?{
  guard si >= 0 && si < nodes.count else { return nil }
  
  switch nodes[si]{
   case let node as SnippetBuilderNode<NMPhotoSnippet>: return node.parent
   case let node as SnippetBuilderNode<NMAudioSnippet>: return node.parent
   case let node as SnippetBuilderNode<NMTextSnippet> : return node.parent
   case let node as SnippetBuilderNode<NMVideoSnippet>: return node.parent
   case let node as SnippetBuilderNode<NMMixedSnippet>: return node.parent
   default: return nil
  }
  
 }
 
 public subscript<F: NMContentFolder> (si: Int, fi: Int) -> F? {
  guard si >= 0 && si < nodes.count else { return nil }
  guard let nodes = (nodes[si] as? SnippetBuilderNode<F.Snippet>)?.childNodes else { return nil }
  guard fi >= 0 && fi < nodes.count else { return nil }
  return (nodes[fi] as? FolderBuilderNode<F>)?.parent
 }
 
 public subscript (si: Int, fi: Int) -> NMBaseContent? {
  guard si >= 0 && si < nodes.count else { return nil }
  
  switch nodes[si]{
   case let node as SnippetBuilderNode<NMPhotoSnippet> where fi >= 0 && fi < node.childNodes.count:
    return (node.childNodes[fi] as? FolderBuilderNode<NMPhotoFolder>)?.parent ??
    (node.childNodes[fi] as? ElementBuilderNode<NMPhoto>)?.parent
    
   case let node as SnippetBuilderNode<NMAudioSnippet> where fi >= 0 && fi < node.childNodes.count:
    return (node.childNodes[fi] as? FolderBuilderNode<NMAudioFolder>)?.parent ??
    (node.childNodes[fi] as? ElementBuilderNode<NMAudio>)?.parent
    
   case let node as SnippetBuilderNode<NMTextSnippet> where fi >= 0 && fi < node.childNodes.count:
    return (node.childNodes[fi] as? FolderBuilderNode<NMTextFolder>)?.parent ??
    (node.childNodes[fi] as? ElementBuilderNode<NMText>)?.parent
    
   case let node as SnippetBuilderNode<NMVideoSnippet> where fi >= 0 && fi < node.childNodes.count:
    return (node.childNodes[fi] as? FolderBuilderNode<NMVideoFolder>)?.parent ??
    (node.childNodes[fi] as? ElementBuilderNode<NMVideo>)?.parent
    
   case let node as SnippetBuilderNode<NMMixedSnippet> where fi >= 0 && fi < node.childNodes.count:
    switch node.childNodes[fi] {
      
     case let node as ElementBuilderNode<NMPhoto>      : return node.parent
     case let node as FolderBuilderNode<NMPhotoFolder> : return node.parent
      
     case let node as ElementBuilderNode<NMAudio>      : return node.parent
     case let node as FolderBuilderNode<NMAudioFolder> : return node.parent
      
     case let node as ElementBuilderNode<NMText>       : return node.parent
     case let node as FolderBuilderNode<NMTextFolder>  : return node.parent
      
     case let node as ElementBuilderNode<NMVideo>      : return node.parent
     case let node as FolderBuilderNode<NMVideoFolder> : return node.parent
      
     case let node as FolderBuilderNode<NMMixedFolder> : return node.parent
      
     default: return nil
    }
    
   default: return nil
  }
 }
 
 public subscript<E: NMContentElement> (si: Int, ei: Int) -> E?  {
  guard si >= 0 && si < nodes.count else { return nil }
  guard let nodes = (nodes[si] as? SnippetBuilderNode<E.Snippet>)?.childNodes else { return nil }
  guard ei >= 0 && ei < nodes.count else { return nil }
  return (nodes[ei] as? ElementBuilderNode<E>)?.parent
 }
 
 public subscript<E: NMContentElement> (si: Int, fi: Int, ei: Int) -> E? {
  guard si >= 0 && si < nodes.count else { return nil }
  guard let nodes = (nodes[si] as? SnippetBuilderNode<E.Snippet>)?.childNodes else { return nil }
  guard fi >= 0 && fi < nodes.count else { return nil }
  guard let nodes = (nodes[fi] as? FolderBuilderNode<E.Folder>)?.childNodes else { return nil }
  guard ei >= 0 && ei < nodes.count else { return nil }
  return (nodes[ei] as? ElementBuilderNode<E>)?.parent
  
 }
 
 public subscript (si: Int, fi: Int, ei: Int) -> NMBaseContent? {
  guard si >= 0 && si < nodes.count else { return nil }
  
  switch nodes[si]{
   case let node as SnippetBuilderNode<NMPhotoSnippet> where fi >= 0 && fi < node.childNodes.count:
    switch node.childNodes[fi] {
     case let node as FolderBuilderNode<NMPhotoFolder> where ei >= 0 && ei < node.childNodes.count:
      return (node.childNodes[ei] as? ElementBuilderNode<NMPhoto>)?.parent
     default: return nil
    }
    
    
   case let node as SnippetBuilderNode<NMAudioSnippet> where fi >= 0 && fi < node.childNodes.count:
    switch node.childNodes[fi] {
     case let node as FolderBuilderNode<NMAudioFolder> where ei >= 0 && ei < node.childNodes.count:
      return (node.childNodes[ei] as? ElementBuilderNode<NMAudio>)?.parent
     default: return nil
    }
    
   case let node as SnippetBuilderNode<NMTextSnippet> where fi >= 0 && fi < node.childNodes.count:
    switch node.childNodes[fi] {
     case let node as FolderBuilderNode<NMTextFolder> where ei >= 0 && ei < node.childNodes.count:
      return (node.childNodes[ei] as? ElementBuilderNode<NMText>)?.parent
     default: return nil
    }
    
   case let node as SnippetBuilderNode<NMVideoSnippet> where fi >= 0 && fi < node.childNodes.count:
    switch node.childNodes[fi] {
     case let node as FolderBuilderNode<NMVideoFolder> where ei >= 0 && ei < node.childNodes.count:
      return (node.childNodes[ei] as? ElementBuilderNode<NMVideo>)?.parent
     default: return nil
    }
    
   case let node as SnippetBuilderNode<NMMixedSnippet> where fi >= 0 && fi < node.childNodes.count:
    switch node.childNodes[fi] {
      
     case let node as FolderBuilderNode<NMPhotoFolder> where ei >= 0 && ei < node.childNodes.count:
      return (node.childNodes[ei] as? ElementBuilderNode<NMPhoto>)?.parent
     case let node as FolderBuilderNode<NMAudioFolder> where ei >= 0 && ei < node.childNodes.count:
      return (node.childNodes[ei] as? ElementBuilderNode<NMAudio>)?.parent
     case let node as FolderBuilderNode<NMTextFolder>  where ei >= 0 && ei < node.childNodes.count:
      return (node.childNodes[ei] as? ElementBuilderNode<NMText>)?.parent
     case let node as FolderBuilderNode<NMVideoFolder> where ei >= 0 && ei < node.childNodes.count:
      return (node.childNodes[ei] as? ElementBuilderNode<NMVideo>)?.parent
     case let node as FolderBuilderNode<NMMixedFolder> where ei >= 0 && ei < node.childNodes.count:
      switch node.childNodes[ei] {
       case let node as ElementBuilderNode<NMPhoto>: return node.parent
       case let node as ElementBuilderNode<NMText> : return node.parent
       case let node as ElementBuilderNode<NMAudio>: return node.parent
       case let node as ElementBuilderNode<NMVideo>: return node.parent
       default: return nil
      }
      
     default: return nil
    }
    
   default: return nil
  }
 }
 
}

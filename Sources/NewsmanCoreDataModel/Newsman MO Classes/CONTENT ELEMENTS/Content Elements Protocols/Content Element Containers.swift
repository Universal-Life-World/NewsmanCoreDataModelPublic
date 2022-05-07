
import Foundation

public protocol NMSnippetContained where Self: NMBaseContent{
 var snippetID: UUID? { get }
}

public protocol NMFolderContained where Self: NMBaseContent{
 var folderID: UUID? { get }
}

public typealias NMContainerContained = NMSnippetContained & NMFolderContained


import Foundation
import Combine

public protocol NMBaseSnippetUIStateObservable {
 
 var snippet: NMBaseSnippet?                            { get set }
 var disposeBag: Set<AnyCancellable>                    { get set }
}

public protocol NMBaseSnippetUICellConfiguration {

 var date: Date?                                        { get     }
 var about: String?                                     { get set }
 var isContentCopyable: Bool?                           { get set }
 var isContentEditable: Bool?                           { get set }
 var isContentPublishable: Bool?                        { get set }
 var isContentSharable: Bool?                           { get set }
 var isDeletable: Bool?                                 { get set }
 var isDragAnimating: Bool?                             { get set }
 var isDraggable: Bool?                                 { get set }
 var isHiddenFromSection: Bool?                         { get set }
 var isHideableFromSection: Bool?                       { get set }
 var isMergeable: Bool?                                 { get set }
 var isSelected: Bool?                                  { get set }
 var isShowingSnippetDetailedCell: Bool?                { get set }
 var isTrashable: Bool?                                 { get set }
 var lastAccessedTimeStamp: Date?                       { get set }
 var lastModifiedTimeStamp: Date?                       { get set }
              
 var location: String?                                  { get set }
 var nameTag: String?                                   { get set }
 var priority: NMBaseSnippet.SnippetPriority?           { get set }
 var publishedTimeStamp: Date?                          { get set }
 
 var status: NMBaseSnippet.SnippetStatus?               { get set }
 var connectedWithTopNews: Int?                         { get set }
 var type: NMBaseSnippet.SnippetType?                   { get set }

}


import CoreData

public protocol NMNormalizedSearchParentRepresentable where Self: NSManagedObject {
 
 var parent: NMNormalizedSearchChildrenRepresentable? { get }
}

public protocol NMNormalizedSearchChildrenRepresentable where Self: NSManagedObject {
 
 static var normalizedSearchChildrenKey: String { get }
 var children: [ NMNormalizedSearchParentRepresentable ] { get }
}

public extension NMNormalizedSearchChildrenRepresentable  {
 
 var searchChildrenString: String {
  
  let s = Set(children.filter{ !$0.isDeleted }.map{ $0.normalizedSearchString })
   //DELETED CONTENTS ELEMENTS ARE NOT SEARCHED!
  
  return s.reduce(into: s){ s1, el in
   if s1.contains(where: {$0 != el && $0.contains(el)}) { s1.remove(el) }
  }.reduce(""){ $0 + ($0.isEmpty ? "" : " ") + $1 }
   
 }
 
 func updateSearchChildrenString() {
  setValue(searchChildrenString, forKey: Self.normalizedSearchChildrenKey)
 }
}

public extension NMNormalizedSearchParentRepresentable {
 func updateParentSearchChildrenString() {
  guard (changedValuesForCurrentEvent().keys.contains{$0.hasPrefix(.normalizedFieldNamePrefix)} || isDeleted)
  else { return }
  parent?.updateSearchChildrenString()
 }
 
 //SEARCH ONLY INSIDE NORMALIZED STRING FIELDS: "normalizedSearch..."
 var normarizedSearchFieldNames: [String] {
  entity.attributesByName.keys.filter{ $0.hasPrefix(.normalizedFieldNamePrefix) }
 }
 
 var normalizedSearchString: String {
  
  let s = Set(normarizedSearchFieldNames.compactMap{ value(forKey:$0) as? String })
  
  return s.reduce(into: s){ s1, el in
   if s1.contains(where: {$0 != el && $0.contains(el)}) { s1.remove(el) }
  }.reduce(""){ $0 + ($0.isEmpty ? "" : " ") + $1 }
  
 
 }
}


 //MARK: Content elements of snippets.
extension NMPhoto: NMNormalizedSearchParentRepresentable {
 public var parent: NMNormalizedSearchChildrenRepresentable? { photoSnippet ?? mixedSnippet }
}

extension NMPhotoFolder: NMNormalizedSearchParentRepresentable {
 public var parent: NMNormalizedSearchChildrenRepresentable? { photoSnippet ?? mixedSnippet }
}

extension NMText: NMNormalizedSearchParentRepresentable {
 public var parent: NMNormalizedSearchChildrenRepresentable? { textSnippet ?? mixedSnippet}
}

extension NMTextFolder: NMNormalizedSearchParentRepresentable {
 public var parent: NMNormalizedSearchChildrenRepresentable? { textSnippet ?? mixedSnippet }
}

extension NMAudio: NMNormalizedSearchParentRepresentable {
 public var parent: NMNormalizedSearchChildrenRepresentable? { audioSnippet ?? mixedSnippet}
}

extension NMAudioFolder: NMNormalizedSearchParentRepresentable {
 public var parent: NMNormalizedSearchChildrenRepresentable? { audioSnippet ?? mixedSnippet}
}

extension NMVideo: NMNormalizedSearchParentRepresentable {
 public var parent: NMNormalizedSearchChildrenRepresentable? { videoSnippet ?? mixedSnippet }
}

extension NMVideoFolder: NMNormalizedSearchParentRepresentable {
 public var parent: NMNormalizedSearchChildrenRepresentable? { videoSnippet ?? mixedSnippet}
}

extension NMMixedFolder: NMNormalizedSearchParentRepresentable {
 public var parent: NMNormalizedSearchChildrenRepresentable? { mixedSnippet }
}


//MARK: Photo content snippet.
extension NMPhotoSnippet: NMNormalizedSearchChildrenRepresentable {
 public static let  normalizedSearchChildrenKey: String = "normalizedSearchChildrenString"
 
 public var allSearchedPhotos: [NMNormalizedSearchParentRepresentable] {
  photos?.allObjects as? [NMNormalizedSearchParentRepresentable] ?? []
 }
 
 public var allSearchedFolders: [NMNormalizedSearchParentRepresentable] {
  photoFolders?.allObjects as? [NMNormalizedSearchParentRepresentable] ?? []
 }
 
 public var children: [NMNormalizedSearchParentRepresentable] { allSearchedPhotos + allSearchedFolders }
}


//MARK: Text content snippet.
extension NMTextSnippet: NMNormalizedSearchChildrenRepresentable {
 
 public static let normalizedSearchChildrenKey: String = "normalizedSearchChildrenString"
 
 public var allSearchedTexts: [NMNormalizedSearchParentRepresentable] {
  texts?.allObjects as? [NMNormalizedSearchParentRepresentable] ?? []
 }
 
 public var allSearchedFolders: [NMNormalizedSearchParentRepresentable] {
  textFolders?.allObjects as? [NMNormalizedSearchParentRepresentable] ?? []
 }
 
 public var children: [NMNormalizedSearchParentRepresentable] { allSearchedTexts + allSearchedFolders }
 
 
}


//MARK: Audio content snippet.
extension NMAudioSnippet: NMNormalizedSearchChildrenRepresentable {
 
 public static let normalizedSearchChildrenKey: String = "normalizedSearchChildrenString"
 
 public var allSearchedAudios: [NMNormalizedSearchParentRepresentable] {
  audios?.allObjects as? [NMNormalizedSearchParentRepresentable] ?? []
 }
 
 public var allSearchedFolders: [NMNormalizedSearchParentRepresentable] {
  audioFolders?.allObjects as? [NMNormalizedSearchParentRepresentable] ?? []
 }
 
 public var children: [NMNormalizedSearchParentRepresentable] { allSearchedAudios + allSearchedFolders }
 
 
}

//MARK: Video content snippet.
extension NMVideoSnippet: NMNormalizedSearchChildrenRepresentable {
 
 public static let normalizedSearchChildrenKey: String = "normalizedSearchChildrenString"
 
 public var allSearchedVideos: [NMNormalizedSearchParentRepresentable] {
  videos?.allObjects as? [NMNormalizedSearchParentRepresentable] ?? []
 }
 
 public var allSearchedFolders: [NMNormalizedSearchParentRepresentable] {
  videoFolders?.allObjects as? [NMNormalizedSearchParentRepresentable] ?? []
 }
 
 public var children: [NMNormalizedSearchParentRepresentable] { allSearchedVideos + allSearchedFolders }
 
 
}

//MARK: Mixed content snippet.

extension NMMixedSnippet: NMNormalizedSearchChildrenRepresentable {
 
 public static let normalizedSearchChildrenKey: String = "normalizedSearchChildrenString"
 
 public var allSearchedPhotos: [NMNormalizedSearchParentRepresentable] {
  photos?.allObjects as? [NMNormalizedSearchParentRepresentable] ?? []
 }
 
 public var allSearchedPhotoFolders: [NMNormalizedSearchParentRepresentable] {
  photoFolders?.allObjects as? [NMNormalizedSearchParentRepresentable] ?? []
 }
 
 public var allSearchedAudios: [NMNormalizedSearchParentRepresentable] {
  audios?.allObjects as? [NMNormalizedSearchParentRepresentable] ?? []
 }
 
 public var allSearchedAudioFolders: [NMNormalizedSearchParentRepresentable] {
  audioFolders?.allObjects as? [NMNormalizedSearchParentRepresentable] ?? []
 }
 
 public var allSearchedVideos: [NMNormalizedSearchParentRepresentable] {
  videos?.allObjects as? [NMNormalizedSearchParentRepresentable] ?? []
 }
 
 public var allSearchedVideoFolders: [NMNormalizedSearchParentRepresentable] {
  videoFolders?.allObjects as? [NMNormalizedSearchParentRepresentable] ?? []
 }
 
 public var allSearchedTexts: [NMNormalizedSearchParentRepresentable] {
  texts?.allObjects as? [NMNormalizedSearchParentRepresentable] ?? []
 }
 
 public var allSearchedTextFolders: [NMNormalizedSearchParentRepresentable] {
  textFolders?.allObjects as? [NMNormalizedSearchParentRepresentable] ?? []
 }
 
 public var allSearchedMixedFolders: [NMNormalizedSearchParentRepresentable] {
  mixedFolders?.allObjects as? [NMNormalizedSearchParentRepresentable] ?? []
 }
 
 
 public var allSearchedFolders: [NMNormalizedSearchParentRepresentable] {
  allSearchedVideoFolders  +
  allSearchedAudioFolders +
  allSearchedPhotoFolders  +
  allSearchedTextFolders   +
  allSearchedMixedFolders
   
 
 }
 
 public var children: [NMNormalizedSearchParentRepresentable] {
  allSearchedVideos +
  allSearchedAudios +
  allSearchedPhotos +
  allSearchedTexts  +
  allSearchedFolders }
 
 
}

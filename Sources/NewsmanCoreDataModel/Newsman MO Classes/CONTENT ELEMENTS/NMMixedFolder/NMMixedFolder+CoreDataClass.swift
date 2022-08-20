//
//  NMMixedFolder+CoreDataClass.swift
//  NewsmanCoreDataModel
//
//  Created by Anton2016 on 06.01.2022.
//
//

import Foundation
import CoreData

@objc(NMMixedFolder)
public class NMMixedFolder: NMBaseContent {}


extension NMMixedFolder: NMUndoManageable {}

@available(iOS 15.0, macOS 12.0, *)
extension NMMixedFolder : NMFileStorageManageable  {

 public var folderedElementsAsync: [NMBaseContent]? {
  get async { await managedObjectContext?.perform { self.folderedElements } }
 }

 public func fileManagerFolderedGroup() async throws {
  try await withThrowingTaskGroup(of: Void.self, returning: Void.self) { group in

   await folderedElementsAsync?.compactMap{$0 as? NMFileStorageManageable}.forEach{ element in
    group.addTask { try await element.fileManagerTaskGroup() }
   }

   try await group.waitForAll()
  }
 }

 public func fileManagerTaskGroup() async throws {
  try await fileManagerTask?.value
  try await fileManagerFolderedGroup()

 }

}

public typealias Element = NMBaseContent
public typealias Snippet = NMMixedSnippet

extension NMMixedFolder: NMContentFolder {
 
 @objc(container) public var snippet: NMMixedSnippet? { mixedSnippet }
 
 @objc public var audios: [NMAudio] { (folderedAudios?.allObjects ?? []).compactMap{ $0 as? NMAudio } }
 @objc public var videos: [NMVideo] { (folderedVideos?.allObjects ?? []).compactMap{ $0 as? NMVideo } }
 @objc public var photos: [NMPhoto] { (folderedPhotos?.allObjects ?? []).compactMap{ $0 as? NMPhoto } }
 @objc public var texts:  [NMText]  { (folderedTexts?.allObjects  ?? []).compactMap{ $0 as? NMText  } }
 
 @objc public var folderedElements: [NMBaseContent] {
  audios as [NMBaseContent] + videos as [NMBaseContent] +
  photos as [NMBaseContent] + texts  as [NMBaseContent]
 }
 

 
 public func addToContainer(singleElements: [NMBaseContent]) {
  
  let texts = NSSet(array: singleElements.compactMap{$0 as? NMText}
                                         .modified{$0.textSnippet = nil; $0.textFolder = nil })
  addToFolderedTexts(texts)
  mixedSnippet?.addToTexts(texts)
  
  let audios = NSSet(array: singleElements.compactMap{$0 as? NMAudio}
                                          .modified{$0.audioSnippet = nil; $0.audioFolder = nil })
  addToFolderedAudios(audios)
  mixedSnippet?.addToAudios(audios)
  
  let videos = NSSet(array: singleElements.compactMap{$0 as? NMVideo}
                                          .modified{$0.videoSnippet = nil; $0.videoFolder = nil })
  addToFolderedVideos(videos)
  mixedSnippet?.addToVideos(videos)
  
  let photos = NSSet(array: singleElements.compactMap{$0 as? NMPhoto}
                                          .modified{$0.photoSnippet = nil; $0.photoFolder = nil })
  addToFolderedPhotos(photos)
  mixedSnippet?.addToPhotos(photos)
  
 }

 public func removeFromContainer(singleElements: [NMBaseContent]) {
  removeFromFolderedTexts( .init(array: singleElements.compactMap{$0 as? NMText}))
  removeFromFolderedAudios(.init(array: singleElements.compactMap{$0 as? NMAudio}))
  removeFromFolderedVideos(.init(array: singleElements.compactMap{$0 as? NMVideo}))
  removeFromFolderedPhotos(.init(array: singleElements.compactMap{$0 as? NMPhoto}))
 }
 
 
}

//
//  NMMixedSnippet+CoreDataClass.swift
//  NewsmanCoreDataModel
//
//  Created by Anton2016 on 06.01.2022.
//
//

import Foundation
import CoreData

@available(iOS 13.0, *)
@objc(NMMixedSnippet) public class NMMixedSnippet: NMBaseSnippet {}

extension NMMixedSnippet: NMUndoManageable{}

@available(iOS 15.0, macOS 12.0, *)
extension NMMixedSnippet: NMFileStorageManageable {
 public var unfolderedAsync: [Element]? {
  get async { await managedObjectContext?.perform { self.unfolderedContentElements } }
 }
 
 public var foldersAsync: [Folder]? {
  get async { await managedObjectContext?.perform { self.folders } }
 }
 
 public func fileManagerFoldersTaskGroup() async throws {
  try await withThrowingTaskGroup(of: Void.self, returning: Void.self) { group in
   
   await foldersAsync?.forEach{ folder in
    group.addTask { try await folder.fileManagerTask?.value }
   }
   
   try await group.waitForAll()
  }
 }
 
 public func fileManagerUnfolderedTaskGroup() async throws {
  try await withThrowingTaskGroup(of: Void.self, returning: Void.self) { group in
   
   await unfolderedAsync?.forEach{ element in
    group.addTask { try await element.fileManagerTask?.value }
   }
   
   try await group.waitForAll()
  }
 }
 
 public func fileManagerChildrenTaskGroup() async throws {
  try await fileManagerFoldersTaskGroup()
  try await fileManagerUnfolderedTaskGroup()
 }
 
 public func fileManagerTaskGroup() async throws {
  try await fileManagerTask?.value
  try await fileManagerChildrenTaskGroup()
 }
 
 
}

extension NMMixedSnippet: NMContentElementsContainer  {
 
 public typealias Element = NMBaseContent
 public typealias Folder = NMBaseContent
 
 public var audioElementsFolders: [NMAudioFolder] { (audioFolders?.allObjects ?? []).compactMap{ $0 as? _ } }
 public var videoElementsFolders: [NMVideoFolder] { (videoFolders?.allObjects ?? []).compactMap{ $0 as? _ } }
 public var photoElementsFolders: [NMPhotoFolder] { (photoFolders?.allObjects ?? []).compactMap{ $0 as? _ } }
 public var textElementsFolders:  [NMTextFolder ] { (textFolders?.allObjects  ?? []).compactMap{ $0 as? _ } }
 public var mixedElementsFolders: [NMMixedFolder] { (mixedFolders?.allObjects ?? []).compactMap{ $0 as? _ } }
 
 public var folders: [NMBaseContent] {
  audioElementsFolders as [NMBaseContent] +
  videoElementsFolders as [NMBaseContent] +
  photoElementsFolders as [NMBaseContent] +
  textElementsFolders as [NMBaseContent] +
  mixedElementsFolders as [NMBaseContent]
 }
 
 public var audioElements: [NMAudio] { (audios?.allObjects ?? []).compactMap{ $0 as? _ } }
 public var videoElements: [NMVideo] { (videos?.allObjects ?? []).compactMap{ $0 as? _ } }
 public var photoElements: [NMPhoto] { (photos?.allObjects ?? []).compactMap{ $0 as? _ } }
 public var textsElements: [NMText]  { (texts?.allObjects  ?? []).compactMap{ $0 as? _  } }
 
 
 public var singleContentElements: [NMBaseContent] {
  audioElements as [_ ] + videoElements as [_ ] +
  photoElements as [_ ] + textsElements as [_ ]
 }
 
 public var folderedContentElements: [NMBaseContent] {
  audioElements.filter{ $0.isFoldered } as [NMBaseContent ] +
  videoElements.filter{ $0.isFoldered } as [NMBaseContent ] +
  photoElements.filter{ $0.isFoldered } as [NMBaseContent ] +
  textsElements.filter{ $0.isFoldered } as [NMBaseContent ]
 }
 
 public var unfolderedContentElements: [NMBaseContent] {
  audioElements.filter{ !$0.isFoldered } as [NMBaseContent ] +
  videoElements.filter{ !$0.isFoldered } as [NMBaseContent ] +
  photoElements.filter{ !$0.isFoldered } as [NMBaseContent ] +
  textsElements.filter{ !$0.isFoldered } as [NMBaseContent ]
 }
 
 public func addToContainer(singleElements: [NMBaseContent]) {
  addToTexts (.init(array: singleElements.compactMap{$0 as? NMText }.modified{$0.textSnippet  = nil } ))
  addToAudios(.init(array: singleElements.compactMap{$0 as? NMAudio}.modified{$0.audioSnippet = nil } ))
  addToVideos(.init(array: singleElements.compactMap{$0 as? NMVideo}.modified{$0.videoSnippet = nil } ))
  addToPhotos(.init(array: singleElements.compactMap{$0 as? NMPhoto}.modified{$0.photoSnippet = nil } ))
 }
 
 
 public func removeFromContainer(singleElements: [NMBaseContent]) {
  removeFromTexts (.init(array: singleElements.compactMap{$0 as? NMText}))
  removeFromAudios(.init(array: singleElements.compactMap{$0 as? NMAudio}))
  removeFromVideos(.init(array: singleElements.compactMap{$0 as? NMVideo}))
  removeFromPhotos(.init(array: singleElements.compactMap{$0 as? NMPhoto}))
 }
 
 
 public func addToContainer(folders: [NMBaseContent]) {
  
  let photoFolders = folders.compactMap{ $0 as? NMPhotoFolder }
  addToPhotoFolders(.init(array: photoFolders))
  let allPhotoFoldered = photoFolders.flatMap{ $0.folderedElements }
  addToContainer(singleElements: allPhotoFoldered)
  
  let textFolders = folders.compactMap{ $0 as? NMTextFolder}
  addToTextFolders (.init(array: textFolders ))
  let allTextFoldered = textFolders.flatMap{ $0.folderedElements }
  addToContainer(singleElements: allTextFoldered)
  
  let audioFolders = folders.compactMap{ $0 as? NMAudioFolder }
  addToAudioFolders(.init(array: audioFolders))
  let allAudioFoldered = audioFolders.flatMap{ $0.folderedElements }
  addToContainer(singleElements: allAudioFoldered)
  
  let videoFolders = folders.compactMap{ $0 as? NMVideoFolder }
  addToVideoFolders(.init(array: videoFolders))
  let allVideoFoldered = videoFolders.flatMap{ $0.folderedElements }
  addToContainer(singleElements: allVideoFoldered)
  
  let mixedFolders = folders.compactMap{ $0 as? NMMixedFolder }
  addToMixedFolders(.init(array: mixedFolders))
  let allMixedFoldered = mixedFolders.flatMap{ $0.folderedElements }
  addToContainer(singleElements: allMixedFoldered)
  
 }
 
 public func removeFromContainer(folders: [NMBaseContent]) {
  
  let photoFolders = folders.compactMap{ $0 as? NMPhotoFolder }
  removeFromPhotoFolders(.init(array: photoFolders))
  let allPhotoFoldered = photoFolders.flatMap{ $0.folderedElements }
  removeFromContainer(singleElements: allPhotoFoldered)
  
  let textFolders = folders.compactMap{ $0 as? NMTextFolder }
  removeFromTextFolders (.init(array: textFolders ))
  let allTextFoldered = textFolders.flatMap{ $0.folderedElements }
  removeFromContainer(singleElements: allTextFoldered)
  
  let audioFolders = folders.compactMap{ $0 as? NMAudioFolder }
  removeFromAudioFolders(.init(array: audioFolders))
  let allAudioFoldered = audioFolders.flatMap{ $0.folderedElements }
  removeFromContainer(singleElements: allAudioFoldered)
  
  let videoFolders = folders.compactMap{ $0 as? NMVideoFolder }
  removeFromVideoFolders(.init(array: videoFolders))
  let allVideoFoldered = videoFolders.flatMap{ $0.folderedElements }
  removeFromContainer(singleElements: allVideoFoldered)
 
  let mixedFolders = folders.compactMap{ $0 as? NMMixedFolder }
  removeFromMixedFolders(.init(array: mixedFolders))
  let allMixedFoldered = mixedFolders.flatMap{ $0.folderedElements }
  removeFromContainer(singleElements: allMixedFoldered)
  
 }
 

}

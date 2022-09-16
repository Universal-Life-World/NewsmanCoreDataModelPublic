//
//  NMPhotoSnippet+CoreDataClass.swift
//  NewsmanCoreDataModel
//
//  Created by Anton2016 on 06.01.2022.
//
//

import Foundation
import CoreData
import Combine

@objc(NMPhotoSnippet) public class NMPhotoSnippet: NMBaseSnippet {}

@available(iOS 15.0, macOS 12.0, *)
extension NMPhotoSnippet: NMUndoManageable{}

@available(iOS 15.0, macOS 12.0, *)
extension NMPhotoSnippet: NMFileStorageManageable {
 public func fileManagerTaskGroup() async throws {
  try await fileManagerTask?.value
  try await fileManagerChildrenTaskGroup()
 }
}


extension NMPhotoSnippet: NMContentElementsContainer {
 
 public typealias Element = NMPhoto
 public typealias Folder = NMPhotoFolder
 

 public func addToContainer(singleElements: [NMPhoto]) {
  addToPhotos(.init(array: singleElements))
 }
 
 public func removeFromContainer(singleElements: [NMPhoto]) {
  removeFromPhotos(.init(array: singleElements))
 }
 
 public func addToContainer(folders: [NMPhotoFolder]) {
  addToPhotoFolders(.init(array: folders))
  addToContainer(singleElements: folders.flatMap{ $0.folderedElements } )
   //add all folders' children to this snippet container as well!
 }
 
 public func removeFromContainer(folders: [NMPhotoFolder]) {
  removeFromPhotos(.init(array: folders))
 }
 
 public var folders: [NMPhotoFolder] {
  (photoFolders?.allObjects ?? []).compactMap{ $0 as? NMPhotoFolder }
 }
 
 public var singleContentElements: [NMPhoto] {
  (photos?.allObjects ?? []).compactMap{ $0 as? NMPhoto }
 }
 
 
 
 
}


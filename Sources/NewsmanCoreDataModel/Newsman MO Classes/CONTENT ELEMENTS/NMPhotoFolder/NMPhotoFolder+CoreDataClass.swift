//
//  NMPhotoFolder+CoreDataClass.swift
//  NewsmanCoreDataModel
//
//  Created by Anton2016 on 06.01.2022.
//
//

import Foundation
import CoreData

@objc(NMPhotoFolder)
public class NMPhotoFolder: NMBaseContent {}

extension NMPhotoFolder: NMUndoManageable{}

@available(iOS 15.0, macOS 12.0, *)
extension NMPhotoFolder: NMFileStorageManageable{
 public func fileManagerTaskGroup() async throws {
  try await fileManagerTask?.value
  try await fileManagerFolderedGroup()
 }
}

extension NMPhotoFolder: NMContentFolder {

 public typealias Element = NMPhoto
 
 public typealias Snippet = NMPhotoSnippet
 
 @objc(container) public var snippet: NMPhotoSnippet? { photoSnippet }
 
 @objc public var folderedElements: [NMPhoto] {
  (folderedPhotos?.allObjects ?? []).compactMap{ $0 as? NMPhoto }
 }
 
 public func addToContainer(singleElements: [NMPhoto]) {
  let newElements: NSSet = .init(array: singleElements)
  addToFolderedPhotos(newElements)
  photoSnippet?.addToPhotos(newElements)
  mixedSnippet?.addToPhotos(newElements)
 }
 
 public func removeFromContainer(singleElements: [NMPhoto]) {
  removeFromFolderedPhotos(.init(array: singleElements))
 }
 
 
 
}





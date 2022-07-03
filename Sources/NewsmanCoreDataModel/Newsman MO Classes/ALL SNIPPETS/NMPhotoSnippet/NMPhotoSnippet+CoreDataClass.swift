//
//  NMPhotoSnippet+CoreDataClass.swift
//  NewsmanCoreDataModel
//
//  Created by Anton2016 on 06.01.2022.
//
//

import Foundation
import CoreData

@available(iOS 13.0, *)
@objc(NMPhotoSnippet)
public class NMPhotoSnippet: NMBaseSnippet {}

@available(iOS 15.0, macOS 12.0, *)
extension NMPhotoSnippet: NMFileStorageManageable{}


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


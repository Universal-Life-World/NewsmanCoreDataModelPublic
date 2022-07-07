//
//  NMPhoto+CoreDataClass.swift
//  NewsmanCoreDataModel
//
//  Created by Anton2016 on 06.01.2022.
//
//

import Foundation
import CoreData

@objc(NMPhoto)
public class NMPhoto: NMBaseContent{
 
// public override func willChangeValue(forKey key: String) {
//  super.willChangeValue(forKey: key)
//  if key == #keyPath(NMPhoto.photoSnippet) {
//   print (" FROM SNIPPET \(String(describing: photoSnippet?.id))")
//  }
// }
//
// public override func didChangeValue(forKey key: String) {
//  super.didChangeValue(forKey: key)
//  if key == #keyPath(NMPhoto.photoSnippet) {
//   print (" TO SNIPPET \(String(describing: photoSnippet?.id))")
//
//
//  }
// }
}


extension NMPhoto: NMUndoManageable{}

extension NMPhoto: NMFileStorageManageable {
 public func fileManagerTaskGroup() async throws { try await fileManagerTask?.value }
}

extension NMPhoto: NMContentElement{
 
 public typealias Snippet = NMPhotoSnippet
 public typealias Folder = NMPhotoFolder
 
 @objc(container) public var snippet: NMPhotoSnippet? { photoSnippet }
 @objc public var folder: NMPhotoFolder?   { photoFolder  }
 

 
 
}





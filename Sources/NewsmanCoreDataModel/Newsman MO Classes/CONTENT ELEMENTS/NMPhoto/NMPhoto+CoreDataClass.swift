//
//  NMPhoto+CoreDataClass.swift
//  NewsmanCoreDataModel
//
//  Created by Anton2016 on 06.01.2022.
//
//

import Foundation
import CoreData

@objc(NMPhoto) public class NMPhoto: NMBaseContent{}

extension NMPhoto: NMUndoManageable{}


@available(iOS 15.0, macOS 12.0, *)
extension NMPhoto: NMFileStorageManageable {
 public func fileManagerTaskGroup() async throws { try await fileManagerTask?.value }
}

extension NMPhoto: NMContentElement{
 
 public typealias Snippet = NMPhotoSnippet
 public typealias Folder = NMPhotoFolder
 
 @objc(container) public var snippet: NMPhotoSnippet? { photoSnippet }
 @objc public var folder: NMPhotoFolder?   { photoFolder  }
 

}






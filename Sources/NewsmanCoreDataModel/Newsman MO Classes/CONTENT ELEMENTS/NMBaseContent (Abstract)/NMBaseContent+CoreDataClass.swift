//
//  NMBaseContent+CoreDataClass.swift
//  NewsmanCoreDataModel
//
//  Created by Anton2016 on 06.01.2022.
//
//

import Foundation
import CoreData

@objc(NMBaseContent)
public class NMBaseContent: NSManagedObject {
 public override func prepareForDeletion() {
  super.prepareForDeletion()
  
  let description = String(describing: Swift.type(of: self)) + "[\(id!.uuidString)]"
  (self as? NMFileStorageManageable)?.removeFileStorage{  result in
   
   switch result {
    case .success():
     print("\(description) FILE STORAGE REMOVED SUCCESSFULLY!")
    case .failure(let error):
     print("\(description) <<<FILE STORAGE REMOVE ERROR>>> \(error.localizedDescription)")
   }
   
  }
 }
}

@available(iOS 13.0, *)
public extension NMFileStorageManageable where Self: NMContainerContained {
 var url: URL? {
  get {
   
   guard let CID = self.id else { return nil }
   guard let SID = snippetID else { return nil }
   
   let snippetURL = docFolder.appendingPathComponent(SID.uuidString)
   
   guard let FID = folderID else {
    return snippetURL.appendingPathComponent(CID.uuidString)
   }
   
   return snippetURL.appendingPathComponent(FID.uuidString).appendingPathComponent(CID.uuidString)
  }
 }
}

@available(iOS 13.0, *)
public extension NMFileStorageManageable where Self: NMSnippetContained {
 var url: URL? {
  get {
   
   guard let CID = self.id else { return nil }
   guard let SID = snippetID else { return nil }
   
   let snippetURL = docFolder.appendingPathComponent(SID.uuidString)
   
   return snippetURL.appendingPathComponent(CID.uuidString)
  }
 }
}

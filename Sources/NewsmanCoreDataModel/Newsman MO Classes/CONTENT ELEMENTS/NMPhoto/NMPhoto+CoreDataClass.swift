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
public class NMPhoto: NMBaseContent, NMContainerContained {
 public var snippetID: UUID? { photoSnippet?.id }
 public var folderID:  UUID? { photoFolder?.id  }
 

}

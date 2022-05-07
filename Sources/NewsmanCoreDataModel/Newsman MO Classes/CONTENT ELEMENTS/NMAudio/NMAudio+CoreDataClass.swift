//
//  NMAudio+CoreDataClass.swift
//  NewsmanCoreDataModel
//
//  Created by Anton2016 on 06.01.2022.
//
//

import Foundation
import CoreData

@objc(NMAudio)
public class NMAudio: NMBaseContent, NMContainerContained {
 public var snippetID: UUID? { audioSnippet?.id }
 public var folderID : UUID? { audioFolder?.id }
 
}



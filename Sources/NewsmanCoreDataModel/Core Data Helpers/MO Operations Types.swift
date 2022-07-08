import Foundation

public enum ContextOperationTypes: String
{
 case updateObject = "UPDATING MANAGED OBJECT"
 case persistObject = "PERSISTING MANAGED OBJECT"
 
 case storageCreate = "CREATING STORAGE"
 case storageDelete = "DELETING STORAGE"
 
 case move = "MOVING"
 case undoMove = "UNDOING MOVING"
 
 case removeFromContainer = "REMOVING CONTENT ELEMENT FROM ITS CONTENT CONTAINER"
 case addToContainer = "ADDING CONTENT ELEMENT TO CONTENT CONTAINER"
 
 case removeFromContainerUndoably = "REMOVING CONTENT ELEMENT FROM ITS CONTENT CONTAINER WITH UNDO/REDO TASKS"
 case addToContainerUndoably = "ADDING CONTENT ELEMENT TO CONTENT CONTAINER WITH UNDO/REDO TASKS"
 
 case moveOnDisk = "MOVING DATA FILE ON DISK"
 case undoMoveOnDisk = "UNDOING MOVING DATA FILE ON DISK"
 
 case moveInside = "MOVING INSIDE FOLDER"
 case undoMoveInside = "UNDOING MOVING INSIDE FOLDER"
 
 case folder = "FOLDERING"
 case undoFolder = "UNDOING FOLDERING"
 
 case unfolder = "UNFOLDERING"
 case undoUnfolder = "UNDOING UNFOLDERING"
 
 case autoremoveFolder = "AUTOREMOVING FOLDER"

 case refolder = "REFOLDERING"
 case undoRefolder = "UNDOING REFOLDERING"
  
 case mergeWith = "MERGING WITH"
 case undoMergeWith = "UNDOING MERGING WITH"
 
 case delete = "DELETING"
 case undoDelete = "UNDOING DELETING"
 
 case cloudMetadataUpdate = "UPDATING CLOUD RECORD METADATA"
 
 case createChildren = "CREATING CHILD CONTENT ELEMENT"
 
 case resourceFileAccess = "ACCESSING CONTENT ELEMENT FILE RESOURCE ULR"
 
}

public enum ContextEntityTypes: String {
 
 case singleContentElement = "SINGLE CONTENT ELEMENT"
 case folderContentElement = "FOLDER CONTENT ELEMENT"
 
 case snippet = "SNIPPET"
 case contentElementContainer = "CONTENT ELEMENTS CONTAINER"
 case contentFolder = "CONTENT ELEMENTS FOLDER"
 case object = "MANAGED OBJECT"
 
 case photo = "PHOTO"
 case destPhoto = "DESTINATION PHOTO"
 case sourcePhoto = "SOURCE PHOTO"
 
 case singlePhoto = "SINGLE PHOTO"
 case singlePhotoFolder = "SINGLE PHOTO FOLDER"
 
 case photoFolder = "PHOTO FOLDER"
 case destPhotoFolder = "DESTINATION PHOTO FOLDER"
 case sourcePhotoFolder = "SOURCE PHOTO FOLDER"
 
 case photoSnippet = "PHOTO SNIPPET"
 case destPhotoSnippet = "DESTINATION PHOTO SNIPPET"
 case sourcePhotoSnippet = "SOURCE PHOTO SNIPPET"
 
 case textSnippet = "TEXT SNIPPET"
 case multiple  = "MULTIPLE OBJECTS"
}

func + (operation: ContextOperationTypes, entity: ContextEntityTypes) -> String
{
 var infixClause: String
 {
  switch (operation, entity)
  {
   case (.move,         .destPhotoSnippet):    fallthrough
   case (.undoMove,     .destPhotoSnippet):    fallthrough
   
   case (.folder,       .destPhotoFolder):     fallthrough
   case (.undoFolder,   .destPhotoFolder):     fallthrough
   
   case (.refolder,     .destPhotoFolder):     fallthrough
   case (.undoRefolder, .destPhotoFolder):     fallthrough
   
   case (.undoMove,     .destPhotoFolder):     fallthrough
   case (.move,         .destPhotoFolder):     return " INTO "
   
   case (.refolder,     .sourcePhotoFolder):   fallthrough
   case (.undoRefolder, .sourcePhotoFolder):   fallthrough
   
   case (.move,         .sourcePhotoSnippet):  fallthrough
   case (.undoMove,     .sourcePhotoSnippet):  fallthrough
   
   case (.delete,       .sourcePhotoSnippet):  fallthrough
   case (.undoDelete,   .sourcePhotoSnippet):  fallthrough
   
   case (.delete,       .sourcePhotoFolder):   fallthrough
   case (.undoDelete,   .sourcePhotoFolder):   fallthrough
   
   case (.undoMove,     .sourcePhotoFolder):   fallthrough
   case (.move,         .sourcePhotoFolder):   return " FROM "
   
   default: break
  }
  return " "
 }
 
 return operation.rawValue + infixClause + entity.rawValue
}



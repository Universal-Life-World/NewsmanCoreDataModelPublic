import Foundation

public enum ContextOperationTypes: String {
 
 case JSONEncodingObject = "ENCODING MANAGED OBJECT INDO JSON"
 case JSONDecodingObject = "DECODING MANAGED OBJECT FROM JSON"
 
 case updateObject = "UPDATING MANAGED OBJECT"
 case persistObject = "PERSISTING MANAGED OBJECT"
 
 case storageCreate = "CREATING STORAGE"
 case storageDelete = "DELETING STORAGE"
 
 case gettingObjectKeyPath = "GETTING MO FIELD USING KEYPATH EXPRESSION"
 
 case gettingObjectID = "GETTING MO ID"
 case gettingObjectDTO = "GETTING MO DTO"
 case gettingSnippetID = "GETTING SNIPPET ID OF THIS CONTENT ELEMENT"
 case gettingFolderID = "GETTING FOLDER ID OF THIS CONTENT ELEMENT"
 
 case gettingSnippet = "GETTING SNIPPET OF THIS CONTENT ELEMENT"
 case gettingFolder = "GETTING FOLDER OF THIS CONTENT ELEMENT"
 
 case gettingSnippetElements = "GETTING SNIPPET CONTENT ELEMENTS"
 case gettingSnippetElementsIDs = "GETTING SNIPPET CONTENT ELEMENTS UUIDs"
 
 case gettingFolderElements = "GETTING FOLDER CONTENT ELEMENTS"
 case gettingFolderElementsIDs = "GETTING FOLDER CONTENT ELEMENTS UUIDs"
 
 
 case move = "MOVING"
 case undoMove = "UNDOING MOVING"
 
 case removeFromContainer = "REMOVING CONTENT ELEMENT FROM ITS CONTENT CONTAINER"
 case addToContainer = "ADDING CONTENT ELEMENT TO CONTENT CONTAINER"
 
 case removeFromContainerUndoably = "REMOVING CONTENT ELEMENT FROM ITS CONTENT CONTAINER WITH UNDO/REDO TASKS"
 case addToContainerUndoably = "ADDING CONTENT ELEMENT TO CONTENT CONTAINER WITH UNDO/REDO TASKS"
 case registerUndoRedo = "REGISTERING UNDO/REDO TASKS"
 case registerUndo = "REGISTERING UNDO TASK"
 case registerRedo = "REGISTERING REDO TASK"
 
 case deleteFromContextUndoably = "DELETING MO FROM CONTEXT WITH UNDO/REDO TASKS"
 
 
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
 case deleteWithRecovery = "DELETING OBJECT FROM MOC WITH RECOVERY"
 case undoDelete = "UNDOING DELETING"
 
 case cloudMetadataUpdate = "UPDATING CLOUD RECORD METADATA"
 
 case createChildren = "CREATING CHILD CONTENT ELEMENT"
 
 case resourceFileAccess = "ACCESSING CONTENT ELEMENT FILE RESOURCE ULR"
 
}

public enum ContextEntityTypes: String {
 
 case singleContentElement = "SINGLE CONTENT ELEMENT"
 case folderContentElement = "FOLDER CONTENT ELEMENT"
 
 case baseContent = "BASE ABSTRACT CONTENT ELEMENT"
 case baseSnippet = "BASE ABSTRACT SNIPPET"
 case snippet = "SNIPPET"
 case contentElementContainer = "CONTENT ELEMENTS CONTAINER (AKA SNIPPET)"
 case mixedElementsContainer = "MIXED ELEMENTS CONTENT ELEMENTS CONTAINER"
 case contentFolder = "CONTENT ELEMENTS FOLDER"
 case mixedContentFolder = "MIXED CONTENT ELEMENTS FOLDER"
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



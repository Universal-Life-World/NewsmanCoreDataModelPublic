##__Development specifications for NewsmanCoreDataModel__

(+) Create NMCoreDataModel class to manipulate all app MO types.
(+) Create new remote for this module.
(+) When data model instance is created load persistent store using specified MOM and name.

###__Update definitions of the following entities in Newsman MOM & create Swift Definition of its classes:__
__ SNIPPETS CONTAINERS__
(-) _Abstract_ base entity __NMBaseSnippet__ for content container model objects called snippets.
(-) Derived (from NMBaseSnippet) __NMPhotoSnippet__ container model for NMPhoto & NMPhotoFolder objects.  
(-) Derived (from NMBaseSnippet) __NMAudioSnippet__ container model for NMAudio & NMAudioFolder objects.  
(-) Derived (from NMBaseSnippet) __NMVideoSnippet__ container model for NMVideo & NMVideoFolder objects.  
(-) Derived (from NMBaseSnippet) __NMTextSnippet__  container model for NMText  & NMTextFolder  objects. 

__ SNIPPETS CONTENT ELEMENTS__
(-) __NMPhoto & NMPhotoFolder__ - single content element representing captured 1 photo & corresponding type of the folder.
(-) __NMAudio & NMAudioFolder__ - single content element representing recorded 1 audio & corresponding type of the folder.
(-) __NMVideo & NMVideoFolder__ - single content element representing shot 1 video & corresponding type of the folder.
(-) __NMText  & NMTextFolder__ - single content element representing 1 edited text & corresponding type of the folder.

###__Create the definitions of the following Core Data Model protocols:__
(-)__NMSnippetRepresentable__ to which all snippet classes conform!
(-)__NMSnippetContentRepresentable__ to which all internal content model classes conform!

###__Create definition of the following new entities in Newsman MOM & create Swift Definition of its classes:__
(-) Child _abstract_ entity __NMBaseContentElement__ which represents single content material of the snippet
(-)__NEWSMAN REPORTS__ Separate __NMReport__ entity representing a compiled report.
(-) Derived from NMBaseSnippet  __NMMixedSnippet__ container model for all contents types & NMMixedFolder instances.
(-) Separate __NMNewsmanProfile __entity representing a registered Newsman member.  

__NEWSMAN TASK MANAGEMENT MO CLASSES__
(-) Separate __NMTask __ entity representing a Newsman task.
(-) Separate __NMTaskGroup __ entity representing a group of child mewsman tasks grouped by the NMTopic.
(-) Separate __NMTaskBlock__ _abstract_ entity representing a unit of work within the a single NMTask.
(-) Separate __NMTextBlock__ derived entity representing a text preparation unit of work within NMTask.
(-) Separate __NMTaskTextBlock__ derived entity representing a text material preparation unit of work within NMTask.
(-) Separate __NMTaskAudioBlock__ derived entity representing a recording audio fragments unit of work within NMTask.
(-) Separate __NMTaskVideoBlock__ derived entity representing a capturing videos unit of work within NMTask.
(-) Separate __NMTaskPhotoBlock__ derived entity representing a making photos unit of work within NMTask.
(-) Separate __NMTaskReportBlock__ derived entity representing a preparation of final reports as unit of work.
(-) Separate __NMTaskBlockProgress__ entity representing the progress in each unit of work above.

__SPECIAL MO CLASSES__
(-) Separate __NMNewsmanProfile __ entity representing a registered Newsman member. 
(-) Separate __NMSubscription__ entity to search and retrieve content of interes by placing rich notifications.
(-) Separate __NMChat__ parent entity representing single chat process between 2 newsmen.
(-) Separate __NMChatElement__ child entity of NMChat reprsenting a single chat record of a chat party.

(-) Create basic tests 
(-) Create MOM for all app MO types.

##__Development specifications for NewsmanCoreDataModel__

(+) Create NMCoreDataModel class to manipulate all app MO types.
(+) Create new remote for this module.
(+) When data model instance is created load persistent store using specified MOM and name.

###__Update definitions of the following entities in Newsman MOM & create Swift Definition of its classes:__ 
(-) Abstract base entity __NMBaseSnippet__ for content container model objects called snippets.
(-) Derived (from NMBaseSnippet) __NMPhotoSnippet__ container model for NMPhoto & NMPhotoFolder objects.
(-) Derived (from NMBaseSnippet) __NMAudioSnippet__ container model for NMAudio & NMAudioFolder objects.
(-) Derived (from NMBaseSnippet) __NMVideoSnippet__ container model for NMVideo & NMVideoFolder objects.
(-) Derived (from NMBaseSnippet) __NMTextSnippet__  container model for NMText  & NMTextFolder  objects.

###__Create the definitions of the following Core Data Model protocols:__
(-)__NMSnippetRepresentable__ to which all snippet classes conform!
(-)__NMSnippetContentRepresentable__ to which all internal content model classes conform!

###__Create definition of the following new entities in Newsman MOM & create Swift Definition of its classes:__
(-) Child _abstract_ entity __NMBaseContent__ which represents single content material of the snippet. 
(-) Derived from NMBaseSnippet  __NMMixedSnippet__ container model for all contents types & NMMixedFolder instances.
(-) Separate __NMNewsman __ entity representing a registered mewsman member.  
(-) Separate __NMReport__ entity representing a compiled report.

(-) Separate __NMTask __ entity representing a mewsman task.
(-) Separate __NMTaskGroup __ entity representing a group of child mewsman tasks grouped by the NMTopic.
(-) Separate __NMTaskBlock__ _abstract_ entity representing a unit of work within the a single NMTask.
(-) Separate __NMTextBlock__ derived entity representing a text preparation unit of work within NMTask.
(-) Separate __NMTaskTextBlock__ derived entity representing a text material preparation unit of work within NMTask.
(-) Separate __NMTaskAudioBlock__ derived entity representing a recording audio fragments unit of work within NMTask.
(-) Separate __NMTaskVideoBlock__ derived entity representing a capturing videos unit of work within NMTask.
(-) Separate __NMTaskPhotoBlock__ derived entity representing a making photos unit of work within NMTask.


(-) Create basic tests 
(-) Create MOM for all app MO types.

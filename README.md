MTDataLayer
====================

This set of classes helps to work with data layer.

Intro
====================

Many of iOS (and not only iOS) projects consist of distinct layers. For example, there can be UI Layer, Controller Layer, Network Layer, Model/Data Layer and so on. MTDataLayer contains some helpful classes and categories which do boilerplate work on Model/Data Layer.

There are three pieces: **DataMapping**, **DataStore** and **MergeData**.

DataMapping
====================

**Overview**

This class maps objects of Data Layer classes to objects of Upper Layer classes and vice versa. For example, It can map instances of NSManagedObject (CoreData Layer) to PONSO (View/Presenter Layer) and vice versa.
Also I highly recommend [mogenerator](https://github.com/rentzsch/mogenerator) for this task.

**Usage**

Copy files from repository into your project and include `MTDataMapping.h`.

**Description**

`- (id)mappedObjectFromManagedObject: (NSManagedObject *)managedObject`

It presents mapped object (PONSO) from given managed object (NSManagedObject).

`- (NSDictionary*)managedObjectDictFromMappedObject: (id)mappedObject`
`                                    additionalData: (id)additionalData`
`                                        entityName: (NSString *)entityName`

It presents managed object (NSManagedObject) with given entityName and given additional data from given mapped object (PONSO).

**Example**

`- (id)mappedObjectFromManagedObject: (NSManagedObject *)managedObject`
`{`
`    if (managedObject == nil) {`

`        return nil;`
        
`    } else if ([managedObject isKindOfClass:[MTManagedCity class]]) {`
        
`        NSManagedObject *managedCountry = [managedObject valueForKey:@"country"];`
        
`        id mappedCountry = [self mappedObjectFromManagedObject:managedCountry];`
        
`        return [[MTMappedCity alloc] initWithItemId:[managedObject valueForKey:@"itemId"]`
`                                           itemName:[managedObject valueForKey:@"itemName"]`
`                                            country:mappedCountry`
`                                         population:[managedObject valueForKey:@"population"]];`
`    }`
    
`    return nil;`
`}`

`- (NSDictionary *)managedObjectDictFromMappedObject:(id)mappedObject`
`                                     additionalData:(id)additionalData`
`                                         entityName:(NSString *)entityName`
`{    `
`    if ([entityName isEqualToString:@"MTManagedCity"]) {`
        
`        NSMutableDictionary* result = [[NSMutableDictionary alloc] init];`
`        MTMappedCity *mappedCity = (MTMappedCity *)mappedObject;`
        
`        if (mappedCity.itemId) {`
`            result[@"itemId"] = mappedCity.itemId;`
`        }`
        
`        if (mappedCity.itemName) {`
`            result[@"itemName"] = mappedCity.itemName;`
`        }`
      
`        if (mappedCity.population) {`
`            result[@"population"] = mappedCity.population;`
`        }`
        
`        NSManagedObject *country = (NSManagedObject *)additionalData;`
        
`        if (country != nil) {`
`            result[@"country"] = country;`
`        }`
        
`        return result;`
`    }`

    return nil;
`}`

DataStore
====================

**Overview**

This class is storage and manager of data. Now it is presented as singleton with CoreData storage. In order to change that you need to rewrite internals of class and remove `__unavailable` attribute for `init` method declaration.

Default CoreData stack is presented on the picture:

![ScreenShot](https://cloud.githubusercontent.com/assets/2142832/10045554/6029e180-6225-11e5-9edd-10dc5b8f7285.png)

There are two contexts: main and private. Main context is used for main thread (UI) and private context for background thread (all other operations). Generally kind of CoreData stack depends on app which you develop. 

**Usage**

Copy files from repository into your project and include `MTDataStore.h`.
To use methods of singleton call `[MTDataStore sharedStore]`.

**Description**

`- (void)saveContext: (NSManagedObjectContext*)context`

Save changes in given context.

`- (NSFetchRequest *)fetchRequestWithEntity: (NSString *)entityName`
`                                 predicate: (NSPredicate *)predicate`
`                         sortedDescriptors: (NSArray *)sortedDescriptors`
`                                   context: (NSManagedObjectContext *)context`

Data request with given entity, predicate, sorted descriptors, context.

`- (NSFetchRequest *)fetchRequestWithEntity: (NSString *)entityName`
`                                 predicate: (NSPredicate *)predicate`
`                         sortedDescriptors: (NSArray *)sortedDescriptors`
`                         propertiesToFetch: (NSArray *)propertiesToFetch`
`                       includesSubentities: (BOOL)includesSubentities`
`                    returnsObjectsAsFaults: (BOOL)returnsObjectsAsFaults`
`                    includesPendingChanges: (BOOL)includesPendingChanges`
`                                   context: (NSManagedObjectContext *)context`

Data request with given entity, predicate, sorted descriptors, properties, context and include/not include subentities, return objects as faults or not, include pending changes or not include.

`- (NSArray *)objectsForEntity: (NSString *)entityName`
`                    predicate: (NSPredicate *)predicate`
`            sortedDescriptors: (NSArray *)sortedDescriptors`
`                      context: (NSManagedObjectContext *)context`

Get objects with given entity, predicate, sorted descriptors, context.

`- (NSArray *)objectsForEntity: (NSString *)entityName`
`                    predicate: (NSPredicate *)predicate`
`            sortedDescriptors: (NSArray *)sortedDescriptors`
`            propertiesToFetch: (NSArray *)propertiesToFetch`
`          includesSubentities: (BOOL)includesSubentities`
`       returnsObjectsAsFaults: (BOOL)returnsObjectsAsFaults`
`       includesPendingChanges: (BOOL)includesPendingChanges`
`                      context: (NSManagedObjectContext *)context`

Get objects with given entity, predicate, sorted descriptors, properties, context and include/not include subentities, return objects as faults or not, include pending changes or not include.

`- (id)objectForEntity: (NSString *)entityName`
`            predicate: (NSPredicate *)predicate`
`    sortedDescriptors: (NSArray *)sortedDescriptors`
`              context: (NSManagedObjectContext *)context`

Get object with given entity, predicate, sorted descriptors, context.

`- (id)objectForEntity: (NSString *)entityName`
`            predicate: (NSPredicate *)predicate`
`    sortedDescriptors: (NSArray *)sortedDescriptors`
`    propertiesToFetch: (NSArray *)propertiesToFetch`
`  includesSubentities: (BOOL)includesSubentities`
`returnsObjectsAsFaults: (BOOL)returnsObjectsAsFaults`
`includesPendingChanges: (BOOL)includesPendingChanges`
`              context: (NSManagedObjectContext *)context`

Get object with given entity, predicate, sorted descriptors, properties, context and include/not include subentities, return objects as faults or not, include pending changes or not include.

`- (NSUInteger)countOfObjectsForEntity: (NSString *)entityName`
`                            predicate: (NSPredicate *)predicate`
`                    sortedDescriptors: (NSArray *)sortedDescriptors`
`                              context: (NSManagedObjectContext *)context`

Get count of objects with given entity, predicate, sorted descriptors, context.

`- (NSUInteger)countOfObjectsForEntity: (NSString *)entityName`
`                            predicate: (NSPredicate *)predicate`
`                    sortedDescriptors: (NSArray *)sortedDescriptors`
`                    propertiesToFetch: (NSArray *)propertiesToFetch`
`                  includesSubentities: (BOOL)includesSubentities`
`               returnsObjectsAsFaults: (BOOL)returnsObjectsAsFaults`
`               includesPendingChanges: (BOOL)includesPendingChanges`
`                              context: (NSManagedObjectContext *)context`

Get count of objects with given entity, predicate, sorted descriptors, properties, context and include/not include subentities, return objects as faults or not, include pending changes or not include.

`- (void)deleteObject: (NSManagedObject *)object`
`             context: (NSManagedObjectContext *)context`

Delete given object in given context.

MergeData
====================

**Overview**

NSObject+MTMergeObject and NSObject+MTMergeObjects categories help to merge data between old objects (for example, data storage) and new objects (for example, objects which be downloaded from server). 
'To merge' means:
- insert new objects to data storage (if they were not among old objects);
- update old objects in data store (if they are among new objects);
- delete old objects (if they were not among new objects);

**Usage**

Copy files from repository into your project and include `NSObject+MTMergeObjects.h` or `NSObject+MTMergeObject.h`.

**Description**

*NSObject+MTMergeObjects.h*

`- (BOOL)mt_mergeObjects: (NSArray *)objects`
`         idPropertyName: (NSString *)idPropertyName`
`                 entity: (NSString *)entityName`
`         additionalData: (id)additionalData`
`              predicate: (NSPredicate *)predicate`
`                context: (NSManagedObjectContext *)context`
`                  error: (NSError * __autoreleasing *)error`

Merge given new objects with id property name, entity, additional data (used in MTDataMapping), predicate, context and error handler.

`- (BOOL)mt_mergeObjects: (NSArray *)objects`
`         idPropertyName: (NSString *)idPropertyName`
`                 entity: (NSString *)entityName`
`         additionalData: (id)additionalData`
`              predicate: (NSPredicate *)predicate`
`           mergeChanges: (BOOL)mergeChanges`
`                context: (NSManagedObjectContext *)context`
`                  error: (NSError * __autoreleasing *)error`

Merge given new objects with id property name, entity, additional data (used in MTDataMapping), predicate, merge changes flag, context and error handler.

`- (NSSet *)mt_idsOfObjectsForDeleteWithOldObjectsIds: (NSSet *)oldObjectsIds`
`                                       newObjectsIds: (NSSet *)newObjectsIds`

Get a set of identifiers of old objects, which were not among new objects.

`- (NSSet *)mt_idsOfObjectsForUpdateWithOldObjectsIds: (NSSet *)oldObjectsIds`
`                                       newObjectsIds: (NSSet *)newObjectsIds`

Get a set of identifiers of old objects, which were among new objects.

`- (NSSet *)mt_idsOfObjectsForInsertWithOldObjectsIds: (NSSet *)oldObjectsIds`
`                                       newObjectsIds: (NSSet *)newObjectsIds`

Get a set of identifiers of new objects, which were not among old objects.

`- (void)mt_deleteObjectsWithIds: (NSSet *)idsOfObjectsForDelete`
`                 idPropertyName: (NSString *)idPropertyName`
`                     entityName: (NSString *)entityName`
`                        context: (NSManagedObjectContext *)context`

Delete old objects with given set of identifiers, id property name, entity name, context.

`- (void)mt_updateObjectsWithIds: (NSSet *)idsOfObjectsForUpdate`
`                     newObjects: (NSArray *)newObjects`
`                 additionalData: (id)additionalData`
`                 idPropertyName: (NSString *)idPropertyName`
`                     entityName: (NSString *)entityName`
`                        context: (NSManagedObjectContext *)context`

Update old objects with given set of identifiers, new objects (which were among old objects), additional data (used in MTDataMapping), id property name, entity name, context.           
                        
`- (void)mt_insertObjectsWithIds: (NSSet *)idsOfObjectsForInsert`
`                     newObjects: (NSArray *)newObjects`
`                 additionalData: (id)additionalData`
`                 idPropertyName: (NSString *)idPropertyName`
`                     entityName: (NSString *)entityName`
`                        context: (NSManagedObjectContext *)context`

Insert new objects to data storage with given set of identifiers, new objects (which were not among old objects), additional data (used in MTDataMapping), id property name, entity name, context.

*NSObject+MTMergeObject.h*

`- (BOOL)mt_mergeObjectWithEntity: (NSString *)entityName`
`                    mappedObject: (id)mappedObject`
`                  additionalData: (id)additionalData`
`                       predicate: (NSPredicate *)predicate`
`                    mergeChanges: (BOOL)mergeChanges`
`                         context: (NSManagedObjectContext *)context`
`                           error: (NSError * __autoreleasing *)error`

Merge given mapped object with entity name, additional data (used in MTDataMapping), predicate, merge changes flag, context and error handler.

`- (BOOL)mt_mergeObjectWithEntity: (NSString *)entityName`
`                    mappedObject: (id)mappedObject`
`                  additionalData: (id)additionalData`
`                       predicate: (NSPredicate *)predicate`
`                         context: (NSManagedObjectContext *)context`
`                           error: (NSError * __autoreleasing *)error`

Merge given mapped object with entity name, additional data (used in MTDataMapping), predicate, context and error handler.

`- (void)mt_updateObject: (NSManagedObject *)object`
`           mappedObject: (id)mappedObject`
`         additionalData: (id)additionalData`
`                 entity: (NSString *)entityName`
`           mergeChanges: (BOOL)mergeChanges`
`                context: (NSManagedObjectContext *)context`

Update given managed object with mapped object, entity name, additional data (used in MTDataMapping), merge changes flag and context.

`- (void)mt_insertObjectWithMappedObject: (id)mappedObject`
`                         additionalData: (id)additionalData`
`                                 entity: (NSString*)entityName`
`                                context: (NSManagedObjectContext*)context`

Insert given mapped object with entity name, additional data (used in MTDataMapping) and context.

Demo
====================

These clasess are used in [this demo app](https://github.com/maxxx777/MTVIPERDemoApp).

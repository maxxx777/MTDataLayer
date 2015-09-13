//
//  MTDataStore.h
//
//  Created by MAXIM TSVETKOV on 03.12.14.
//

#import "MTDataStoreConstants.h"

@interface MTDataStore : NSObject

@property (nonatomic, strong, readonly) NSManagedObjectModel *managedObjectModel;
@property (nonatomic, strong, readonly) NSPersistentStoreCoordinator *persistentStoreCoordinator;
@property (strong, nonatomic, readonly) NSManagedObjectContext *mainQueueContext;
@property (strong, nonatomic, readonly) NSManagedObjectContext *privateQueueContext;

- (instancetype) __unavailable init;

+ (MTDataStore *)sharedStore;

- (void)saveContext: (NSManagedObjectContext*)context;

- (NSFetchRequest *)fetchRequestWithEntity: (NSString *)entityName
                                 predicate: (NSPredicate *)predicate
                         sortedDescriptors: (NSArray *)sortedDescriptors
                                   context: (NSManagedObjectContext *)context;
- (NSFetchRequest *)fetchRequestWithEntity: (NSString *)entityName
                                 predicate: (NSPredicate *)predicate
                         sortedDescriptors: (NSArray *)sortedDescriptors
                         propertiesToFetch: (NSArray *)propertiesToFetch
                       includesSubentities: (BOOL)includesSubentities
                    returnsObjectsAsFaults: (BOOL)returnsObjectsAsFaults
                    includesPendingChanges: (BOOL)includesPendingChanges
                                   context: (NSManagedObjectContext *)context;
- (NSArray *)objectsForEntity: (NSString *)entityName
                    predicate: (NSPredicate *)predicate
            sortedDescriptors: (NSArray *)sortedDescriptors
                      context: (NSManagedObjectContext *)context;
- (NSArray *)objectsForEntity: (NSString *)entityName
                    predicate: (NSPredicate *)predicate
            sortedDescriptors: (NSArray *)sortedDescriptors
            propertiesToFetch: (NSArray *)propertiesToFetch
          includesSubentities: (BOOL)includesSubentities
       returnsObjectsAsFaults: (BOOL)returnsObjectsAsFaults
       includesPendingChanges: (BOOL)includesPendingChanges
                      context: (NSManagedObjectContext *)context;
- (id)objectForEntity: (NSString *)entityName
            predicate: (NSPredicate *)predicate
    sortedDescriptors: (NSArray *)sortedDescriptors
              context: (NSManagedObjectContext *)context;
- (id)objectForEntity: (NSString *)entityName
            predicate: (NSPredicate *)predicate
    sortedDescriptors: (NSArray *)sortedDescriptors
    propertiesToFetch: (NSArray *)propertiesToFetch
  includesSubentities: (BOOL)includesSubentities
returnsObjectsAsFaults: (BOOL)returnsObjectsAsFaults
includesPendingChanges: (BOOL)includesPendingChanges
              context: (NSManagedObjectContext *)context;
- (NSUInteger)countOfObjectsForEntity: (NSString *)entityName
                            predicate: (NSPredicate *)predicate
                    sortedDescriptors: (NSArray *)sortedDescriptors
                              context: (NSManagedObjectContext *)context;
- (NSUInteger)countOfObjectsForEntity: (NSString *)entityName
                            predicate: (NSPredicate *)predicate
                    sortedDescriptors: (NSArray *)sortedDescriptors
                    propertiesToFetch: (NSArray *)propertiesToFetch
                  includesSubentities: (BOOL)includesSubentities
               returnsObjectsAsFaults: (BOOL)returnsObjectsAsFaults
               includesPendingChanges: (BOOL)includesPendingChanges
                              context: (NSManagedObjectContext *)context;
- (void)deleteObject: (NSManagedObject *)object
             context: (NSManagedObjectContext *)context;

@end

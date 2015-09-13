//
//  MTDataStore.m
//
//  Created by MAXIM TSVETKOV on 03.12.14.
//

#import "MTDataStore.h"

@implementation MTDataStore
@synthesize managedObjectModel = _managedObjectModel;
@synthesize persistentStoreCoordinator = _persistentStoreCoordinator;
@synthesize mainQueueContext = _mainQueueContext;
@synthesize privateQueueContext = _privateQueueContext;

+ (MTDataStore*)sharedStore
{
    static id sharedInstance;
    static dispatch_once_t once;
    dispatch_once(&once, ^{
        sharedInstance = [[self alloc] init];
    });
    return sharedInstance;
}

#pragma mark - Lifecycle

- (instancetype)init
{
    self = [super init];
    if (self) {
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(contextDidSavePrivateQueueContext:)name:NSManagedObjectContextDidSaveNotification object:[self privateQueueContext]];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(contextDidSaveMainQueueContext:) name:NSManagedObjectContextDidSaveNotification object:[self mainQueueContext]];
    }
    return self;
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    
    DLog(@"%@ deallocated: %p", NSStringFromClass([self class]), self);
}

- (void)saveContext: (NSManagedObjectContext*)context
{
    NSError *error = nil;
    NSManagedObjectContext *managedObjectContext = context;
    if (managedObjectContext != nil) {
        if ([managedObjectContext hasChanges] && ![managedObjectContext save:&error]) {
            // Replace this implementation with code to handle the error appropriately.
            // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
            DLog(@"%@", error);
            abort();
        }
    }
}

#pragma mark - Notifications

- (void)contextDidSavePrivateQueueContext:(NSNotification *)notification
{
    @synchronized(self) {
        [self.mainQueueContext performBlock:^{
            [self.mainQueueContext mergeChangesFromContextDidSaveNotification:notification];
        }];
    }
}

- (void)contextDidSaveMainQueueContext:(NSNotification *)notification
{
    @synchronized(self) {
        [self.privateQueueContext performBlock:^{
            [self.privateQueueContext mergeChangesFromContextDidSaveNotification:notification];
        }];
    }
}

#pragma mark - Core Data stack

- (NSManagedObjectContext *)mainQueueContext
{
    if (_mainQueueContext != nil) {
        return _mainQueueContext;
    }
    
    NSPersistentStoreCoordinator *coordinator = [self persistentStoreCoordinator];
    if (coordinator != nil) {
        _mainQueueContext = [[NSManagedObjectContext alloc] initWithConcurrencyType:NSMainQueueConcurrencyType];
        [_mainQueueContext setPersistentStoreCoordinator:coordinator];
    }
    return _mainQueueContext;
}

- (NSManagedObjectContext *)privateQueueContext
{
    if (_privateQueueContext != nil) {
        return _privateQueueContext;
    }
    
    NSPersistentStoreCoordinator *coordinator = [self persistentStoreCoordinator];
    if (coordinator != nil) {
        _privateQueueContext = [[NSManagedObjectContext alloc] initWithConcurrencyType:NSPrivateQueueConcurrencyType];
        [_privateQueueContext setPersistentStoreCoordinator:coordinator];
    }
    return _privateQueueContext;
}

// Returns the managed object model for the application.
// If the model doesn't already exist, it is created from the application's model.
- (NSManagedObjectModel *)managedObjectModel
{
    if (_managedObjectModel != nil) {
        return _managedObjectModel;
    }
    NSURL *modelURL = [[NSBundle mainBundle] URLForResource:MTDataStoreModelFileName withExtension:@"momd"];
    _managedObjectModel = [[NSManagedObjectModel alloc] initWithContentsOfURL:modelURL];
    return _managedObjectModel;
}

// Returns the persistent store coordinator for the application.
// If the coordinator doesn't already exist, it is created and the application's store added to it.
- (NSPersistentStoreCoordinator *)persistentStoreCoordinator {
    if (_persistentStoreCoordinator != nil) {
        return _persistentStoreCoordinator;
    }
    
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = paths[0];
    NSString *storePath = [documentsDirectory stringByAppendingPathComponent:MTDataStoreSQLiteFileName];
    
    NSURL* storeUrl = [NSURL fileURLWithPath:storePath];
    
//    DLog(@"store URL %@", storeUrl);
    
    NSError *error = nil;
    _persistentStoreCoordinator = [[NSPersistentStoreCoordinator alloc]
                                   initWithManagedObjectModel:[self managedObjectModel]];
    
    NSDictionary *options = @{
                              NSMigratePersistentStoresAutomaticallyOption : @YES,
                              NSInferMappingModelAutomaticallyOption : @YES
                              };
    
    if(![_persistentStoreCoordinator addPersistentStoreWithType:NSSQLiteStoreType
                                                  configuration:nil URL:storeUrl options:options error:&error]) {
        /*Error for store creation should be handled in here*/
    }
    
    return _persistentStoreCoordinator;
}

#pragma mark - Fetch Request

- (NSFetchRequest *)fetchRequestWithEntity: (NSString *)entityName
                                 predicate: (NSPredicate *)predicate
                         sortedDescriptors: (NSArray *)sortedDescriptors
                                   context: (NSManagedObjectContext *)context
{
    return [self fetchRequestWithEntity:entityName
                              predicate:predicate
                      sortedDescriptors:sortedDescriptors
                      propertiesToFetch:nil
                    includesSubentities:YES
                 returnsObjectsAsFaults:NO
                 includesPendingChanges:YES
                                context:context];
}

- (NSFetchRequest *)fetchRequestWithEntity: (NSString *)entityName
                                 predicate: (NSPredicate *)predicate
                         sortedDescriptors: (NSArray *)sortedDescriptors
                         propertiesToFetch: (NSArray *)propertiesToFetch
                       includesSubentities: (BOOL)includesSubentities
                    returnsObjectsAsFaults: (BOOL)returnsObjectsAsFaults
                    includesPendingChanges: (BOOL)includesPendingChanges
                                   context: (NSManagedObjectContext *)context
{
    NSEntityDescription *entityDesc = [NSEntityDescription entityForName:entityName inManagedObjectContext:context];
    
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    [request setEntity:entityDesc];
    
    if (predicate != nil) {
        [request setPredicate:predicate];
    }
    
    if (sortedDescriptors != nil) {
        [request setSortDescriptors:sortedDescriptors];
    }
    
    if (propertiesToFetch != nil) {
        request.propertiesToFetch = propertiesToFetch;
        [request setReturnsDistinctResults:YES];
        [request setResultType:NSDictionaryResultType];
    }
    
    [request setIncludesSubentities:includesSubentities];
    [request setReturnsObjectsAsFaults:returnsObjectsAsFaults];
    [request setIncludesPendingChanges:includesPendingChanges];
    
    return request;
}

- (NSArray *)objectsForEntity: (NSString*)entityName
                    predicate: (NSPredicate*)predicate
            sortedDescriptors: (NSArray*)sortedDescriptors
                      context: (NSManagedObjectContext*)context
{
    return [self objectsForEntity:entityName
                        predicate:predicate
                sortedDescriptors:sortedDescriptors
                propertiesToFetch:nil
              includesSubentities:YES
           returnsObjectsAsFaults:NO
           includesPendingChanges:YES
                          context:context];
}

- (NSArray *)objectsForEntity: (NSString*)entityName
                    predicate: (NSPredicate*)predicate
            sortedDescriptors: (NSArray*)sortedDescriptors
            propertiesToFetch: (NSArray*)propertiesToFetch
          includesSubentities: (BOOL)includesSubentities
       returnsObjectsAsFaults: (BOOL)returnsObjectsAsFaults
       includesPendingChanges: (BOOL)includesPendingChanges
                      context: (NSManagedObjectContext*)context
{
    NSFetchRequest* fetchRequest = [self fetchRequestWithEntity:entityName
                                                      predicate:predicate
                                              sortedDescriptors:sortedDescriptors
                                              propertiesToFetch:propertiesToFetch
                                            includesSubentities:includesSubentities
                                         returnsObjectsAsFaults:returnsObjectsAsFaults
                                         includesPendingChanges:includesPendingChanges
                                                        context:context];
    NSError *error;
    NSArray *objects = [context executeFetchRequest:fetchRequest error:&error];
    
    return objects;
}

- (id)objectForEntity: (NSString*)entityName
            predicate: (NSPredicate*)predicate
    sortedDescriptors: (NSArray*)sortedDescriptors
              context: (NSManagedObjectContext*)context
{
    return [self objectForEntity:entityName
                       predicate:predicate
               sortedDescriptors:sortedDescriptors
               propertiesToFetch:nil
             includesSubentities:YES
          returnsObjectsAsFaults:YES
          includesPendingChanges:YES
                         context:context];
}

- (id)objectForEntity: (NSString*)entityName
            predicate: (NSPredicate*)predicate
    sortedDescriptors: (NSArray*)sortedDescriptors
    propertiesToFetch: (NSArray*)propertiesToFetch
  includesSubentities: (BOOL)includesSubentities
returnsObjectsAsFaults: (BOOL)returnsObjectsAsFaults
includesPendingChanges: (BOOL)includesPendingChanges
              context: (NSManagedObjectContext*)context
{
    NSArray *objects = [self objectsForEntity:entityName
                                    predicate:predicate
                            sortedDescriptors:sortedDescriptors
                            propertiesToFetch:propertiesToFetch
                          includesSubentities:includesSubentities
                       returnsObjectsAsFaults:returnsObjectsAsFaults
                       includesPendingChanges:includesPendingChanges
                                      context:context];
    
    return [objects lastObject];
}

- (NSUInteger)countOfObjectsForEntity: (NSString*)entityName
                            predicate: (NSPredicate*)predicate
                    sortedDescriptors: (NSArray*)sortedDescriptors
                    propertiesToFetch: (NSArray*)propertiesToFetch
                  includesSubentities: (BOOL)includesSubentities
               returnsObjectsAsFaults: (BOOL)returnsObjectsAsFaults
               includesPendingChanges: (BOOL)includesPendingChanges
                              context: (NSManagedObjectContext*)context
{
    NSArray *objects = [self objectsForEntity:entityName
                                    predicate:predicate
                            sortedDescriptors:sortedDescriptors
                            propertiesToFetch:propertiesToFetch
                          includesSubentities:includesSubentities
                       returnsObjectsAsFaults:returnsObjectsAsFaults
                       includesPendingChanges:includesPendingChanges
                                      context:context];
    return objects.count;
}

- (NSUInteger)countOfObjectsForEntity: (NSString*)entityName
                            predicate: (NSPredicate*)predicate
                    sortedDescriptors: (NSArray*)sortedDescriptors
                              context: (NSManagedObjectContext*)context
{
    return [self countOfObjectsForEntity:entityName
                               predicate:predicate
                       sortedDescriptors:sortedDescriptors
                       propertiesToFetch:nil
                     includesSubentities:YES
                  returnsObjectsAsFaults:NO
                  includesPendingChanges:YES
                                 context:context];
}

- (void)deleteObject: (NSManagedObject*)object
             context: (NSManagedObjectContext*)context
{
    [context deleteObject:object];
}

@end

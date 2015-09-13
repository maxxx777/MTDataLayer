//
//  NSObject+MTMergeObject.h
//  VIPERDemoApp
//
//  Created by MAXIM TSVETKOV on 06.09.15.
//  Copyright (c) 2015 MAXIM TSVETKOV. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSObject (MTMergeObject)

- (BOOL)mt_mergeObjectWithEntity: (NSString *)entityName
                    mappedObject: (id)mappedObject
                  additionalData: (id)additionalData
                       predicate: (NSPredicate *)predicate
                    mergeChanges: (BOOL)mergeChanges
                         context: (NSManagedObjectContext *)context
                           error: (NSError * __autoreleasing *)error;
- (BOOL)mt_mergeObjectWithEntity: (NSString *)entityName
                    mappedObject: (id)mappedObject
                  additionalData: (id)additionalData
                       predicate: (NSPredicate *)predicate
                         context: (NSManagedObjectContext *)context
                           error: (NSError * __autoreleasing *)error;
- (void)mt_updateObject: (NSManagedObject *)object
           mappedObject: (id)mappedObject
         additionalData: (id)additionalData
                 entity: (NSString *)entityName
           mergeChanges: (BOOL)mergeChanges
                context: (NSManagedObjectContext *)context;
- (void)mt_insertObjectWithMappedObject: (id)mappedObject
                         additionalData: (id)additionalData
                                 entity: (NSString*)entityName
                                context: (NSManagedObjectContext*)context;

@end

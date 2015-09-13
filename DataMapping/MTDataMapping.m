//
//  MTDataMapping.m
//
//  Created by MAXIM TSVETKOV on 28.08.15.
//

#import "MTDataMapping.h"

@implementation MTDataMapping

- (id)mappedObjectFromManagedObject: (NSManagedObject *)managedObject
{
    if (managedObject == nil) {
        return nil;
    }
    
    return nil;
}

- (NSDictionary *)managedObjectDictFromMappedObject:(id)mappedObject
                                     additionalData:(id)additionalData
                                         entityName:(NSString *)entityName
{    
    return nil;
}

@end

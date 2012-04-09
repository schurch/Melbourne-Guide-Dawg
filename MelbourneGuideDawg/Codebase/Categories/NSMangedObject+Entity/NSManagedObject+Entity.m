//
//  NSManagedObject+Entity.m
//  Sky
//
//  Created by Stefan Church on 27/03/2012.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "NSManagedObject+Entity.h"

@implementation NSManagedObject (Entity)

#pragma mark - Class methods -

+ (NSString *)entityName
{
    return NSStringFromClass([self class]);
}

+ (id)entityWithContext:(NSManagedObjectContext *)context
{
    return [NSEntityDescription insertNewObjectForEntityForName:[[self class] entityName] inManagedObjectContext:context];   
}

#pragma mark - Methods -

- (void)remove
{
    NSLog(@"NSManagedObject :: Deleteing entity (%@)", [[self class] entityName]);
    
    NSError *error = nil;
    
    [self.managedObjectContext deleteObject:self];
    [self.managedObjectContext save:nil];
    
    if (error != nil) {
        NSLog(@"Unresolved error when deleting entity: %@, %@", error, [error userInfo]);
#if DEBUG
        abort();
#endif
    }
}

@end

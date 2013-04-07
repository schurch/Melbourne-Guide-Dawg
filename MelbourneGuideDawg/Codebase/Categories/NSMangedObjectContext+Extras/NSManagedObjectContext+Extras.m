//
//  NSManagedObjectContext+Extras.m
//  Travel
//
//  Created by Stefan Church on 02/03/2012.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "NSManagedObjectContext+Extras.h"

@implementation NSManagedObjectContext (Extras)

static NSManagedObjectContext *managedObjectContext = nil;

+ (NSManagedObjectContext *)sharedInstance 
{
    @synchronized(self) 
    {
        if (!managedObjectContext) 
        {
            NSError *error = nil;
            
            NSURL *modelURL = [[NSBundle mainBundle] URLForResource:@"Model" withExtension:@"momd"];
            NSManagedObjectModel *managedObjectModel = [[NSManagedObjectModel alloc] initWithContentsOfURL:modelURL];
            
            NSPersistentStoreCoordinator *persistentStoreCoordinator;
            NSURL *storeURL = [self storeURL];
            persistentStoreCoordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:managedObjectModel];
            
            if (![persistentStoreCoordinator addPersistentStoreWithType:NSSQLiteStoreType configuration:nil URL:storeURL options:nil error:&error])
            {
                NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
#if DEBUG
                abort();
#endif
            }
            
            managedObjectContext = [[NSManagedObjectContext alloc] init];
            [managedObjectContext setPersistentStoreCoordinator:persistentStoreCoordinator];
        }
        
        return managedObjectContext;
    }
}

+ (NSURL *)storeURL
{
    NSURL *URL = [[Utils downloadDirectory] URLByAppendingPathComponent:@"Model.sqlite"];
    [Utils excludeURLPathFromBackup:URL];
    return URL;
}

- (void)save
{
    NSLog(@"NSMangedObjectConext :: Saving conext changes..");
    
    NSError* error;
    if(![self save:&error]) {
        NSLog(@"Failed to save to data store: %@", [error localizedDescription]);
        NSArray* detailedErrors = [[error userInfo] objectForKey:NSDetailedErrorsKey];
        if(detailedErrors != nil && [detailedErrors count] > 0) {
            for(NSError* detailedError in detailedErrors) {
                NSLog(@"  DetailedError: %@", [detailedError userInfo]);
            }
#if DEBUG
            abort();
#endif            
        } else {
            NSLog(@"  %@", [error userInfo]);
        }
    }
}

@end

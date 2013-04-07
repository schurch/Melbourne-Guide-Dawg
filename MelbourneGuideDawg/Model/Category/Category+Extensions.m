//
//  Category+Extensions.m
//  MelbourneGuideDawg
//
//  Created by Stefan Church on 04/03/2012.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "Category+Extensions.h"
#import "NSManagedObject+Entity.h"
#import "NSManagedObjectContext+Extras.h"
#import "Place.h"
#import "Place+Extensions.h"

@implementation Category (Extensions)

#pragma mark - Class methods -

+ (Category *)category
{
    return [self entityWithContext:[NSManagedObjectContext sharedInstance]];
}

+ (NSArray *)allCategories
{
    return [self executeRequestWithPredicate:nil];
}

+ (NSArray *)placeCategoriesWithToilets:(BOOL)includeToilets
{
    NSPredicate *predicate = nil;
    if (!includeToilets) {
        predicate = [NSPredicate predicateWithFormat:@"places.@count != 0 && name !=[cd] %@", @"Toilets"];
    } else {
        predicate = [NSPredicate predicateWithFormat:@"places.@count != 0"];
    }
    
    return [self executeRequestWithPredicate:predicate];
}

+ (NSArray *)placeCategories 
{
    return [self placeCategoriesWithToilets:NO];
}

+ (Category *)categoryWithId:(NSNumber *)categoryId
{
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"categoryId == %@", categoryId];
    NSArray *results = [self executeRequestWithPredicate:predicate];
    
    if (results == nil || results.count == 0) {
        NSLog(@"No category found with ID: %@", categoryId);
        return nil;
    }
    
    if (results.count > 1) {
        NSLog(@"Muliple categories found with ID: %@", categoryId);
    }
    
    return [results objectAtIndex:0];
}

#pragma mark - instance methods -

- (NSArray *)sortedPlaces
{
    NSSortDescriptor *sortNameDescriptor = [[NSSortDescriptor alloc] initWithKey:@"name" ascending:YES];
    NSArray *sortDescriptors = @[sortNameDescriptor];
    
    return [self.places sortedArrayUsingDescriptors:sortDescriptors];
}

#pragma mark - Private methods -

+ (NSArray *)executeRequestWithPredicate:(NSPredicate *)predicate
{
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"Category" inManagedObjectContext:[NSManagedObjectContext sharedInstance]];
    
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    [request setEntity:entity];
    
    NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"name" ascending:YES];
    [request setSortDescriptors:@[sortDescriptor]];
    
    if (predicate) {
        [request setPredicate:predicate];   
    }
    
    NSError *error = nil;
    NSArray *results = [[NSManagedObjectContext sharedInstance] executeFetchRequest:request error:&error];
    
    if (error && [error isKindOfClass:[NSError class]]) {
        NSLog(@"Failed to fetch data: %@", [error localizedDescription]);
#if DEBUG
        abort();
#endif
    }
    
    return results;
}

@end

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
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"Category" inManagedObjectContext:[NSManagedObjectContext sharedInstance]];
    
    NSFetchRequest *request = [[[NSFetchRequest alloc] init] autorelease];
    [request setEntity:entity];
    
    NSSortDescriptor *sortDescriptor = [[[NSSortDescriptor alloc] initWithKey:@"name" ascending:YES] autorelease];
    [request setSortDescriptors:[NSArray arrayWithObject:sortDescriptor]];
    
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"places.@count != 0"];
    [request setPredicate:predicate];
    
    return [[NSManagedObjectContext sharedInstance] executeFetchRequest:request error:nil];
}

+ (Category *)categoryWithId:(NSNumber *)categoryId
{
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"Category" inManagedObjectContext:[NSManagedObjectContext sharedInstance]];
    
    NSFetchRequest *request = [[[NSFetchRequest alloc] init] autorelease];
    [request setEntity:entity];
    [request setFetchLimit:1];
    [request setPredicate:[NSPredicate predicateWithFormat:@"categoryId == %@", categoryId]];
    
    return [[[NSManagedObjectContext sharedInstance] executeFetchRequest:request error:nil] objectAtIndex:0];
}

@end

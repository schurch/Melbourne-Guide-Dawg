//
//  Category+Extensions.m
//  MelbourneGuideDawg
//
//  Created by Stefan Church on 04/03/2012.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "Category+Extensions.h"

@implementation Category (Extensions)

+ (void)addDummyData
{
    NSArray *categories = [[NSArray alloc] initWithObjects:@"Toilets", @"Museums", @"Coffee Shops", @"Bars", @"Restaurants", nil];

    for (NSString *categoryName in categories)
    {
        Category *category = [self category];
        category.name = categoryName;
        [self saveCategory:category];
    }
}

+ (Category *)category
{
    NSManagedObjectContext *context = [NSManagedObjectContext sharedInstance];
    return [NSEntityDescription insertNewObjectForEntityForName:@"Category" inManagedObjectContext:context];   
}

+ (NSArray *)allCategories 
{
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"Category" inManagedObjectContext:[NSManagedObjectContext sharedInstance]];
    
    NSFetchRequest *request = [[[NSFetchRequest alloc] init] autorelease];
    [request setEntity:entity];
    
    NSSortDescriptor *sortDescriptor = [[[NSSortDescriptor alloc] initWithKey:@"name" ascending:YES] autorelease];
    [request setSortDescriptors:[NSArray arrayWithObject:sortDescriptor]];
    
    return [[NSManagedObjectContext sharedInstance] executeFetchRequest:request error:nil];
}

+ (void)saveCategory:(Category *)category
{
    [[NSManagedObjectContext sharedInstance] insertObject:category];
    [[NSManagedObjectContext sharedInstance] save:nil];   
}

+ (void)deleteCategory:(Category *)category
{
    [[NSManagedObjectContext sharedInstance] deleteObject:category];
    [[NSManagedObjectContext sharedInstance] save:nil];
}

@end

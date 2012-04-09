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

+ (void)addDummyData
{
    NSArray *categories = [[NSArray alloc] initWithObjects:@"Toilets", @"Museums", @"Coffee Shops", @"Bars", @"Restaurants", nil];

    for (NSString *categoryName in categories)
    {
        Category *category = [self category];
        category.name = categoryName;
        
        NSMutableArray *places = [[NSMutableArray alloc] init];
        for (int i = 0; i < 10; i++) {
            [Place createDummyPlaceWithImage:@"melbourne1" lat:-37.812225 lng:144.963055 category:category];
            [Place createDummyPlaceWithImage:@"melbourne2" lat:-37.80490 lng:144.97121 category:category];    
            [Place createDummyPlaceWithImage:@"melbourne3" lat:-37.82036 lng:144.94477 category:category];    
            [Place createDummyPlaceWithImage:@"melbourne4" lat:-37.81290 lng:144.95190 category:category];    
            [Place createDummyPlaceWithImage:@"melbourne5" lat:-37.81507 lng:144.97396 category:category];    
            [Place createDummyPlaceWithImage:@"melbourne6" lat:-37.82423 lng:144.96958 category:category];    
            [Place createDummyPlaceWithImage:@"melbourne7" lat:-37.81941 lng:144.97516 category:category];    
            [Place createDummyPlaceWithImage:@"melbourne8" lat:-37.81575 lng:144.96263 category:category];  
        }
        
        [category addPlaces:[[NSSet alloc] initWithArray:places]];
        
        [places release];   
    }
    
    [[NSManagedObjectContext sharedInstance] save];
}

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

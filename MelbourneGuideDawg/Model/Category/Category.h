//
//  Category.h
//  MelbourneGuideDawg
//
//  Created by Stefan Church on 01/03/2012.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Place;

@interface Category : NSManagedObject

@property (nonatomic, retain) NSNumber * categoryId;
@property (nonatomic, retain) NSString * name;
@property (nonatomic, retain) NSSet *places;
@end

@interface Category (CoreDataGeneratedAccessors)

- (void)addPlaceObject:(Place *)value;
- (void)removePlaceObject:(Place *)value;
- (void)addPlace:(NSSet *)values;
- (void)removePlace:(NSSet *)values;

@end

//
//  Category.h
//  MelbourneGuideDawg
//
//  Created by Stefan Church on 25/05/2012.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Place;

@interface Category : NSManagedObject

@property (nonatomic, strong) NSNumber * categoryId;
@property (nonatomic, strong) NSString * name;
@property (nonatomic, strong) NSNumber * filterSelected;
@property (nonatomic, strong) NSSet *places;
@end

@interface Category (CoreDataGeneratedAccessors)

- (void)addPlacesObject:(Place *)value;
- (void)removePlacesObject:(Place *)value;
- (void)addPlaces:(NSSet *)values;
- (void)removePlaces:(NSSet *)values;
@end

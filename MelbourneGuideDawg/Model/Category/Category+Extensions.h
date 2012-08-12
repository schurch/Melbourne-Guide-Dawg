//
//  Category+Extensions.h
//  MelbourneGuideDawg
//
//  Created by Stefan Church on 04/03/2012.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "Category.h"

@interface Category (Extensions)

+ (Category *)category;
+ (NSArray *)allCategories;
+ (NSArray *)placeCategories;
+ (NSArray *)placeCategoriesWithToilets:(BOOL)includeToilets;
+ (Category *)categoryWithId:(NSNumber *)categoryId;
+ (NSArray *)executeRequestWithPredicate:(NSPredicate *)predicate;

@end

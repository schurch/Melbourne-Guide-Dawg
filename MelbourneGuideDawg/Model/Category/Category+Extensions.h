//
//  Category+Extensions.h
//  MelbourneGuideDawg
//
//  Created by Stefan Church on 04/03/2012.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "Category.h"

@interface Category (Extensions)

+ (void)addDummyData;
+ (Category *)category;
+ (NSArray *)allCategories;
+ (void)saveCategory:(Category *)category;
+ (void)deleteCategory:(Category *)category;

@end

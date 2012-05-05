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
+ (Category *)categoryWithId:(NSNumber *)categoryId;

@end

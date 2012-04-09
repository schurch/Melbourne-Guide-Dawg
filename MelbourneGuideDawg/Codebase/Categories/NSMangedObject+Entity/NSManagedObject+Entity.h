//
//  NSManagedObject+Entity.h
//  Sky
//
//  Created by Stefan Church on 27/03/2012.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <CoreData/CoreData.h>

@interface NSManagedObject (Entity)

+ (NSString *)entityName;
+ (id)entityWithContext:(NSManagedObjectContext *)context;

- (void)remove;

@end

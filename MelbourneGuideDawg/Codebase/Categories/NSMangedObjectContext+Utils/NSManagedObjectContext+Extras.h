//
//  NSManagedObjectContext+Extras.h
//  Travel
//
//  Created by Stefan Church on 02/03/2012.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreData/CoreData.h>

@interface NSManagedObjectContext (Extras)

+ (NSManagedObjectContext *)sharedInstance;
- (void)save;

@end

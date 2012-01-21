//
//  Image.h
//  MelbourneGuideDawg
//
//  Created by Stefan Church on 21/01/2012.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Site;

@interface Image : NSManagedObject

@property (nonatomic, retain) NSString * imageFileName;
@property (nonatomic, retain) NSString * smallFileName;
@property (nonatomic, retain) Site *site;

@end

//
//  SiteDetail.h
//  MelbourneGuideDawg
//
//  Created by Stefan Church on 17/01/2012.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Site;

@interface SiteDetail : NSManagedObject

@property (nonatomic, retain) NSData * image;
@property (nonatomic, retain) Site *site;

@end

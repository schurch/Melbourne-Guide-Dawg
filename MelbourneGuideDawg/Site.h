//
//  Site.h
//  MelbourneGuideDawg
//
//  Created by Stefan Church on 17/01/2012.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class SiteDetail;

@interface Site : NSManagedObject

@property (nonatomic, retain) NSDate * date;
@property (nonatomic, retain) NSNumber * id;
@property (nonatomic, retain) NSString * locationPosition;
@property (nonatomic, retain) NSString * locationText;
@property (nonatomic, retain) NSString * text;
@property (nonatomic, retain) NSString * title;
@property (nonatomic, retain) NSData * imageThumb;
@property (nonatomic, retain) SiteDetail *detail;

@end

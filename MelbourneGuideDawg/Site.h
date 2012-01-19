//
//  Site.h
//  MelbourneGuideDawg
//
//  Created by Stefan Church on 19/01/2012.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface Site : NSManagedObject

@property (nonatomic, retain) NSDate * date;
@property (nonatomic, retain) NSString * imageFileName;
@property (nonatomic, retain) NSData * imageThumbData;
@property (nonatomic, retain) NSNumber * lat;
@property (nonatomic, retain) NSNumber * lng;
@property (nonatomic, retain) NSString * location;
@property (nonatomic, retain) NSString * name;
@property (nonatomic, retain) NSNumber * siteId;
@property (nonatomic, retain) NSString * text;
@property (nonatomic, retain) NSData * imageTinyData;

@end

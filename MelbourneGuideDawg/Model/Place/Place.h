//
//  Place.h
//  MelbourneGuideDawg
//
//  Created by Stefan Church on 09/04/2012.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Category;

@interface Place : NSManagedObject

@property (nonatomic, retain) NSString * address;
@property (nonatomic, retain) NSDate * date;
@property (nonatomic, retain) NSString * imageFileName;
@property (nonatomic, retain) NSString * cellImageFileName;
@property (nonatomic, retain) NSNumber * lat;
@property (nonatomic, retain) NSNumber * lng;
@property (nonatomic, retain) NSString * name;
@property (nonatomic, retain) NSNumber * placeId;
@property (nonatomic, retain) NSString * smallImageFileName;
@property (nonatomic, retain) NSString * text;
@property (nonatomic, retain) NSString * url;
@property (nonatomic, retain) NSString * retinaImageFileName;
@property (nonatomic, retain) Category *category;

@end

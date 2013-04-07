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

@property (nonatomic, strong) NSString * address;
@property (nonatomic, strong) NSDate * date;
@property (nonatomic, strong) NSString * imageFileName;
@property (nonatomic, strong) NSString * cellImageFileName;
@property (nonatomic, strong) NSNumber * lat;
@property (nonatomic, strong) NSNumber * lng;
@property (nonatomic, strong) NSString * name;
@property (nonatomic, strong) NSNumber * placeId;
@property (nonatomic, strong) NSString * smallImageFileName;
@property (nonatomic, strong) NSString * text;
@property (nonatomic, strong) NSString * url;
@property (nonatomic, strong) NSString * retinaImageFileName;
@property (nonatomic, strong) Category *category;

@end

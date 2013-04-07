//
//  PlaceViewController.h
//  MelbourneGuideDawg
//
//  Created by Stefan Church on 25/05/2012.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface PlaceViewController : UIViewController

@property (nonatomic, strong) NSManagedObjectContext *managedObjectContext;

- (void)refreshView;

@end

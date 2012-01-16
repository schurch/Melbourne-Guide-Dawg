//
//  FirstViewController.h
//  MelbourneGuideDawg
//
//  Created by Stefan Church on 16/01/2012.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface HomeViewController : UIViewController {
    UIScrollView *_introScrollView;
    UIView *_introductionView;
}

@property (nonatomic, retain) IBOutlet UIScrollView *introScrollView;
@property (nonatomic, retain) IBOutlet UIView *introductionView;

@end

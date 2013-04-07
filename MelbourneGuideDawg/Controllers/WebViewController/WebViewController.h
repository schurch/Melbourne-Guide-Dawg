//
//  WebViewController.h
//  MelbourneGuideDawg
//
//  Created by Stefan Church on 24/05/2012.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PlaceViewController.h"

@interface WebViewController : PlaceViewController

@property (nonatomic, strong) IBOutlet UIWebView *webview; 
@property (nonatomic, strong) NSString *url;

@end

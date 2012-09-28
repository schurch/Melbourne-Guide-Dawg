//
//  WebViewController.m
//  MelbourneGuideDawg
//
//  Created by Stefan Church on 24/05/2012.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "WebViewController.h"

@implementation WebViewController


- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
    }
    return self;
}

- (void)dealloc
{
    [_webview release];
    [_url release];
    
    [super dealloc];
}

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.navigationItem.leftBarButtonItem = [Utils generateButtonItemWithImageName:@"back-btn.png" target:self selector:@selector(back:)];
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    
    self.webview = nil;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    //clear web view
    [self.webview stringByEvaluatingJavaScriptFromString:@"document.open();document.close()"];
    NSURLRequest *request = [[NSURLRequest alloc] initWithURL:[NSURL URLWithString:self.url]];
    [self.webview loadRequest:request];
    [request release];
}

#pragma mark - Methods -

- (void)back:(id)sender 
{
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark - Web view delegates -

- (void)webViewDidStartLoad:(UIWebView *)webView
{
    [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
}

- (void)webViewDidFinishLoad:(UIWebView *)webView
{
    [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
}

@end

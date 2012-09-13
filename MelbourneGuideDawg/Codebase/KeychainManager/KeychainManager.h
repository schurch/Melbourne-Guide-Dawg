//
//  KeychainManager.h
//
//  Created by Brent Chionh on 5/2/11.
//  Copyright 2011 rubbleDEV. All rights reserved.
//
//  Manages generic passwords in keychain

#import <Foundation/Foundation.h>

@interface KeychainManager : NSObject

- (id)initWithServiceName:(NSString *)service;
- (BOOL)writeItem:(NSString *)item forKey:(NSString *)key;
- (BOOL)itemExistsForKey:(NSString *)key;
- (void)clearItemForKey:(NSString *)key;
- (NSString *)itemForKey:(NSString *)key;

@end
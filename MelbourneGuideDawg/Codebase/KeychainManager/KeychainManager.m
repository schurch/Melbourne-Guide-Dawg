//
//  KeychainManager.m
//
//  Created by Brent Chionh on 5/2/11.
//  Copyright 2011 rubbleDEV. All rights reserved.
//

#import "KeychainManager.h"
#import "SFHFKeychainUtils.h"

@interface KeychainManager()
@property (nonatomic, strong) NSString *serviceName;
@end

@implementation KeychainManager

@synthesize serviceName = _serviceName;

- (id)initWithServiceName:(NSString *)service {
    
    if ((self = [super init])) {
        self.serviceName = service;
    }
    return self;
}

- (BOOL)writeItem:(NSString *)item forKey:(NSString *)key {
    
    if (!key || !item) {
        return NO;
    }
    NSError *error = nil;
    BOOL success = [SFHFKeychainUtils storeKey:key
                                      andValue:item
                                forServiceName:self.serviceName 
                                updateExisting:YES 
                                         error:&error];  
    return (success && !error);
}

- (BOOL)itemExistsForKey:(NSString *)key {
    
    if (!key) {
        return NO;
    } 
    return ([self itemForKey:key] != nil);
}

- (void)clearItemForKey:(NSString *)key {
  
    [SFHFKeychainUtils deleteItemForKey:key
                         andServiceName:self.serviceName 
                                  error:nil];
}

- (NSString *)itemForKey:(NSString *)key {
    
    if (!key) {
        return nil;
    }
    
    NSError *error = nil;
    NSString *value = nil;

    value = [SFHFKeychainUtils getValueForKey:key
                               andServiceName:self.serviceName 
                                        error:&error];
    if (error || !value) {
        return nil;
    }
    return value;
}

#pragma mark - Memory Management -


@end
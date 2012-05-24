//
//  SyncManager.h
//  MelbourneGuideDawg
//
//  Created by Stefan Church on 09/04/2012.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SyncManager : NSObject 
{
    BOOL _syncInProgress;
}

- (void)syncWithCompletionBlock:(void (^)())completionBlock errorBlock:(void (^)(NSError *))errorBlock progressBlock:(void (^)(NSString *))progressBlock;

@end

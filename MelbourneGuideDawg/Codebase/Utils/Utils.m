//
//  Utils.m
//  MelbourneGuideDawg
//
//  Created by Stefan Church on 13/09/2012.
//
//

#import "Utils.h"
#import "KeychainManager.h"

@implementation Utils

+ (NSString *)deviceID
{
    KeychainManager *keychain = [[[KeychainManager alloc] initWithServiceName:kBundleID] autorelease];
    NSString *key = @".deviceID";
    if ([keychain itemExistsForKey:key]) {
        return [keychain itemForKey:key];
    } else {
        NSString *uuid = nil;
        CFUUIDRef theUUID = CFUUIDCreate(kCFAllocatorDefault);
        if (theUUID) {
            uuid = NSMakeCollectable(CFUUIDCreateString(kCFAllocatorDefault, theUUID));
            [uuid autorelease];
            CFRelease(theUUID);
        }
        [keychain writeItem:uuid forKey:key];
        return uuid;
    }
}

@end

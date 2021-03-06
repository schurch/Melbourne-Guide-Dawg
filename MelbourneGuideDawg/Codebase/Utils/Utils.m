//
//  Utils.m
//  MelbourneGuideDawg
//
//  Created by Stefan Church on 14/09/2012.
//
//

#import "Utils.h"
#import "Place+Extensions.h"
#import "KeychainManager.h"

@interface Utils()
+ (NSURL *)storeLocation;
+ (NSURL *)photosLocation;
@end

@implementation Utils

#pragma mark - public methods -

+ (UIBarButtonItem *)generateButtonItemWithImageName:(NSString *)imageName target:(id)target selector:(SEL)selector
{
    UIImage *image = [UIImage imageNamed:imageName];
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    [button setFrame:CGRectMake(0.0f, 0.0f, image.size.width, image.size.height)];
    [button setImage:image forState:UIControlStateNormal];
    [button addTarget:target action:selector forControlEvents:UIControlEventTouchUpInside];
    return [[UIBarButtonItem alloc] initWithCustomView:button];
}

+ (NSString *)deviceID
{
    KeychainManager *keychain = [[KeychainManager alloc] initWithServiceName:kBundleID];
    NSString *key = @".deviceID";
    if ([keychain itemExistsForKey:key]) {
        return [keychain itemForKey:key];
    } else {
        NSString *uuid = nil;
        CFUUIDRef theUUID = CFUUIDCreate(kCFAllocatorDefault);
        if (theUUID) {
            uuid = CFBridgingRelease(CFUUIDCreateString(kCFAllocatorDefault, theUUID));
            CFRelease(theUUID);
        }
        [keychain writeItem:uuid forKey:key];
        return uuid;
    }
}

+ (NSURL *)documentsDirectory
{
    return [[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] lastObject];   
}

+ (NSURL *)downloadDirectory
{
    return [[[NSFileManager defaultManager] URLsForDirectory:NSCachesDirectory inDomains:NSUserDomainMask] lastObject];
}

+ (BOOL)downloadDataInDocuments
{
    BOOL databaseExists = [[NSFileManager defaultManager] fileExistsAtPath:[[self storeLocation] path]];
    BOOL photoExist = [[NSFileManager defaultManager] fileExistsAtPath:[[self photosLocation] path]];
    
    if (databaseExists || photoExist) {
        return YES;
    } else {
        return NO;
    }
}

+ (void)moveDownloadDataToCache
{
    NSFileManager *fileManager = [NSFileManager defaultManager];
    
    if ([fileManager fileExistsAtPath:[[self storeLocation] path]]) {
        NSURL *newPath = [[self downloadDirectory] URLByAppendingPathComponent:@"Model.sqlite"];
        [self excludeURLPathFromBackup:newPath];
        [fileManager moveItemAtURL:[self storeLocation] toURL:newPath error:nil];
    }
    
    if ([fileManager fileExistsAtPath:[[self photosLocation] path]]) {
        NSURL *newPath = [[self downloadDirectory] URLByAppendingPathComponent:@"photos"];
        [self excludeURLPathFromBackup:newPath];
        [fileManager moveItemAtURL:[self photosLocation] toURL:newPath error:nil];
    }
}

+ (BOOL)excludeURLPathFromBackup:(NSURL *)URL
{
    const char* filePath = [[URL path] fileSystemRepresentation];
    const char* attrName = "com.apple.MobileBackup";
    if (&NSURLIsExcludedFromBackupKey == nil) {
        // iOS 5.0.1 and lower
        u_int8_t attrValue = 1;
        int result = setxattr(filePath, attrName, &attrValue, sizeof(attrValue), 0, 0);
        return result == 0;
    } else {
        // First try and remove the extended attribute if it is present
        int result = getxattr(filePath, attrName, NULL, sizeof(u_int8_t), 0, 0);
        if (result != -1) {
            // The attribute exists, we need to remove it
            int removeResult = removexattr(filePath, attrName, 0);
            if (removeResult == 0) {
                NSLog(@"Removed extended attribute on file %@", URL);
            }
        }
        
        // Set the new key
        return [URL setResourceValue:[NSNumber numberWithBool:YES] forKey:@"NSURLIsExcludedFromBackupKey" error:nil];
    }
}

#pragma mark - private methods -

+ (NSURL *)storeLocation
{
    return [[self documentsDirectory] URLByAppendingPathComponent:@"Model.sqlite"];
}

+ (NSURL *)photosLocation
{
    return [[self documentsDirectory] URLByAppendingPathComponent:@"photos"];
}

@end

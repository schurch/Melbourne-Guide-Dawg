//
//  Utils.h
//  MelbourneGuideDawg
//
//  Created by Stefan Church on 13/09/2012.
//
//

#import <Foundation/Foundation.h>

@interface Utils : NSObject

+ (NSString *)deviceID;
+ (NSURL *)documentsDirectory;
+ (NSURL *)downloadDirectory;
+ (BOOL)downloadDataInDocuments;
+ (void)moveDownloadDataToCache;
+ (BOOL)excludeURLPathFromBackup:(NSURL *)URL;

@end
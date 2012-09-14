//
//  Utils.h
//  MelbourneGuideDawg
//
//  Created by Stefan Church on 14/09/2012.
//
//

#import <Foundation/Foundation.h>

@interface Utils : NSObject

+ (NSURL *)documentsDirectory;
+ (NSURL *)downloadDirectory;
+ (BOOL)downloadDataInDocuments;
+ (void)moveDownloadDataToCache;
+ (BOOL)excludeURLPathFromBackup:(NSURL *)URL;

@end

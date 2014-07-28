//
//  FileUtils.m
//  iGCS
//
//  Created by Andrew Brown on 8/28/13.
//
//

#import "FileUtils.h"

@implementation FileUtils

#pragma mark -
#pragma path helpers
+(NSURL *)documentsDir {
    return [[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] firstObject];
}

+(NSURL *)URLToFileInDocumentsDirWithFileName:(NSString *) fileName {
    return [[self documentsDir] URLByAppendingPathComponent:fileName];
}

#pragma mark - 
#pragma FileHandle helpers
+(NSFileHandle *) fileHandleForWritingAtPath:(NSString *) filePath create:(BOOL) shouldCreate {
    NSFileHandle *fileHandle = [NSFileHandle fileHandleForWritingAtPath:filePath];
    
    if (!fileHandle && shouldCreate) {
        BOOL success = [[NSFileManager defaultManager]
                        createFileAtPath:filePath contents:nil attributes:nil];
        
        if (success) {
            NSLog(@"FileUtils:createFileHandleForWritingAtFilePath: %@", filePath);
            fileHandle = [NSFileHandle fileHandleForWritingAtPath:filePath];
        } else {
            NSLog(@"FileUtils:createFileHandleForWritingAtFilePath: failed to create %@", filePath);
        }
    }

    return fileHandle;
}

+(NSData *)dataFromFileInMainBundleWithName:(NSString *) fileName {
    NSString *resourceName = [fileName stringByDeletingPathExtension];
    NSString *resourceType = [fileName pathExtension];

    NSBundle *mainBundle = [NSBundle mainBundle];
    NSString *filePath = [mainBundle pathForResource:resourceName ofType:resourceType];

    if (!fileName) {
        return nil;
    }

    NSURL *fileURL = [NSURL fileURLWithPath:filePath];
    return [NSData dataWithContentsOfFile:[fileURL path]];
}
@end

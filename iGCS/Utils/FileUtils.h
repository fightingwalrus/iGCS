//
//  FileUtils.h
//  iGCS
//
//  Created by Andrew Brown on 8/28/13.
//
//

#import <Foundation/Foundation.h>

@interface FileUtils : NSObject
+(NSURL *)documentsDir;
+(NSURL *)URLToFileInDocumentsDirWithFileName:(NSString *) fileName;
+(NSFileHandle *) fileHandleForWritingAtPath:(NSString *) filePath create:(BOOL)shouldCreate;
@end

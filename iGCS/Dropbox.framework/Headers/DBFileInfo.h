/* Copyright (c) 2012 Dropbox, Inc. All rights reserved. */

@class DBPath;


/** The file info class contains basic information about a file or folder. */

@interface DBFileInfo : NSObject

/** The path of the file or folder. */
@property (nonatomic, readonly) DBPath *path;

/** Whether the item at `path` is a folder or a file. */
@property (nonatomic, readonly) BOOL isFolder;

/** The last time the file or folder was modified. */
@property (nonatomic, readonly) NSDate *modifiedTime;

/** The file's size. This property is always 0 for folders. */
@property (nonatomic, readonly) long long size;

@end

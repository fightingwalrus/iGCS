/* Copyright (c) 2012 Dropbox, Inc. All rights reserved. */

#import "DBAccount.h"
#import "DBFile.h"
#import "DBFileInfo.h"
#import "DBPath.h"


/** A set of various fields indicating the current status of the filesystem's syncing. */

enum DBSyncStatusFlags {
	DBSyncStatusDownloading = (1 << 0),
	DBSyncStatusUploading = (1 << 1),
	DBSyncStatusSyncing = (1 << 2),
	DBSyncStatusOnline = (1 << 3),
};

typedef NSUInteger DBSyncStatus;

/** The filesystem object provides a files and folder view of a user's Dropbox. The most basic
 operations are listing a folder and opening a file, but it also allows you to move, delete, and 
 create files and folders.*/

@interface DBFilesystem : NSObject

/** @name Creating a filesystem object */

/** Create a new filesystem object with a linked [account](DBAccount) from the
 [account manager](DBAccountManager).*/
- (id)initWithAccount:(DBAccount *)account;

/** A convienent place to store your app's filesystem */
+ (void)setSharedFilesystem:(DBFilesystem *)filesystem;

/** A convienent place to get your app's filesystem */
+ (DBFilesystem *)sharedFilesystem;


/** @name Getting file information */

/** Returns a list of DBFileInfo objects representing the files contained in the folder at `path`.
 If <completedFirstSync> is false, then this call will block until the first sync completes or an
 error occurs.
 
 @return An array of DBFileInfo objects if successful, or `nil` if an error occurred.
 */
- (NSArray *)listFolder:(DBPath *)path error:(DBError **)error;

/** Returns the [file info](DBFileInfo) for the file or folder at `path`. */
- (DBFileInfo *)fileInfoForPath:(DBPath *)path error:(DBError **)error;


/** @name Operations */

/** Opens an existing file and returns a [file](DBFile) object representing the file at `path`.
 
 Files are opened at the newest cached version if the file is cached. Otherwise, the file will
 open at the latest server version and start downloading. Check the `status` property of the
 returned file object to determine whether it's cached. Only 1 file can be open at a given path at 
 the same time.

 @return The [file](DBFile) object if the file was opened successfully, or `nil` if an error
 occurred.
 */
- (DBFile *)openFile:(DBPath *)path error:(DBError **)error;

/** Creates a new file at `path` and returns a file object open at that path.
 
 @return The newly created [file](DBFile) object if the file was opened successfuly, or `nil` if an
 error occurred. */
- (DBFile *)createFile:(DBPath *)path error:(DBError **)error;

/** Creates a new folder at `path`. 
 
 @return YES if the folder was created successfully, or NO if an error occurred. */
- (BOOL)createFolder:(DBPath *)path error:(DBError **)error;

/** Deletes the file or folder at `path`.
 
 @return YES if the file or folder was deleted successfully, or NO if an error occurred. */
- (BOOL)deletePath:(DBPath *)path error:(DBError **)error;

/** Moves a file or folder at `fromPath` to `toPath`.
 
 @return YES if the file or folder was moved successfully, or NO if an error occurred. */
- (BOOL)movePath:(DBPath *)fromPath toPath:(DBPath *)toPath error:(DBError **)error;


/** @name Getting the current state */

/** The [account](DBAccount) object this filesystem was created with. */
@property (nonatomic, readonly) DBAccount *account;

/** When a user's account is first linked, the filesystem needs to be synced with the server before
 it can be used. This property indicates whether the first sync has completed and the filesystem
 is ready to use. */
@property (nonatomic, readonly) BOOL completedFirstSync;

/** Whether the filesystem is currently shut down. The filesystem will shut down if the account
 associated with this filesystem becomes unlinked. */
@property (nonatomic, readonly, getter=isShutDown) BOOL shutDown;

/** Returns a bitmask representing all the currently active states of the filesystem OR'ed together.
 See the DBSyncStatus enum for more details. */
@property (nonatomic, readonly) DBSyncStatus status;


/** @name Watching for changes */

/** Add an observer to be notified any time the file or folder at `path` changes. */
- (BOOL)addObserver:(id)observer forPath:(DBPath *)path block:(DBObserver)block;

/** Add an observer to be notified any time the folder at `path` changes or a file or folder
 directly contained in `path` changes. */
- (BOOL)addObserver:(id)observer forPathAndChildren:(DBPath *)path block:(DBObserver)block;

/** Add an observer to be notified any time the folder at `path` changes or a file or folder
 contained somewhere beneath `path` changes. */
- (BOOL)addObserver:(id)observer forPathAndDescendants:(DBPath *)path block:(DBObserver)block;

/** Unregister all blocks associated with `observer` from receiving updates. */
- (void)removeObserver:(id)observer;

@end




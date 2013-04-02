/* Copyright (c) 2013 Dropbox, Inc. All rights reserved. */


/** Information about a user's account. */
@interface DBAccountInfo : NSObject

/** The user's name. */
@property (nonatomic, readonly) NSString *displayName;

/** The user's email address, if available. */
@property (nonatomic, readonly) NSString *email;

@end

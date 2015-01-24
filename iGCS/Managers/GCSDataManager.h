//
//  GCSDataManager.h
//  iGCS
//
//  Created by Andrew Brown on 1/22/15.
//
//

#import <Foundation/Foundation.h>
#import "GCSCraftModel.h"

@interface GCSDataManager : NSObject
+ (instancetype) sharedInstance;

@property (atomic, strong) id<GCSCraftModel> craft;

@end

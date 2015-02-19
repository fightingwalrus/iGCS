//
//  GCSCraftArduCopter.h
//  iGCS
//
//  Created by Claudio Natoli on 24/01/2015.
//
//

#import <Foundation/Foundation.h>
#import "GCSCraftModel.h"

@interface GCSCraftArduCopter : NSObject <GCSCraftModel>
@property (nonatomic, assign) mavlink_heartbeat_t heartbeat;
@end

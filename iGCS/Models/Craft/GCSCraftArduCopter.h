//
//  GCSCraftArduCopter.h
//  iGCS
//
//  Created by Claudio Natoli on 24/01/2015.
//
//

#import <Foundation/Foundation.h>
#import "GCSCraftModel.h"
#import "GCSHeartbeat.h"

@interface GCSCraftArduCopter : NSObject <GCSCraftModel>
@property (nonatomic, strong) GCSHeartbeat *heartbeat;
@end

//
//  GCSCraftArduPlane.h
//  iGCS
//
//  Created by Claudio Natoli on 24/01/2015.
//
//

#import <Foundation/Foundation.h>
#import "GCSCraftModel.h"

@interface GCSCraftArduPlane : NSObject <GCSCraftModel>
@property (nonatomic, strong) GCSHeartbeat* heartbeat;
@end

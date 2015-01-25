//
//  GCSDataManager.h
//  iGCS
//
//  Created by Andrew Brown on 1/22/15.
//
//

#import <Foundation/Foundation.h>
#import <MapKit/MKMapCamera.h>
#import "GCSCraft.h"
#import "GCSCraftModel.h"

@interface GCSDataManager : NSObject
+ (instancetype) sharedInstance;

@property (atomic, strong) id<GCSCraftModel> craft;

// This is used to keep the maps consistent when switching back and forth between
// the various views. A camera object (representing a center-coord and altitude)
// is preferred over a region (center-coord + lat/long spans) due to the differing
// aspect ratios of the maps: a camera will remain consistent between switches,
// whereas a region cannot.
@property (atomic, copy) MKMapCamera *lastViewedMapCamera;

@end

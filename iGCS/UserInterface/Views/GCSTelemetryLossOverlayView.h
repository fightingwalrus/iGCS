//
//  GCSTelemetryLossOverlayView.h
//  iGCS
//
//  Created by Claudio Natoli on 16/07/2014.
//
//

#import <Foundation/Foundation.h>

@interface GCSTelemetryLossOverlayView : NSObject

- (instancetype) initWithParentView:(UIView*)parentView NS_DESIGNATED_INITIALIZER;
- (void) show;
- (void) hide;

@end

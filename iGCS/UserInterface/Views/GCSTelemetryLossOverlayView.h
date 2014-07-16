//
//  GCSTelemetryLossOverlayView.h
//  iGCS
//
//  Created by Claudio Natoli on 16/07/2014.
//
//

#import <Foundation/Foundation.h>

@interface GCSTelemetryLossOverlayView : NSObject

- (id) initWithParentView:(UIView*)parentView;
- (void) show;
- (void) hide;

@end

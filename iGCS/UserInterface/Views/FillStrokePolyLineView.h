//
//  FillStrokePolyLineView.h
//  iGCS
//
//  Created by Claudio Natoli on 14/03/2014.
//
//  A basic replacement for MKPolylineView, which supports filled and stroked lines.
//
//  To be replaced by a MKOverlayPathRenderer variant when supporting iOS7 only.

#import <MapKit/MapKit.h>

@interface FillStrokePolyLineView : MKOverlayPathView

@property CGFloat fillWidth;

- (id) initWithPolyline:(MKPolyline*)polyline;

@end

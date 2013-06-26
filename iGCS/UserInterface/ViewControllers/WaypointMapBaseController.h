//
//  WaypointMapBaseController.h
//  iGCS
//
//  Created by Claudio Natoli on 20/03/13.
//
//

#import <UIKit/UIKit.h>
#import <MapKit/MKMapView.h>

#import "WaypointsHolder.h"
#import "WaypointAnnotation.h"

@interface WaypointMapBaseController : UIViewController <MKMapViewDelegate> {
@private
    MKPolyline *waypointRoutePolyline;
    MKPolylineView *waypointRouteView;
    int currentWaypointNum;

    MKPolyline *trackPolyline;
    MKPolylineView *trackView;
    MKMapPoint *trackMKMapPoints;
    unsigned int trackMKMapPointsLen;
    unsigned int numTrackPoints;
    
@protected
    MKMapView *map;
    bool draggableWaypointsP;
}

@property (nonatomic, retain) IBOutlet MKMapView *_mapView;

- (void) removeExistingWaypointAnnotations;
- (WaypointAnnotation *) getWaypointAnnotation:(int)waypointSeq;
- (void) resetWaypoints:(WaypointsHolder *)_waypoints;
- (void) maybeUpdateCurrentWaypoint:(int)newCurrentWaypointSeq;

- (void) makeWaypointsDraggable:(bool)_draggableWaypointsP;
- (void) waypointWithSeq:(int)waypointSeq wasMovedToLat:(double)latitude andLong:(double)longitude;
- (NSString*) waypointNumberForAnnotationView:(mavlink_mission_item_t)item;

- (void) addToTrack:(CLLocationCoordinate2D)pos;

// FIXME: move to some utils file
+ (UIImage*)imageWithImage:(UIImage*)image scaledToSize:(CGSize)newSize rotation:(double)ang;
+ (UIImage *)image:(UIImage*)img withColor:(UIColor*)color;


@end

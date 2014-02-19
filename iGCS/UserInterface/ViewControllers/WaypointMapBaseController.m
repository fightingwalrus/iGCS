//
//  WaypointMapBaseController.m
//  iGCS
//
//  Created by Claudio Natoli on 20/03/13.
//
//

#import "WaypointMapBaseController.h"
#import "MiscUtilities.h"

@implementation WaypointMapBaseController

@synthesize _mapView = map;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];

	// Do any additional setup after loading the view.
    map.delegate = self;
    
    currentWaypointNum = -1;
    
    trackMKMapPointsLen = 1000;
    trackMKMapPoints = malloc(trackMKMapPointsLen * sizeof(MKMapPoint));
    numTrackPoints = 0;
    
    draggableWaypointsP = false;
    
    // Add recognizer for long press gestures
    UILongPressGestureRecognizer *longPressGesture = [[UILongPressGestureRecognizer alloc]
                                                      initWithTarget:self action:@selector(handleLongPressGesture:)];
    longPressGesture.numberOfTapsRequired = 0;
    longPressGesture.numberOfTouchesRequired = 1;
    longPressGesture.minimumPressDuration = 1.0;
    [map addGestureRecognizer:longPressGesture];
    
    // Start listening for location updates
    locationManager = [[CLLocationManager alloc] init];
    locationManager.desiredAccuracy = kCLLocationAccuracyBest;
    locationManager.delegate = self;
    locationManager.distanceFilter = 2.0f;
    [locationManager startUpdatingLocation];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (NSArray*) getWaypointAnnotations {
    return [map.annotations
            filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"(self isKindOfClass: %@)",
                                         [WaypointAnnotation class]]];
}

- (void) removeExistingWaypointAnnotations {
    [map removeAnnotations:[self getWaypointAnnotations]];
}

- (WaypointAnnotation *) getWaypointAnnotation:(int)waypointSeq {
    NSArray* waypointAnnotations = [self getWaypointAnnotations];
    for (unsigned int i = 0; i < [waypointAnnotations count]; i++) {
        WaypointAnnotation *waypointAnnotation = (WaypointAnnotation*)[waypointAnnotations objectAtIndex:i];;
        if ([waypointAnnotation isCurrentWaypointP:waypointSeq]) {
            return waypointAnnotation;
        }
    }
    return nil;
}

- (void) resetWaypoints:(WaypointsHolder *)_waypoints {
    
    // Clean up existing objects
    [self removeExistingWaypointAnnotations];
    [map removeOverlay:waypointRoutePolyline];
    
    // Get the nav-specfic waypoints
    WaypointsHolder *navWaypoints = [_waypoints getNavWaypoints];
    unsigned int numWaypoints = [navWaypoints numWaypoints];
    
    MKMapPoint *navMKMapPoints = malloc(sizeof(MKMapPoint) * numWaypoints);
    
    // Add waypoint annotations, and convert to array of MKMapPoints
    for (unsigned int i = 0; i < numWaypoints; i++) {
        mavlink_mission_item_t waypoint = [navWaypoints getWaypoint:i];
        CLLocationCoordinate2D coordinate = CLLocationCoordinate2DMake(waypoint.x, waypoint.y);
        
        // Add the annotation
        WaypointAnnotation *annotation = [[WaypointAnnotation alloc] initWithCoordinate:coordinate
                                                                            andWayPoint:waypoint
                                                                                atIndex:[_waypoints getIndexOfWaypointWithSeq:waypoint.seq]];
        [map addAnnotation:annotation];
        
        // Construct the MKMapPoint
        navMKMapPoints[i] = MKMapPointForCoordinate(coordinate);
    }
    
    // Add the polyline overlay
    waypointRoutePolyline = [MKPolyline polylineWithPoints:navMKMapPoints count:numWaypoints];
    [map addOverlay:waypointRoutePolyline];
    
    // Set the map extents
    MKMapRect bounds = [waypointRoutePolyline boundingMapRect];
    if (!MKMapRectIsNull(bounds)) {
        // Extend the bounding rect of the polyline slightly
        MKCoordinateRegion region = MKCoordinateRegionForMapRect(bounds);
        region.span.latitudeDelta  = MIN(MAX(region.span.latitudeDelta  * MAP_REGION_PAD_FACTOR, MAP_MINIMUM_ARC),  90);
        region.span.longitudeDelta = MIN(MAX(region.span.longitudeDelta * MAP_REGION_PAD_FACTOR, MAP_MINIMUM_ARC), 180);
        [map setRegion:region animated:YES];
    } else if ([waypointRoutePolyline pointCount] == 1) {
        // Fallback to a padded box centered on the single waypoint
        CLLocationCoordinate2D coord = MKCoordinateForMapPoint([waypointRoutePolyline points][0]);
        [map setRegion:MKCoordinateRegionMakeWithDistance(coord, MAP_MINIMUM_PAD, MAP_MINIMUM_PAD) animated:YES];
    }
    [map setNeedsDisplay];
    
    free(navMKMapPoints);
}

- (void)resetWaypointAnnotation:(WaypointAnnotation*)annotation {
    if (annotation) {
        [map removeAnnotation:annotation];
        [map addAnnotation:annotation];
    }
}

- (void) maybeUpdateCurrentWaypoint:(int)newCurrentWaypointSeq {
    if (currentWaypointNum != newCurrentWaypointSeq) {
        // We've reached a new waypoint, so...
        int previousWaypointNum = currentWaypointNum;
        
        //  first, update the current value (so we get the desired
        // side-effect when resetting the waypoints), then...
        currentWaypointNum = newCurrentWaypointSeq;

        //  reset the previous and new current waypoints
        [self resetWaypointAnnotation: [self getWaypointAnnotation:previousWaypointNum]];        
        [self resetWaypointAnnotation: [self getWaypointAnnotation:currentWaypointNum]];
    }
}

- (void) makeWaypointsDraggable:(bool)_draggableWaypointsP {
    draggableWaypointsP = _draggableWaypointsP;
    
    NSArray* waypointAnnotations = [self getWaypointAnnotations];
    for (unsigned int i = 0; i < [waypointAnnotations count]; i++) {
        WaypointAnnotation *waypointAnnotation = (WaypointAnnotation*)[waypointAnnotations objectAtIndex:i];
        
        // See also viewForAnnotation
        MKAnnotationView *av = [map viewForAnnotation:waypointAnnotation];
        [av setCanShowCallout: !draggableWaypointsP];
        [av setDraggable: draggableWaypointsP];
        [av setSelected: draggableWaypointsP];
    }
}

- (void)mapView:(MKMapView *)mapView annotationView:(MKAnnotationView *)annotationView
   didChangeDragState:(MKAnnotationViewDragState)newState
   fromOldState:(MKAnnotationViewDragState)oldState
{
    if ([annotationView.annotation isKindOfClass:[WaypointAnnotation class]]) {
        static WaypointAnnotation *draggedAnnot = nil;
        WaypointAnnotation* annot = annotationView.annotation;
        if (newState == MKAnnotationViewDragStateStarting) {
            draggedAnnot = annot;
        }
        if (newState == MKAnnotationViewDragStateEnding && annot == draggedAnnot) {
            CLLocationCoordinate2D coord = annot.coordinate;
            [self waypointWithSeq:annot.waypoint.seq wasMovedToLat:coord.latitude andLong:coord.longitude];
        }
    }
}


// FIXME: Ugh. This was a quick and dirty way to promote waypoint changes (due to dragging etc) to
// the subclass (which overrides this method). Adopt a more idomatic pattern for this?
- (void) waypointWithSeq:(int)waypointSeq wasMovedToLat:(double)latitude andLong:(double)longitude {
}

// FIXME: consider more efficient (and safe?) ways to do this - see iOS Breadcrumbs sample code
- (void) addToTrack:(CLLocationCoordinate2D)pos {
    MKMapPoint newPoint = MKMapPointForCoordinate(pos);
    
    // Check distance from 0
    if (MKMetersBetweenMapPoints(newPoint, MKMapPointForCoordinate(CLLocationCoordinate2DMake(0, 0))) < 1.0) {
        return;
    }
    
    // Check distance from last point
    if (numTrackPoints > 0) {
        if (MKMetersBetweenMapPoints(newPoint, trackMKMapPoints[numTrackPoints-1]) < 1.0) {
            return;
        }
    }
    
    // Check array bounds
    if (numTrackPoints == trackMKMapPointsLen) {
        MKMapPoint *newAlloc = realloc(trackMKMapPoints, trackMKMapPointsLen*2 * sizeof(MKMapPoint));
        if (newAlloc == nil)
            return;
        trackMKMapPoints = newAlloc;
        trackMKMapPointsLen *= 2;
    }
    
    // Add the next coord
    trackMKMapPoints[numTrackPoints] = newPoint;
    numTrackPoints++;
    
    // Clean up existing objects
    [map removeOverlay:trackPolyline];
    
    trackPolyline = [MKPolyline polylineWithPoints:trackMKMapPoints count:numTrackPoints];
    
    // Add the polyline overlay
    [map addOverlay:trackPolyline];
    [map setNeedsDisplay];
}

- (MKOverlayView *)mapView:(MKMapView *)mapView viewForOverlay:(id)overlay
{
    if (overlay == waypointRoutePolyline) {
        waypointRouteView = [[MKPolylineView alloc] initWithPolyline:overlay];
        waypointRouteView.fillColor     = WAYPOINT_LINE_COLOR;
        waypointRouteView.strokeColor   = WAYPOINT_LINE_COLOR;
        waypointRouteView.lineWidth     = 3;
        return waypointRouteView;
    } else if (overlay == trackPolyline) {
        trackView = [[MKPolylineView alloc] initWithPolyline:overlay];
        trackView.fillColor     = TRACK_LINE_COLOR;
        trackView.strokeColor   = TRACK_LINE_COLOR;
        trackView.lineWidth     = 2;
        return trackView;
    }
    
    return nil;
}

- (NSString*) waypointNumberForAnnotationView:(mavlink_mission_item_t)item {
    // Base class uses the mission item sequence number
    return [NSString stringWithFormat:@"%d", item.seq];
}

// NOOPs - intended to be overrriden as needed
- (void) customizeWaypointAnnotationView:(MKAnnotationView*)view {
}
- (void) handleLongPressGesture:(UIGestureRecognizer*)sender {
}

- (MKAnnotationView *)mapView:(MKMapView *)theMapView viewForAnnotation:(id <MKAnnotation>)annotation
{
    static const int LABEL_TAG = 100;
    static const int ICON_VIEW_TAG = 101;
    
    // If it's the user location, just return nil.
    if ([annotation isKindOfClass:[MKUserLocation class]])
        return nil;
    
    // Handle our custom annotations
    //
    if ([annotation isKindOfClass:[WaypointAnnotation class]]) {
        static NSString* const identifier = @"WAYPOINT";
        MKAnnotationView *view = (MKAnnotationView*) [map dequeueReusableAnnotationViewWithIdentifier:identifier];
        if (view == nil) {
            view = [[MKAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:identifier];
            
            UILabel *label = [[UILabel alloc]  initWithFrame:CGRectMake(WAYPOINT_TOUCH_TARGET_SIZE/2, -WAYPOINT_TOUCH_TARGET_SIZE/2, 32, 32)];
            label.backgroundColor = [UIColor clearColor];
            label.textColor = [UIColor whiteColor];
            label.tag = LABEL_TAG;
            [view addSubview:label];
        } else {
            [[view viewWithTag:ICON_VIEW_TAG] removeFromSuperview];
            view.annotation = annotation;
        }
        
        view.enabled = YES;
        
        // See also makeWaypointsDraggable
        view.canShowCallout = !draggableWaypointsP;
        view.draggable = draggableWaypointsP;
        view.selected = draggableWaypointsP;
        [view setFrame:CGRectMake(0,0,WAYPOINT_TOUCH_TARGET_SIZE,WAYPOINT_TOUCH_TARGET_SIZE)];
        
        // Set the waypoint label
        WaypointAnnotation *waypointAnnotation = (WaypointAnnotation*)annotation;
        UILabel *label = (UILabel *)[view viewWithTag:LABEL_TAG];
        label.text = [self waypointNumberForAnnotationView: waypointAnnotation.waypoint];
        
        // Add appropriate icon
        //  - we don't just set view.image, as we want a touch target that is larger than the icon itself
        UIImage *icon = nil;
        if ([waypointAnnotation isCurrentWaypointP:currentWaypointNum]) {
            view.centerOffset = CGPointMake(0,0);
            icon = [MiscUtilities image:[UIImage imageNamed:@"13-target.png"]
                              withColor:WAYPOINT_NAV_NEXT_COLOR];
        } else {
            view.centerOffset = CGPointMake(0,-12); // adjust for offset pointer in map marker
            icon = [MiscUtilities image:[UIImage imageNamed:@"07-map-marker.png"]
                              withColor:[waypointAnnotation getColor]];
        }
        UIImageView *imgSubView = [[UIImageView alloc] initWithImage:icon];
        imgSubView.tag = ICON_VIEW_TAG;
        imgSubView.center = [view convertPoint:view.center fromView:view.superview];
        [view addSubview:imgSubView];

        // Provide subclasses with a chance to customize the waypoint annotation view
        [self customizeWaypointAnnotationView:view];
        
        return view;
    }
    
    return nil;
}

- (void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error {
    // FIXME: mark some error
}

- (void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations {
    userPosition = locationManager.location;
}

@end

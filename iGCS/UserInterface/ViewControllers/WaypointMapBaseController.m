//
//  WaypointMapBaseController.m
//  iGCS
//
//  Created by Claudio Natoli on 20/03/13.
//
//

#import "WaypointMapBaseController.h"
#import "MiscUtilities.h"
#import "FillStrokePolyLineView.h"
#import "WaypointAnnotationView.h"

@implementation WaypointMapBaseController

- (instancetype)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];

	// Do any additional setup after loading the view.
    _mapView.delegate = self;
    
    _currentWaypointNum = -1;
    
    _trackMKMapPointsLen = 1000;
    _trackMKMapPoints = malloc(_trackMKMapPointsLen * sizeof(MKMapPoint));
    _numTrackPoints = 0;
    
    draggableWaypointsP = NO;
    
    // Add recognizer for long press gestures
    UILongPressGestureRecognizer *longPressGesture = [[UILongPressGestureRecognizer alloc]
                                                      initWithTarget:self action:@selector(handleLongPressGesture:)];
    longPressGesture.numberOfTapsRequired = 0;
    longPressGesture.numberOfTouchesRequired = 1;
    longPressGesture.minimumPressDuration = 1.0;
    [_mapView addGestureRecognizer:longPressGesture];
    
    // Start listening for location updates
    locationManager = [[CLLocationManager alloc] init];
    locationManager.desiredAccuracy = kCLLocationAccuracyBest;
    locationManager.delegate = self;
    locationManager.distanceFilter = 2.0f;
    [locationManager startUpdatingLocation];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (NSArray*) getWaypointAnnotations {
    return [_mapView.annotations
            filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"(self isKindOfClass: %@)",
                                         [WaypointAnnotation class]]];
}

- (void) removeExistingWaypointAnnotations {
    [_mapView removeAnnotations:[self getWaypointAnnotations]];
}

- (WaypointAnnotation *) getWaypointAnnotation:(NSInteger)waypointSeq {
    NSArray* waypointAnnotations = [self getWaypointAnnotations];
    for (NSUInteger i = 0; i < [waypointAnnotations count]; i++) {
        WaypointAnnotation *waypointAnnotation = (WaypointAnnotation*)waypointAnnotations[i];;
        if ([waypointAnnotation hasMatchingSeq:waypointSeq]) {
            return waypointAnnotation;
        }
    }
    return nil;
}

- (void) resetWaypoints:(WaypointsHolder *)waypoints {
    
    // Clean up existing objects
    [self removeExistingWaypointAnnotations];
    [_mapView removeOverlay:_waypointRoutePolyline];
    
    // Get the nav-specfic waypoints
    WaypointsHolder *navWaypoints = [waypoints navWaypoints];
    NSUInteger numWaypoints = [navWaypoints numWaypoints];
    
    MKMapPoint *navMKMapPoints = malloc(sizeof(MKMapPoint) * numWaypoints);
    
    // Add waypoint annotations, and convert to array of MKMapPoints
    for (NSUInteger i = 0; i < numWaypoints; i++) {
        mavlink_mission_item_t waypoint = [navWaypoints getWaypoint:i];
        CLLocationCoordinate2D coordinate = CLLocationCoordinate2DMake(waypoint.x, waypoint.y);
        
        // Add the annotation
        WaypointAnnotation *annotation = [[WaypointAnnotation alloc] initWithCoordinate:coordinate
                                                                            andWayPoint:waypoint
                                                                                atIndex:[waypoints getIndexOfWaypointWithSeq:waypoint.seq]];
        [_mapView addAnnotation:annotation];
        
        // Construct the MKMapPoint
        navMKMapPoints[i] = MKMapPointForCoordinate(coordinate);
    }
    
    // Add the polyline overlay
    _waypointRoutePolyline = [MKPolyline polylineWithPoints:navMKMapPoints count:numWaypoints];
    [_mapView addOverlay:_waypointRoutePolyline];
    
    // Set the map extents
    MKMapRect bounds = [_waypointRoutePolyline boundingMapRect];
    if (!MKMapRectIsNull(bounds)) {
        // Extend the bounding rect of the polyline slightly
        MKCoordinateRegion region = MKCoordinateRegionForMapRect(bounds);
        region.span.latitudeDelta  = MIN(MAX(region.span.latitudeDelta  * MAP_REGION_PAD_FACTOR, MAP_MINIMUM_ARC),  90);
        region.span.longitudeDelta = MIN(MAX(region.span.longitudeDelta * MAP_REGION_PAD_FACTOR, MAP_MINIMUM_ARC), 180);
        [_mapView setRegion:region animated:YES];
    } else if ([_waypointRoutePolyline pointCount] == 1) {
        // Fallback to a padded box centered on the single waypoint
        CLLocationCoordinate2D coord = MKCoordinateForMapPoint([_waypointRoutePolyline points][0]);
        [_mapView setRegion:MKCoordinateRegionMakeWithDistance(coord, MAP_MINIMUM_PAD, MAP_MINIMUM_PAD) animated:YES];
    }
    [_mapView setNeedsDisplay];
    
    free(navMKMapPoints);
}

- (void)updateWaypointIcon:(WaypointAnnotation*)annotation isSelected:(BOOL)isSelected {
    if (annotation) {
        [WaypointMapBaseController updateWaypointIconFor:(WaypointAnnotationView*)[_mapView viewForAnnotation: annotation]
                                              isSelected:isSelected];
    }
}

- (void) maybeUpdateCurrentWaypoint:(NSInteger)newCurrentWaypointSeq {
    if (_currentWaypointNum != newCurrentWaypointSeq) {
        // We've reached a new waypoint, so...
        NSInteger previousWaypointNum = _currentWaypointNum;
        
        //  first, update the current value (so we get the desired
        // side-effect, from viewForAnnotation, when resetting the waypoints), then...
        _currentWaypointNum = newCurrentWaypointSeq;

        //  reset the previous and new current waypoints
        [self updateWaypointIcon:[self getWaypointAnnotation:previousWaypointNum] isSelected:NO];
        [self updateWaypointIcon:[self getWaypointAnnotation:_currentWaypointNum] isSelected:YES];
    }
}

- (void) makeWaypointsDraggable:(BOOL)_draggableWaypointsP {
    draggableWaypointsP = _draggableWaypointsP;
    
    NSArray* waypointAnnotations = [self getWaypointAnnotations];
    for (NSUInteger i = 0; i < [waypointAnnotations count]; i++) {
        WaypointAnnotation *waypointAnnotation = (WaypointAnnotation*)waypointAnnotations[i];
        
        // See also viewForAnnotation
        MKAnnotationView *av = [_mapView viewForAnnotation:waypointAnnotation];
        [av setCanShowCallout: !draggableWaypointsP];
        [av setDraggable: draggableWaypointsP];
        [av setSelected: draggableWaypointsP];
    }
}

- (void)mapView:(MKMapView *)mapView annotationView:(MKAnnotationView *)annotationView
   didChangeDragState:(MKAnnotationViewDragState)newState
   fromOldState:(MKAnnotationViewDragState)oldState {
    if ([annotationView.annotation isKindOfClass:[WaypointAnnotation class]]) {
        WaypointAnnotation* annot = annotationView.annotation;
        if (newState == MKAnnotationViewDragStateEnding) {
            CLLocationCoordinate2D coord = annot.coordinate;
            [self waypointWithSeq:annot.waypoint.seq wasMovedToLat:coord.latitude andLong:coord.longitude];
        }
    }
    
    // Force the annotationView (which may have been disconnected from its annotation, such as due
    // to an add/remove of waypoint annotation during or on completion of dragging) to close out the drag state.
    if (newState == MKAnnotationViewDragStateEnding || newState == MKAnnotationViewDragStateCanceling) {
        [annotationView setDragState:MKAnnotationViewDragStateNone animated:YES];
    }
}


// FIXME: Ugh. This was a quick and dirty way to promote waypoint changes (due to dragging etc) to
// the subclass (which overrides this method). Adopt a more idomatic pattern for this?
- (void) waypointWithSeq:(NSUInteger)waypointSeq wasMovedToLat:(double)latitude andLong:(double)longitude {
}

// FIXME: consider more efficient (and safe?) ways to do this - see iOS Breadcrumbs sample code
- (void) addToTrack:(CLLocationCoordinate2D)pos {
    MKMapPoint newPoint = MKMapPointForCoordinate(pos);
    
    // Check distance from 0
    if (MKMetersBetweenMapPoints(newPoint, MKMapPointForCoordinate(CLLocationCoordinate2DMake(0, 0))) < 1.0) {
        return;
    }
    
    // Check distance from last point
    if (_numTrackPoints > 0) {
        if (MKMetersBetweenMapPoints(newPoint, _trackMKMapPoints[_numTrackPoints-1]) < 1.0) {
            return;
        }
    }
    
    // Check array bounds
    if (_numTrackPoints == _trackMKMapPointsLen) {
        MKMapPoint *newAlloc = realloc(_trackMKMapPoints, _trackMKMapPointsLen*2 * sizeof(MKMapPoint));
        if (!newAlloc) {
            return;
        }
        _trackMKMapPoints = newAlloc;
        _trackMKMapPointsLen *= 2;
    }
    
    // Add the next coord
    _trackMKMapPoints[_numTrackPoints] = newPoint;
    _numTrackPoints++;
    
    // Clean up existing objects
    [_mapView removeOverlay:_trackPolyline];
    
    _trackPolyline = [MKPolyline polylineWithPoints:_trackMKMapPoints count:_numTrackPoints];
    
    // Add the polyline overlay
    [_mapView addOverlay:_trackPolyline];
    [_mapView setNeedsDisplay];
}

- (MKOverlayView *)mapView:(MKMapView *)mapView viewForOverlay:(id)overlay {
    GCSThemeManager *theme = [GCSThemeManager sharedInstance];
    
    if (overlay == _waypointRoutePolyline) {
        FillStrokePolyLineView *waypointRouteView = [[FillStrokePolyLineView alloc] initWithPolyline:overlay];
        waypointRouteView.strokeColor = [theme waypointLineStrokeColor];
        waypointRouteView.fillColor   = [theme waypointLineFillColor];
        waypointRouteView.lineWidth   = 1;
        waypointRouteView.fillWidth   = 2;
        waypointRouteView.lineCap     = kCGLineCapRound;
        waypointRouteView.lineJoin    = kCGLineJoinRound;
        return waypointRouteView;
    } else if (overlay == _trackPolyline) {
        MKPolylineView *trackView = [[MKPolylineView alloc] initWithPolyline:overlay];
        trackView.fillColor     = [theme trackLineColor];
        trackView.strokeColor   = [theme trackLineColor];
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

+ (void) animateMKAnnotationView:(MKAnnotationView*)view from:(float)from to:(float)to duration:(float)duration {
    CABasicAnimation *scaleAnimation = [CABasicAnimation animationWithKeyPath:@"transform.scale"];
    scaleAnimation.duration = duration;
    scaleAnimation.repeatCount = HUGE_VAL;
    scaleAnimation.autoreverses = YES;
    scaleAnimation.fromValue = @(from);
    scaleAnimation.toValue   = @(to);
    [view.layer addAnimation:scaleAnimation forKey:@"scale"];
}

+ (void)updateWaypointIconFor:(WaypointAnnotationView*)view isSelected:(BOOL)isSelected {
    static const NSInteger ICON_VIEW_TAG = 101;
    UIImage *icon = nil;
    if (isSelected) {
        // Animate the waypoint view
        [WaypointMapBaseController animateMKAnnotationView:view from:1.0 to:1.1 duration:1.0];
        
        // Create target icon
        icon = [MiscUtilities image:[UIImage imageNamed:@"13-target.png"]
                          withColor:[[GCSThemeManager sharedInstance] waypointNavNextColor]];
    } else {
        [view.layer removeAllAnimations];
    }

    // Note: We don't just set view.image, as we want a touch target that is larger than the icon itself
    UIImageView *imgSubView = [[UIImageView alloc] initWithImage:icon];
    imgSubView.tag = ICON_VIEW_TAG;
    imgSubView.center = [view convertPoint:view.center fromView:view.superview];
    
    // Remove existing icon subview (if any) and add the new icon
    [[view viewWithTag:ICON_VIEW_TAG] removeFromSuperview];
    [view addSubview:imgSubView];
    [view sendSubviewToBack:imgSubView];
    
}

- (MKAnnotationView *)mapView:(MKMapView *)theMapView viewForAnnotation:(id <MKAnnotation>)annotation {
    static const NSInteger LABEL_TAG = 100;
    
    // If it's the user location, just return nil.
    if ([annotation isKindOfClass:[MKUserLocation class]])
        return nil;
    
    // Handle our custom annotations
    //
    if ([annotation isKindOfClass:[WaypointAnnotation class]]) {
        static NSString* const identifier = @"WAYPOINT";
        // FIXME: Dequeuing disabled due to issue observed on iOS7.1 only - cf IGCS-110
        //MKAnnotationView *view = (MKAnnotationView*) [map dequeueReusableAnnotationViewWithIdentifier:identifier];
        WaypointAnnotationView *view = nil;
        if (view) {
            view.annotation = annotation;
        } else {
            view = [[WaypointAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:identifier];
            [view setFrame:CGRectMake(0,0,WAYPOINT_TOUCH_TARGET_SIZE,WAYPOINT_TOUCH_TARGET_SIZE)];
            [view setBackgroundColor:[UIColor clearColor]];

            UILabel *label = [[UILabel alloc]  initWithFrame:CGRectMake(WAYPOINT_TOUCH_TARGET_SIZE/2, -WAYPOINT_TOUCH_TARGET_SIZE/3, 32, 32)];
            label.backgroundColor = [UIColor clearColor];
            label.textColor = [UIColor whiteColor];
            label.tag = LABEL_TAG;
            label.layer.shadowColor = [[UIColor blackColor] CGColor];
            label.layer.shadowOffset = CGSizeMake(1.0f, 1.0f);
            label.layer.shadowOpacity = 1.0f;
            label.layer.shadowRadius  = 1.0f;
            
            [view addSubview:label];
        }
        
        view.enabled = YES;
        
        // See also makeWaypointsDraggable
        view.canShowCallout = !draggableWaypointsP;
        view.draggable = draggableWaypointsP;
        view.selected = draggableWaypointsP;
        
        // Set the waypoint label
        WaypointAnnotation *waypointAnnotation = (WaypointAnnotation*)annotation;
        UILabel *label = (UILabel *)[view viewWithTag:LABEL_TAG];
        label.text = [self waypointNumberForAnnotationView: waypointAnnotation.waypoint];
        
        // Add appropriate icon
        [WaypointMapBaseController updateWaypointIconFor:view isSelected:[waypointAnnotation hasMatchingSeq:_currentWaypointNum]];

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

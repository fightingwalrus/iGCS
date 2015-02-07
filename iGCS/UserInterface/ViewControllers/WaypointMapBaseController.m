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

#import "GCSDataManager.h"

@interface WaypointMapBaseController ()
@property (nonatomic, strong) MKPolyline *homeToWP1Polyline;
@property (nonatomic, strong) MKPolyline *waypointRoutePolyline;
@property (nonatomic, assign) WaypointSeqOpt currentWaypointNum;

@property (nonatomic, strong) MKPolyline *trackPolyline;
@property (nonatomic, assign) MKMapPoint *trackMKMapPoints;
@property (nonatomic, assign) NSUInteger trackMKMapPointsLen;
@property (nonatomic, assign) NSUInteger numTrackPoints;

@property (nonatomic, assign) BOOL draggableWaypoints;
@end

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
    self.mapView.delegate = self;
    
    self.currentWaypointNum = WAYPOINTSEQ_NONE;
    
    self.trackMKMapPointsLen = 1000;
    self.trackMKMapPoints = malloc(self.trackMKMapPointsLen * sizeof(MKMapPoint));
    self.numTrackPoints = 0;
    
    self.draggableWaypoints = NO;
    
    // Add recognizer for long press gestures
    UILongPressGestureRecognizer *longPressGesture = [[UILongPressGestureRecognizer alloc]
                                                      initWithTarget:self action:@selector(handleLongPressGesture:)];
    longPressGesture.numberOfTapsRequired = 0;
    longPressGesture.numberOfTouchesRequired = 1;
    longPressGesture.minimumPressDuration = 1.0;
    [self.mapView addGestureRecognizer:longPressGesture];
    
    // Start with locateUser button disabled
    [self.locateUser setEnabled:NO];
    [self.locateUser setImage:[MiscUtilities image:[UIImage imageNamed:@"193-location-arrow.png"]
                                         withColor:[[GCSThemeManager sharedInstance] appTintColor]]
                     forState:UIControlStateNormal];
    [self.locateUser setShowsTouchWhenHighlighted:YES];
    
    // Start listening for location updates
    _locationManager = [[CLLocationManager alloc] init];
    self.locationManager.desiredAccuracy = kCLLocationAccuracyBest;
    self.locationManager.delegate = self;
    self.locationManager.distanceFilter = 2.0f;
    
    // Request permission (iOS8+)
    if ([self.locationManager respondsToSelector:@selector(requestWhenInUseAuthorization)]) {
        [self.locationManager requestWhenInUseAuthorization];
    }
    [self.locationManager startUpdatingLocation];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    // Change to the stashed camera
    //  - viewWillAppear would be preferred, however the order of viewWillAppear/Disappear
    //    between the two respective views is not guaranteed.
    if ([GCSDataManager sharedInstance].lastViewedMapCamera) {
        [self.mapView setCamera:[GCSDataManager sharedInstance].lastViewedMapCamera animated:NO];
    }
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    
    // Stash the current camera
    [GCSDataManager sharedInstance].lastViewedMapCamera = self.mapView.camera;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (NSArray*) getWaypointAnnotations {
    return [self.mapView.annotations
            filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"(self isKindOfClass: %@)",
                                         [WaypointAnnotation class]]];
}

- (void) removeExistingWaypointAnnotations {
    [self.mapView removeAnnotations:[self getWaypointAnnotations]];
}

- (WaypointAnnotation *) getWaypointAnnotation:(WaypointSeq)waypointSeq {
    NSArray* waypointAnnotations = [self getWaypointAnnotations];
    for (NSUInteger i = 0; i < [waypointAnnotations count]; i++) {
        WaypointAnnotation *waypointAnnotation = (WaypointAnnotation*)waypointAnnotations[i];;
        if ([waypointAnnotation hasMatchingSeq:waypointSeq]) {
            return waypointAnnotation;
        }
    }
    return nil;
}

- (void) replaceMission:(WaypointsHolder*)mission {
    
    // Clean up existing objects
    [self removeExistingWaypointAnnotations];
    [self.mapView removeOverlay:self.homeToWP1Polyline];
    [self.mapView removeOverlay:self.waypointRoutePolyline];
    
    // Get the nav-specfic waypoints
    WaypointsHolder *navWaypoints = [mission navWaypoints];
    NSUInteger numWaypoints = [navWaypoints numWaypoints];
    
    // Build array of CLLocationCoordinate2D, and add waypoint annotations
    CLLocationCoordinate2D *coords = malloc(sizeof(CLLocationCoordinate2D) * numWaypoints);
    assert(coords);
    for (NSUInteger i = 0; i < numWaypoints; i++) {
        mavlink_mission_item_t waypoint = [navWaypoints getWaypoint:i];
        coords[i] = CLLocationCoordinate2DMake(waypoint.x, waypoint.y);
        
        // Add the annotation
        WaypointAnnotation *annotation = [[WaypointAnnotation alloc] initWithCoordinate:coords[i]
                                                                            andWayPoint:waypoint
                                                                                atIndex:[mission getIndexOfWaypointWithSeq:waypoint.seq]];
        [self.mapView addAnnotation:annotation];
    }
    
    // Add the polyline overlays
    self.homeToWP1Polyline = [MKPolyline polylineWithCoordinates:coords
                                                           count:MAX(numWaypoints,2)]; // use at most the first 2 points
    self.waypointRoutePolyline = (numWaypoints <= 1) ? nil : [MKPolyline polylineWithCoordinates:coords+1
                                                                                           count:numWaypoints-1]; // skip HOME/0 waypoint
    [self.mapView addOverlay:self.homeToWP1Polyline];
    if (self.waypointRoutePolyline) {
        [self.mapView addOverlay:self.waypointRoutePolyline];
    }
    
    // Set the map extents
    MKMapRect bounds = [[MKPolygon polygonWithCoordinates:coords count:numWaypoints] boundingMapRect];
    if (!MKMapRectIsNull(bounds)) {
        // Extend the bounding rect of the polyline slightly
        MKCoordinateRegion region = MKCoordinateRegionForMapRect(bounds);
        region.span.latitudeDelta  = MIN(MAX(region.span.latitudeDelta  * MAP_REGION_PAD_FACTOR, MAP_MINIMUM_ARC),  90);
        region.span.longitudeDelta = MIN(MAX(region.span.longitudeDelta * MAP_REGION_PAD_FACTOR, MAP_MINIMUM_ARC), 180);
        [self.mapView setRegion:region animated:YES];
    } else if ([self.waypointRoutePolyline pointCount] == 1) {
        // Fallback to a padded box centered on the single waypoint
        CLLocationCoordinate2D coord = MKCoordinateForMapPoint([self.waypointRoutePolyline points][0]);
        [self.mapView setRegion:MKCoordinateRegionMakeWithDistance(coord, MAP_MINIMUM_PAD, MAP_MINIMUM_PAD) animated:YES];
    }
    [self.mapView setNeedsDisplay];
    
    free(coords);
}

- (void)updateWaypointIconAtSeq:(WaypointSeqOpt)seq isSelected:(BOOL)isSelected {
    if (seq == WAYPOINTSEQ_NONE) return;
    
    WaypointAnnotation* annotation = [self getWaypointAnnotation:seq];
    if (annotation) {
        [WaypointMapBaseController updateWaypointIconFor:(WaypointAnnotationView*)[self.mapView viewForAnnotation: annotation]
                                              isSelected:isSelected];
    }
}

- (void) maybeUpdateCurrentWaypoint:(WaypointSeqOpt)newCurrentWaypointSeq {
    if (self.currentWaypointNum != newCurrentWaypointSeq) {
        // We've reached a new waypoint, so...
        WaypointSeqOpt previousWaypointNum = self.currentWaypointNum;
        
        //  first, update the current value (so we get the desired
        // side-effect, from viewForAnnotation, when resetting the waypoints), then...
        self.currentWaypointNum = newCurrentWaypointSeq;

        //  reset the previous and new current waypoints
        [self updateWaypointIconAtSeq:previousWaypointNum isSelected:NO];
        [self updateWaypointIconAtSeq:self.currentWaypointNum isSelected:YES];
    }
}

- (void) makeWaypointsDraggable:(BOOL)draggableWaypoints {
    self.draggableWaypoints = draggableWaypoints;
    
    NSArray* waypointAnnotations = [self getWaypointAnnotations];
    for (NSUInteger i = 0; i < [waypointAnnotations count]; i++) {
        WaypointAnnotation *waypointAnnotation = (WaypointAnnotation*)waypointAnnotations[i];
        
        // See also viewForAnnotation
        MKAnnotationView *av = [self.mapView viewForAnnotation:waypointAnnotation];
        [av setCanShowCallout: !draggableWaypoints];
        [av setDraggable: draggableWaypoints];
        [av setSelected: draggableWaypoints];
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
- (void) waypointWithSeq:(WaypointSeq)waypointSeq wasMovedToLat:(double)latitude andLong:(double)longitude {
}

// FIXME: consider more efficient (and safe?) ways to do this - see iOS Breadcrumbs sample code
- (void) addToTrack:(CLLocationCoordinate2D)pos {
    MKMapPoint newPoint = MKMapPointForCoordinate(pos);
    
    // Check distance from 0
    if (MKMetersBetweenMapPoints(newPoint, MKMapPointForCoordinate(CLLocationCoordinate2DMake(0, 0))) < 1.0) {
        return;
    }
    
    // Check distance from last point
    if (self.numTrackPoints > 0) {
        if (MKMetersBetweenMapPoints(newPoint, self.trackMKMapPoints[self.numTrackPoints-1]) < 1.0) {
            return;
        }
    }
    
    // Check array bounds
    if (self.numTrackPoints == self.trackMKMapPointsLen) {
        MKMapPoint *newAlloc = realloc(self.trackMKMapPoints, self.trackMKMapPointsLen*2 * sizeof(MKMapPoint));
        if (!newAlloc) {
            return;
        }
        self.trackMKMapPoints = newAlloc;
        self.trackMKMapPointsLen *= 2;
    }
    
    // Add the next coord
    self.trackMKMapPoints[self.numTrackPoints] = newPoint;
    self.numTrackPoints++;
    
    // Clean up existing objects
    [self.mapView removeOverlay:self.trackPolyline];
    
    self.trackPolyline = [MKPolyline polylineWithPoints:self.trackMKMapPoints count:self.numTrackPoints];
    
    // Add the polyline overlay
    [self.mapView addOverlay:self.trackPolyline];
    [self.mapView setNeedsDisplay];
}

- (MKOverlayView *)mapView:(MKMapView *)mapView viewForOverlay:(id)overlay {
    GCSThemeManager *theme = [GCSThemeManager sharedInstance];
    
    if (overlay == self.waypointRoutePolyline) {
        FillStrokePolyLineView *waypointRouteView = [[FillStrokePolyLineView alloc] initWithPolyline:overlay];
        waypointRouteView.strokeColor = [theme waypointLineStrokeColor];
        waypointRouteView.fillColor   = [theme waypointLineFillColor];
        waypointRouteView.lineWidth   = 1;
        waypointRouteView.fillWidth   = 2;
        waypointRouteView.lineCap     = kCGLineCapRound;
        waypointRouteView.lineJoin    = kCGLineJoinRound;
        return waypointRouteView;
    } else if (overlay == self.trackPolyline) {
        MKPolylineView *trackView = [[MKPolylineView alloc] initWithPolyline:overlay];
        trackView.fillColor     = [theme trackLineColor];
        trackView.strokeColor   = [theme trackLineColor];
        trackView.lineWidth     = 2;
        return trackView;
    }
    
    return nil;
}

- (NSString*) waypointLabelForAnnotationView:(mavlink_mission_item_t)item {
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

            UILabel *label = [[UILabel alloc]  initWithFrame:CGRectMake(WAYPOINT_TOUCH_TARGET_SIZE/2, -WAYPOINT_TOUCH_TARGET_SIZE/3, 48, 32)];
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
        view.canShowCallout = !self.draggableWaypoints;
        view.draggable = self.draggableWaypoints;
        view.selected = self.draggableWaypoints;
        
        // Set the waypoint label
        WaypointAnnotation *waypointAnnotation = (WaypointAnnotation*)annotation;
        BOOL isHome = (waypointAnnotation.waypoint.seq == 0); // handle the HOME/0 waypoint
        UILabel *label = (UILabel *)[view viewWithTag:LABEL_TAG];
        label.text = isHome ? @"Home" : [self waypointLabelForAnnotationView: waypointAnnotation.waypoint];
        
        // Add appropriate icon
        BOOL isSelected = (self.currentWaypointNum != WAYPOINTSEQ_NONE) && [waypointAnnotation hasMatchingSeq:self.currentWaypointNum];
        [WaypointMapBaseController updateWaypointIconFor:view isSelected:isSelected];

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
    CLLocation *location = self.locationManager.location;
    NSTimeInterval age = -[location.timestamp timeIntervalSinceNow];
    DDLogDebug(@"locationManager didUpdateLocations: %@ (age = %0.1fs)", location.description, age);
    if (age > 5.0) return;
    
    self.userPosition = location;
    [self.locateUser setEnabled:(location.horizontalAccuracy >= 0 && location.horizontalAccuracy <= kCLLocationAccuracyHundredMeters)];
}

- (void) zoomInOnUser:(id)sender {
    [self.mapView setRegion:MKCoordinateRegionMakeWithDistance(self.userPosition.coordinate, MAP_MINIMUM_PAD, MAP_MINIMUM_PAD) animated:YES];
}

@end

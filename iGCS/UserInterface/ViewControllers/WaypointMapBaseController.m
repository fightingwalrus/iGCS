//
//  WaypointMapBaseController.m
//  iGCS
//
//  Created by Claudio Natoli on 20/03/13.
//
//

#import "WaypointMapBaseController.h"

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
        WaypointAnnotation *annotation = [[WaypointAnnotation alloc] initWithCoordinate:coordinate andWayPoint:waypoint];
        [map addAnnotation:annotation];
        
        // Construct the MKMapPoint
        navMKMapPoints[i] = MKMapPointForCoordinate(coordinate);
    }
    
    // Add the polyline overlay
    waypointRoutePolyline = [MKPolyline polylineWithPoints:navMKMapPoints count:numWaypoints];
    [map addOverlay:waypointRoutePolyline];
    
    // Set the map extents
    if ([_waypoints numWaypoints] > 1) {
        // FIXME: and if there is only 1?
        // FIXME: and perhaps only change the view if a point is outside the existing map view? (i.e preserve current user zoom)
        MKMapRect bounds = [waypointRoutePolyline boundingMapRect];
        [map setVisibleMapRect:bounds edgePadding:UIEdgeInsetsMake(40,40,40,40) animated:YES];
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

- (MKAnnotationView *)mapView:(MKMapView *)theMapView viewForAnnotation:(id <MKAnnotation>)annotation
{
    // If it's the user location, just return nil.
    if ([annotation isKindOfClass:[MKUserLocation class]])
        return nil;
    
    // Handle our custom annotations
    //
    if ([annotation isKindOfClass:[WaypointAnnotation class]]) {
        
        NSString* identifier = @"WAYPOINT";
        MKAnnotationView *view = (MKAnnotationView*) [map dequeueReusableAnnotationViewWithIdentifier:identifier];
        if (view == nil) {
            view = [[MKAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:identifier];
        } else {
            view.annotation = annotation;
        }
        
        WaypointAnnotation *waypointAnnotation = (WaypointAnnotation*)annotation;
        
        view.enabled = YES;
        
        // See also makeWaypointsDraggable
        view.canShowCallout = !draggableWaypointsP;
        view.draggable = draggableWaypointsP;
        view.selected = draggableWaypointsP;

        // FIXME: memoize view.image generation
        if ([waypointAnnotation isCurrentWaypointP:currentWaypointNum]) {
            view.centerOffset = CGPointMake(0,0);
            view.image = [WaypointMapBaseController image:[UIImage imageNamed:@"13-target.png"]
                                           withColor:WAYPOINT_NAV_NEXT_COLOR];
        } else {
            view.centerOffset = CGPointMake(0,-12); // adjust for offset pointer in map marker
            view.image = [WaypointMapBaseController image:[UIImage imageNamed:@"07-map-marker.png"]
                                           withColor:[waypointAnnotation getColor]];
        }
        return view;
    }
    
    return nil;
}


// FIXME: move to some "utils" file
+ (UIImage*)imageWithImage:(UIImage*)image scaledToSize:(CGSize)newSize rotation:(double)ang
{
    UIGraphicsBeginImageContext( newSize );
    //[image drawInRect:CGRectMake(0,0,newSize.width,newSize.height)];
    
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGAffineTransform transform = CGAffineTransformIdentity;
    transform = CGAffineTransformTranslate(transform, newSize.width/2, newSize.height/2);
    transform = CGAffineTransformRotate(transform, ang);
    CGContextConcatCTM(context, transform);
    
    [image drawInRect:CGRectMake(-newSize.width/2,-newSize.width/2,newSize.width,newSize.height)];
    
    UIImage* newImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return newImage;
}

// FIXME: move to some "utils" file
// ref: http://coffeeshopped.com/2010/09/iphone-how-to-dynamically-color-a-uiimage
+ (UIImage *)image:(UIImage*)img withColor:(UIColor*)color {
    
    
    // begin a new image context, to draw our colored image onto
    UIGraphicsBeginImageContext(img.size);
    
    // get a reference to that context we created
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    // translate/flip the graphics context (for transforming from CG* coords to UI* coords
    CGContextTranslateCTM(context, 0, img.size.height);
    CGContextScaleCTM(context, 1.0, -1.0);
    CGRect rect = CGRectMake(0, 0, img.size.width, img.size.height);
    CGContextDrawImage(context, rect, img.CGImage);
    
    // Set a mask that matches the shape of the image, then draw as black
    [[UIColor blackColor] setFill];
    CGContextSetBlendMode(context, kCGBlendModeDarken);
    CGContextClipToMask(context, rect, img.CGImage);
    CGContextAddRect(context, rect);
    CGContextDrawPath(context,kCGPathFill);
    
    // Now replace with the desired color
    [color setFill];
    CGContextSetBlendMode(context, kCGBlendModeLighten);
    CGContextClipToMask(context, rect, img.CGImage);
    CGContextAddRect(context, rect);
    CGContextDrawPath(context,kCGPathFill);
    
    // generate a new UIImage from the graphics context we drew onto
    UIImage *coloredImg = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    //return the color-burned image
    return coloredImg;
}

@end

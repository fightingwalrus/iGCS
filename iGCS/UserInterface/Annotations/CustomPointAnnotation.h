//
//  CustomPointAnnotation.h
//  iGCS
//
//  Created by Claudio Natoli on 7/07/13.
//
//
#import <Foundation/Foundation.h>
#import <MapKit/MapKit.h>

@interface CustomPointAnnotation : NSObject <MKAnnotation> {
    CLLocationCoordinate2D _coordinate;
    NSString *_title;
    NSString *_viewIdentifer;
    UIColor  *_color;
}

@property (nonatomic, readonly) CLLocationCoordinate2D coordinate;
@property (nonatomic, readonly, copy) NSString *title;
@property (nonatomic, readonly, copy) NSString *viewIdentifier;
@property (nonatomic, readonly, copy) UIColor  *color;

@end

//
//  CustomPointAnnotation.h
//  iGCS
//
//  Created by Claudio Natoli on 7/07/13.
//
//
#import <Foundation/Foundation.h>
#import <MapKit/MapKit.h>

@interface CustomPointAnnotation : NSObject <MKAnnotation>

@property (nonatomic, readonly) CLLocationCoordinate2D coordinate;
@property (nonatomic, readonly, copy) NSString *title;
@property (nonatomic, readonly, copy) NSString *viewIdentifier;
@property (nonatomic, readonly, copy) UIColor  *color;
@property (nonatomic, readonly) BOOL doAnimation;

- (instancetype)initWithCoordinate:(CLLocationCoordinate2D)coordinate
                             title:(NSString*)title
                            viewID:(NSString*)viewIdentifier
                             color:(UIColor*)color
                      andAnimation:(BOOL)doAnimation;

@end

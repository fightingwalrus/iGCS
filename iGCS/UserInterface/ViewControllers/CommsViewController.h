//
//  SecondViewController.h
//  iGCS
//
//  Created by Claudio Natoli on 5/02/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MavLinkPacketHandler.h"
#import "CorePlot-CocoaTouch.h"

@class DataRateRecorder;

@interface CommsViewController : UIViewController <MavLinkPacketHandler, CPTPlotDataSource> {
    CPTXYGraph *_dataRateGraph;
}

@property (nonatomic, retain) IBOutlet UITextView  *attitudeTextView;
@property (nonatomic, retain) IBOutlet UITextView  *vfrHUDTextView;
@property (nonatomic, retain) IBOutlet UITextView  *gpsIntTextView;
@property (nonatomic, retain) IBOutlet UITextView  *gpsRawTextView;
@property (nonatomic, retain) IBOutlet UITextView  *sysStatusView;

@property (nonatomic, retain) IBOutlet UITextView  *gpsStatusView;
@property (nonatomic, retain) IBOutlet UITextView  *navControllerOutputTextView;

@property (nonatomic, retain) IBOutlet UITextView  *defaultTextView;

@property (nonatomic, retain) IBOutlet UIButton *connectionStatus;

@property (nonatomic, retain) IBOutlet CPTGraphHostingView *dataRateGraphView;

@property (nonatomic, weak) DataRateRecorder *dataRateRecorder;

- (void) setCableConnectionStatus:(BOOL) connectedP;

@end

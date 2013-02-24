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

#define NUM_KPBS_TICKS_PER_SECOND     8
#define NUM_KBPS_DATA_POINTS        (61 * NUM_KPBS_TICKS_PER_SECOND)

@interface CommsViewController : UIViewController <MavLinkPacketHandler, CPTPlotDataSource> {
    CPTXYGraph *dataRateGraph;
    
    NSTimer *kBperSecondTimer;
    double kBperSecond[NUM_KBPS_DATA_POINTS];
    unsigned int kBperSecondCircularIndex;
    unsigned int numBytesSinceTick;
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

- (void) bytesReceived:(unsigned int)numBytes;

- (void) setCableConnectionStatus:(bool) connectedP;


- (void)numBytesTimerTick:(NSTimer *)timer;

- (IBAction)bluetoothCentralClicked:(id)sender;
- (IBAction)bluetoothPeripheralClicked:(id)sender;

@end

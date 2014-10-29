//
//  SecondViewController.m
//  iGCS
//
//  Created by Claudio Natoli on 5/02/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "CommsViewController.h"
#import "GaugeViewCommon.h"

#import "CommController.h"
#import "DataRateRecorder.h"

@implementation CommsViewController

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

#pragma mark - View lifecycle

- (void)viewDidLoad {
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
}

- (void) setDataRateRecorder:(DataRateRecorder *)dataRateRecorder {
    _dataRateRecorder = dataRateRecorder;
    
    _dataRateGraph = [[CPTXYGraph alloc] initWithFrame: self.dataRateGraphView.bounds];
    
    CPTGraphHostingView *hostingView = (CPTGraphHostingView *)self.dataRateGraphView;
    hostingView.hostedGraph = _dataRateGraph;
    
    // Setup initial plot ranges
    CPTXYPlotSpace *plotSpace = (CPTXYPlotSpace *)_dataRateGraph.defaultPlotSpace;
    plotSpace.xRange = [CPTPlotRange plotRangeWithLocation:CPTDecimalFromFloat(0.0)
                                                    length:CPTDecimalFromFloat([_dataRateRecorder maxDurationInSeconds])];
    plotSpace.yRange = [CPTPlotRange plotRangeWithLocation:CPTDecimalFromFloat(0.0)
                                                    length:CPTDecimalFromFloat(1.0)];
    
    // Setup axes options
    CPTMutableLineStyle *lineStyle = [CPTMutableLineStyle lineStyle];
    lineStyle.lineColor = [CPTColor whiteColor];
    
    NSNumberFormatter *xAxisFormatter = [[NSNumberFormatter alloc] init];
    xAxisFormatter.minimumIntegerDigits  = 1;
    xAxisFormatter.maximumFractionDigits = 0;
    
    NSNumberFormatter *yAxisFormatter = [[NSNumberFormatter alloc] init];
    yAxisFormatter.minimumIntegerDigits  = 1;
    yAxisFormatter.minimumFractionDigits = 2;
    yAxisFormatter.maximumFractionDigits = 2;
    
    CPTMutableTextStyle *textStyle = [CPTMutableTextStyle textStyle];
    textStyle.fontSize = 13.0f;
    textStyle.color    = [CPTColor whiteColor];
    
    CPTXYAxisSet *axisSet = (CPTXYAxisSet*)_dataRateGraph.axisSet;
    
    CPTXYAxis *xAxis = axisSet.xAxis;
    lineStyle.lineWidth = 2.0f;
    xAxis.axisLineStyle         = lineStyle;
    xAxis.majorTickLineStyle    = lineStyle;
    xAxis.majorIntervalLength   = CPTDecimalFromDouble(10.0);
    xAxis.majorTickLength       = 5.0f;
    lineStyle.lineWidth = 1.0f;
    xAxis.minorTickLineStyle    = lineStyle;
    xAxis.minorTicksPerInterval = 10;
    xAxis.minorTickLength       = 2.0f;
    xAxis.labelOffset    = 0.0f;
    xAxis.labelingPolicy = CPTAxisLabelingPolicyFixedInterval;
    xAxis.labelTextStyle = textStyle;
    xAxis.labelFormatter = xAxisFormatter;
    
    CPTXYAxis *yAxis = axisSet.yAxis;
    lineStyle.lineWidth = 2.0f;
    yAxis.axisLineStyle         = lineStyle;
    yAxis.majorTickLineStyle    = lineStyle;
    yAxis.majorIntervalLength   = CPTDecimalFromDouble(1024.0f);
    yAxis.majorTickLength       = 5.0f;
    lineStyle.lineWidth = 1.0f;
    yAxis.minorTickLineStyle    = lineStyle;
    yAxis.minorTicksPerInterval = 10;
    yAxis.minorTickLength       = 2.0f;
    yAxis.labelOffset    = 0.0f;
    yAxis.labelingPolicy = CPTAxisLabelingPolicyAutomatic;
    yAxis.labelTextStyle = textStyle;
    yAxis.labelFormatter = yAxisFormatter;
    yAxis.title = @"kB/s";
    yAxis.titleTextStyle = textStyle;
    
    // Create the plot object
    CPTScatterPlot *dateRatePlot = [[CPTScatterPlot alloc] initWithFrame:_dataRateGraph.hostingView.bounds];
    dateRatePlot.identifier = @"Data Rate Plot";
    dateRatePlot.dataSource = self;
    lineStyle.lineWidth = 1.0f;
    lineStyle.lineColor = [CPTColor colorWithCGColor:[[GCSThemeManager sharedInstance] appTintColor].CGColor];
    
    dateRatePlot.dataLineStyle = lineStyle;
    dateRatePlot.plotSymbol = CPTPlotSymbolTypeNone;
    [_dataRateGraph addPlot:dateRatePlot];
    
    // Position the plotArea within the plotAreaFrame, and the plotAreaFrame within the graph
    _dataRateGraph.fill = [[CPTFill alloc] initWithColor: [CPTColor blackColor]];
    _dataRateGraph.plotAreaFrame.paddingTop    = 10;
    _dataRateGraph.plotAreaFrame.paddingBottom = 20;
    _dataRateGraph.plotAreaFrame.paddingLeft   = 45;
    _dataRateGraph.plotAreaFrame.paddingRight  = 20;
    _dataRateGraph.paddingTop    = 0;
    _dataRateGraph.paddingBottom = 0;
    _dataRateGraph.paddingLeft   = 5;
    _dataRateGraph.paddingRight  = 5;
    
    // Listen to data recorder ticks
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(onDataRateUpdate:)
                                                 name:GCSDataRecorderTick
                                               object:_dataRateRecorder];
}

- (void)viewDidUnload {
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
}

- (void)viewWillDisappear:(BOOL)animated {
	[super viewWillDisappear:animated];
}

- (void)viewDidDisappear:(BOOL)animated {
	[super viewDidDisappear:animated];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    // Return YES for supported orientations
    return YES;
}

- (void) setCableConnectionStatus: (BOOL) connectedP {
    // Change the connection status button
    [_connectionStatus setTitle:(connectedP ? @"ON" : @"OFF") forState:UIControlStateNormal];
    [_connectionStatus setHighlighted:connectedP]; // FIXME: red/green would be nicer
}

- (void) handlePacket:(mavlink_message_t*)msg {
    NSAssert([NSThread isMainThread], @"handlePacket called on non-main thread");    
    // FIXME: Ugh - forcing view load here to ensure the sub UITextView is already loaded. Make nicer.
    if (!self.defaultTextView) {
        [self loadView];
    }
    
    static NSUInteger packetCount = 0;
    packetCount++;
    
    switch (msg->msgid) {
        case MAVLINK_MSG_ID_ATTITUDE:
            [_attitudeTextView setText:msgToNSString(msg, YES)];
            break;
            
        case MAVLINK_MSG_ID_VFR_HUD:
            [_vfrHUDTextView setText:msgToNSString(msg, YES)];
            break;
     
        case MAVLINK_MSG_ID_GLOBAL_POSITION_INT:
            [_gpsIntTextView setText:msgToNSString(msg, YES)];
            break;
            
        case MAVLINK_MSG_ID_GPS_RAW_INT:
            [_gpsRawTextView setText:msgToNSString(msg, YES)];
            break;
            
        case MAVLINK_MSG_ID_SYS_STATUS:
            [_sysStatusView setText:msgToNSString(msg, YES)];
            break;
            
        case MAVLINK_MSG_ID_GPS_STATUS:
            [_gpsStatusView setText:msgToNSString(msg, YES)];
            break;
            
        case MAVLINK_MSG_ID_NAV_CONTROLLER_OUTPUT:
            [_navControllerOutputTextView setText:msgToNSString(msg, YES)];
            break;
            
        default: {
            // Append string representation of msg
            NSString *newText = [_defaultTextView.text stringByAppendingFormat:@"%7u: %@\n", packetCount, msgToNSString(msg,NO)];
            // Limit length of text buffer
            if (newText.length > 2560)
                newText = [newText substringFromIndex:(newText.length-2560)];
            [_defaultTextView setText:newText];
            [_defaultTextView scrollRangeToVisible:NSMakeRange([_defaultTextView.text length], 0)];
        }
            break;
    }
}

// CorePlot protocol implementation
-(void) onDataRateUpdate:(NSNotification*)notification {
    // Reset the y-axis range and reload the graph data
    CPTXYPlotSpace *plotSpace = (CPTXYPlotSpace *)_dataRateGraph.defaultPlotSpace;
    plotSpace.yRange = [CPTPlotRange plotRangeWithLocation:CPTDecimalFromFloat(-0.01)
                                                    length:CPTDecimalFromFloat(MAX([_dataRateRecorder maxValue]*1.1, 1))];
    [_dataRateGraph reloadData];
}

-(NSUInteger) numberOfRecordsForPlot:(CPTPlot *)plot {
    return [_dataRateRecorder count];
}

-(NSNumber *) numberForPlot:(CPTPlot *)plot field:(NSUInteger)fieldEnum
                recordIndex:(NSUInteger)index {
    return @((fieldEnum == CPTScatterPlotFieldX) ? [_dataRateRecorder secondsSince:index] :[_dataRateRecorder valueAt:index]);
}

@end

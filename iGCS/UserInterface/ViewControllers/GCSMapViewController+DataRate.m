//
//  GCSMapViewController+DataRate.m
//  iGCS
//
//  Created by Claudio Natoli on 22/10/2014.
//
//

#import <objc/runtime.h>
#import "GCSMapViewController+DataRate.h"

@implementation GCSMapViewController (DataRate)

@dynamic dataRateGraph;
@dynamic dataRateRecorder;

- (CPTXYGraph*) dataRateGraph {
    return (CPTXYGraph*)objc_getAssociatedObject(self, @selector(dataRateGraph));
}

- (void) setDataRateGraph:(CPTXYGraph*)dataRateGraph {
    objc_setAssociatedObject(self, @selector(dataRateGraph), dataRateGraph, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}
    
- (DataRateRecorder*) dataRateRecorder {
    return (DataRateRecorder*)objc_getAssociatedObject(self, @selector(dataRateRecorder));
}

- (void) setDataRateRecorder:(DataRateRecorder*)dataRateRecorder {
    objc_setAssociatedObject(self, @selector(dataRateRecorder), dataRateRecorder, OBJC_ASSOCIATION_ASSIGN);
    
    // Setup the sparkline view
    self.dataRateGraph = [[CPTXYGraph alloc] initWithFrame: self.dataRateSparklineView.bounds];
    self.dataRateSparklineView.hostedGraph = self.dataRateGraph;
    
    // Setup initial plot ranges
    CPTXYPlotSpace *plotSpace = (CPTXYPlotSpace *)self.dataRateGraph.defaultPlotSpace;
    plotSpace.xRange = [CPTPlotRange plotRangeWithLocation:CPTDecimalFromFloat(0.0)
                                                    length:CPTDecimalFromFloat([self.dataRateRecorder maxDurationInSeconds]/6.0)];
    plotSpace.yRange = [CPTPlotRange plotRangeWithLocation:CPTDecimalFromFloat(0.0)
                                                    length:CPTDecimalFromFloat(1.0)];
    
    // Hide the axes
    CPTXYAxisSet *axisSet = (CPTXYAxisSet*)self.dataRateGraph.axisSet;
    axisSet.xAxis.hidden = axisSet.yAxis.hidden = YES;
    axisSet.xAxis.labelingPolicy = axisSet.yAxis.labelingPolicy = CPTAxisLabelingPolicyNone;
    
    // Create the plot object
    CPTScatterPlot *dateRatePlot = [[CPTScatterPlot alloc] initWithFrame:self.dataRateGraph.hostingView.bounds];
    dateRatePlot.identifier = @"Data Rate Sparkline";
    dateRatePlot.dataSource = self;
    
    CPTMutableLineStyle *lineStyle = [CPTMutableLineStyle lineStyle];
    lineStyle.lineWidth = 1.0f;
    lineStyle.lineColor = [CPTColor colorWithCGColor:[[GCSThemeManager sharedInstance] appTintColor].CGColor];
    dateRatePlot.dataLineStyle = lineStyle;
    
    dateRatePlot.plotSymbol = CPTPlotSymbolTypeNone;
    [self.dataRateGraph addPlot:dateRatePlot];
    
    // Position the plotArea within the plotAreaFrame, and the plotAreaFrame within the graph
    self.dataRateGraph.fill = [[CPTFill alloc] initWithColor: [CPTColor clearColor]];
    self.dataRateGraph.plotAreaFrame.paddingTop    = 0;
    self.dataRateGraph.plotAreaFrame.paddingBottom = 0;
    self.dataRateGraph.plotAreaFrame.paddingLeft   = 0;
    self.dataRateGraph.plotAreaFrame.paddingRight  = 0;
    self.dataRateGraph.paddingTop    = 0;
    self.dataRateGraph.paddingBottom = 0;
    self.dataRateGraph.paddingLeft   = 0;
    self.dataRateGraph.paddingRight  = 0;
    
    // Listen to data recorder ticks
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(onDataRateUpdate:)
                                                 name:GCSDataRecorderTick
                                               object:self.dataRateRecorder];
}

-(void) onDataRateUpdate:(NSNotification*)notification {
    // Reset the y-axis range and reload the graph data
    CPTXYPlotSpace *plotSpace = (CPTXYPlotSpace *)self.dataRateGraph.defaultPlotSpace;
    plotSpace.yRange = [CPTPlotRange plotRangeWithLocation:CPTDecimalFromFloat(-0.01)
                                                    length:CPTDecimalFromFloat(MAX([self.dataRateRecorder maxValue]*1.1, 1))];
    [self.dataRateGraph reloadData];
    [self.dataRateLabel setText:[NSString stringWithFormat:@"%0.1fkB/s", [self.dataRateRecorder latestValue]]];
}

-(NSUInteger) numberOfRecordsForPlot:(CPTPlot *)plot {
    return [self.dataRateRecorder count];
}

-(NSNumber *) numberForPlot:(CPTPlot *)plot field:(NSUInteger)fieldEnum
                recordIndex:(NSUInteger)index {
    return @((fieldEnum == CPTScatterPlotFieldX) ? [self.dataRateRecorder secondsSince:index] :[self.dataRateRecorder valueAt:index]);
}

@end

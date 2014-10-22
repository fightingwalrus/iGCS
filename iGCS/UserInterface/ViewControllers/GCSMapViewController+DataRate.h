//
//  GCSMapViewController+DataRate.h
//  iGCS
//
//  Created by Claudio Natoli on 22/10/2014.
//
//

#import "GCSMapViewController.h"
#import "DataRateRecorder.h"

@interface GCSMapViewController (DataRate) <CPTPlotDataSource>
@property (nonatomic, retain) CPTXYGraph *dataRateGraph;
@property (assign) DataRateRecorder* dataRateRecorder;
@end

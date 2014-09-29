//
//  ArDroneUtils.m
//  iGCS
//
//  Created by David Leskowicz on 9/29/14.
//
//

#import "ArDroneUtils.h"
#import "BRRequestCreateDirectory.h"
#import "BRRequestDelete.h"
#import "BRRequestUpload.h"
#import "BRRequestError.h"
#import "BRStreamInfo.h"
#import "BRRequestListDirectory.h"
#import "BRRequestQueue.h"

#import <sys/socket.h>
#import "GCDAsyncSocket.h"
#import "GCDAsyncUdpSocket.h"
#import "FileUtils.h"
#import "iGCSMavLinkInterface.h"
#import "CommController.h"



@interface ArDroneUtils ()

@property (nonatomic, strong)BRRequestCreateDirectory *createDir;
@property (nonatomic, strong) BRRequestDelete * deleteDir;
@property (nonatomic, strong) BRRequestListDirectory *listDir;

@property (nonatomic, strong) BRRequestDownload *downloadFile;
@property (nonatomic, strong) BRRequestUpload *uploadFile;
@property (nonatomic, strong) BRRequestDelete *deleteFile;

@property (nonatomic, strong) NSMutableData *downloadData;
@property (nonatomic, strong) NSData *uploadData;


@end

@implementation ArDroneUtils

- (void) uploadSer2udp {
    //----- get the file to upload as an NSData object
    
    _uploadData = [FileUtils dataFromFileInMainBundleWithName: @"ser2udp.gz"];
    
    _uploadFile = [[BRRequestUpload alloc] initWithDelegate: self];
    
    //----- for anonymous login just leave the username and password nil
    _uploadFile.path = @"ser2udp.gz";
    _uploadFile.hostname = @"192.168.1.1";
    _uploadFile.username = nil;
    _uploadFile.password = nil;
    
    //we start the request
    NSLog(@"start the ftp upload");
    [_uploadFile start];
}



- (void)telArdrone{
    
    NSLog(@"%s",__FUNCTION__);
    gcdsocket = [[GCDAsyncSocket alloc] initWithDelegate:self delegateQueue:dispatch_get_main_queue()];
    NSError *err = nil;
    if (![gcdsocket connectToHost:@"192.168.1.1" onPort:23 error:&err]) {
        NSLog(@"I goofed: %@", err);
    }
    [gcdsocket readDataWithTimeout:5 tag:1];
    
    
    
    NSLog(@"Unzipping program");
    NSString *requestStr = @"gunzip -f data/video/ser2udp.gz\r";
    NSData *requestData = [requestStr dataUsingEncoding:NSUTF8StringEncoding];
    [gcdsocket writeData:requestData withTimeout:1.0 tag:0];
    
    NSLog(@"changing permissions");
    requestStr = @"chmod 755 data/video/ser2udp\r";
    requestData = [requestStr dataUsingEncoding:NSUTF8StringEncoding];
    [gcdsocket writeData:requestData withTimeout:1.0 tag:0];
    
    NSLog(@"running program");
    requestStr = @"data/video/ser2udp\r";
    requestData = [requestStr dataUsingEncoding:NSUTF8StringEncoding];
    [gcdsocket writeData:requestData withTimeout:1.0 tag:0];
    
    
}


- (void)socket:(GCDAsyncSocket *)sock didConnectToHost:(NSString *)host port:(uint16_t)port {
    NSLog(@"Telnet Connected!");
}


- (void)mavArdrone {
    NSLog(@"Mav Button Clicked");
    [[CommController sharedInstance].mavLinkInterface sendMavtest];
    
    
}

- (void)lndArdrone {
    NSLog(@"LND Button Clicked");
    [[CommController sharedInstance].mavLinkInterface sendArdroneLand];
    
}

- (void)rtlArdrone {
    NSLog(@"RTL Button Clicked");
    [[CommController sharedInstance].mavLinkInterface sendArdroneRtl];
    
}

- (void)specArdrone {
    NSLog(@"Spec Button Clicked");
    [[CommController sharedInstance].mavLinkInterface sendArdronePairSpektrumDSMX];
    
}


//Request Completed
- (void)requestCompleted:(BRRequest *)request {
    NSLog(@"FTP Request Completed");
    _uploadFile = nil;
    
}

/// requestFailed
/// \param request The request object
- (void)requestFailed:(BRRequest *)request{
    
    if (request == _uploadFile)
    {
        NSLog(@"%@", request.error.message);
        _uploadFile = nil;
    }
    
}

- (NSData *) requestDataToSend: (BRRequestUpload *) request
{
    //----- returns data object or nil when complete
    //----- basically, first time we return the pointer to the NSData.
    //----- and BR will upload the data.
    //----- Second time we return nil which means no more data to send
    NSData *temp = _uploadData;   // this is a shallow copy of the pointer
    
    _uploadData = nil;            // next time around, return nil...
    NSLog(@"request data to send called");
    return temp;
}

/// shouldOverwriteFileWithRequest
/// \param request The request object;
- (BOOL)shouldOverwriteFileWithRequest:(BRRequest *)request {
    NSLog(@"Overwrite function called");
    
    //----- set this as appropriate if you want the file to be overwritten
    if (request == _uploadFile)
    {
        //----- if uploading a file, we set it to YES (if set to NO, nothing happens)
        return YES;
    }
    return NO;
    
}

@end
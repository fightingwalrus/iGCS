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

NSString * const ArDroneAtUtilsAtCommandedTakeOff = @"AT*REF=1,290718208\r";
NSString * const ArDroneAtUtilsToggleEmergency = @"AT*REF=1,290717952\r";
NSString * const ArDroneAtUtilsCalibrateHorizontalPlane = @"AT*FTRIM=1\r";
NSString * const ArDroneAtUtilsCalibrateMagnetometer = @"AT*CALIB=1,0\r";
NSString * const ArDroneAtUtilsResetWatchDogTimer = @"AT*COMWDG=1\r";
NSString * const ArDroneAtUtilsAtCommandedLand = @"AT*REF=1,290717696\r";
NSString * const ArDroneAtUtilsPhiM30 = @"AT*CONFIG=1,\"control:flight_anim\",\"0,1000\"\r";
NSString * const ArDroneAtUtilsPhi30 = @"AT*CONFIG=1,\"control:flight_anim\",\"1,1000\"\r";
NSString * const ArDroneAtUtilsThetaM30= @"AT*CONFIG=1,\"control:flight_anim\",\"2,1000\"\r";
NSString * const ArDroneAtUtilsTheta30= @"AT*CONFIG=1,\"control:flight_anim\",\"3,1000\"\r";
NSString * const ArDroneAtUtilsTheta20degYaw200= @"AT*CONFIG=1,\"control:flight_anim\",\"4,1000\"\r";
NSString * const ArDroneAtUtilsTheta20degYawM200= @"AT*CONFIG=1,\"control:flight_anim\",\"5,1000\"\r";
NSString * const ArDroneAtUtilsTurnAround = @"AT*CONFIG=1,\"control:flight_anim\",\"6,5000\"\r";
NSString * const ArDroneAtUtilsTurnAroundGoDown = @"AT*CONFIG=1,\"control:flight_anim\",\"7,5000\"\r";
NSString * const ArDroneAtUtilsYawShake = @"AT*CONFIG=1,\"control:flight_anim\",\"8,5000\"\r";
NSString * const ArDroneAtUtilsYawDance = @"AT*CONFIG=1,\"control:flight_anim\",\"9,5000\"\r";
NSString * const ArDroneAtUtilsPhiDance = @"AT*CONFIG=1,\"control:flight_anim\",\"10,5000\"\r";
NSString * const ArDroneAtUtilsThetaDance = @"AT*CONFIG=1,\"control:flight_anim\",\"11,5000\"\r";
NSString * const ArDroneAtUtilsVzDance = @"AT*CONFIG=1,\"control:flight_anim\",\"12,5000\"\r";
NSString * const ArDroneAtUtilsWave = @"AT*CONFIG=1,\"control:flight_anim\",\"13,5000\"\r";
NSString * const ArDroneAtUtilsPhiThetaMixed = @"AT*CONFIG=1,\"control:flight_anim\",\"14,5000\"\r";
NSString * const ArDroneAtUtilsDoublePhiThetaMixed = @"AT*CONFIG=1,\"control:flight_anim\",\"15,5000\"\r";
NSString * const ArDroneAtUtilsFlipAhead = @"AT*CONFIG=1,\"control:flight_anim\",\"16,15\"\r";
NSString * const ArDroneAtUtilsFlipBehind = @"AT*CONFIG=1,\"control:flight_anim\",\"17,15\"\r";
NSString * const ArDroneAtUtilsFlipLeft = @"AT*CONFIG=1,\"control:flight_anim\",\"18,15\"\r";
NSString * const ArDroneAtUtilsFlipRight = @"AT*CONFIG=1,\"control:flight_anim\",\"19,15\"\r";


@interface ArDroneUtils ()

@property (nonatomic, strong)BRRequestCreateDirectory *createDir;
@property (nonatomic, strong) BRRequestDelete * deleteDir;
@property (nonatomic, strong) BRRequestListDirectory *listDir;
@property (nonatomic, strong) BRRequestDownload *downloadFile;
@property (nonatomic, strong) BRRequestUpload *uploadFile;
@property (nonatomic, strong) BRRequestDelete *deleteFile;
@property (nonatomic, strong) NSMutableData *downloadData;
@property (nonatomic, strong) NSData *uploadData;
@property (nonatomic, strong) GCDAsyncSocket *gcdAsyncSocket;
@property (nonatomic, strong) GCDAsyncUdpSocket *gcdAsyncUdpSocket;

@end

@implementation ArDroneUtils

- (void) uploadProgramToDrone {
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



- (void)makeTelnetConnectionToDrone{
    
    NSLog(@"%s",__FUNCTION__);
    _gcdAsyncSocket = [[GCDAsyncSocket alloc] initWithDelegate:self delegateQueue:dispatch_get_main_queue()];
    NSError *err = nil;
    if (![_gcdAsyncSocket connectToHost:@"192.168.1.1" onPort:23 error:&err]) {
        NSLog(@"I goofed: %@", err);
    }
}


- (void)socket:(GCDAsyncSocket *)sock didConnectToHost:(NSString *)host port:(uint16_t)port {
    NSLog(@"Telnet Connected!");
    [_gcdAsyncSocket readDataWithTimeout:-1 tag:0];
    
    NSLog(@"Kill any previously running ser2udp rogram");
    NSString *requestStr = @"killall ser2udp\r";
    NSData *requestData = [requestStr dataUsingEncoding:NSUTF8StringEncoding];
    [_gcdAsyncSocket writeData:requestData withTimeout:-1 tag:5];
    
    NSLog(@"Trying to check file");
    requestStr = @"ls -ltr /data/video/ser2udp\r";
    requestData = [requestStr dataUsingEncoding:NSUTF8StringEncoding];
    [_gcdAsyncSocket writeData:requestData withTimeout:-1 tag:0];
    
    NSLog(@"Unzipping program");
    requestStr = @"gunzip -f /data/video/ser2udp.gz\r";
    requestData = [requestStr dataUsingEncoding:NSUTF8StringEncoding];
    [_gcdAsyncSocket writeData:requestData withTimeout:-1 tag:1];
    
    NSLog(@"changing permissions");
    requestStr = @"chmod 755 /data/video/ser2udp\r";
    requestData = [requestStr dataUsingEncoding:NSUTF8StringEncoding];
    [_gcdAsyncSocket writeData:requestData withTimeout:-1 tag:2];
    
    NSLog(@"running program");
    requestStr = @"/data/video/ser2udp\r";
    requestData = [requestStr dataUsingEncoding:NSUTF8StringEncoding];
    [_gcdAsyncSocket writeData:requestData withTimeout:-1 tag:3];

}


- (void)ConnectArDroneUDP{
    
    NSLog(@"%s",__FUNCTION__);
    _gcdAsyncUdpSocket = [[GCDAsyncUdpSocket alloc] initWithDelegate:self delegateQueue:dispatch_get_main_queue()];
    NSError *err = nil;
    if (![_gcdAsyncUdpSocket connectToHost:@"192.168.1.1" onPort:5556 error:&err]) {
        NSLog(@"I goofed: %@", err);
    }
    NSLog(@"running program");
    
}

- (void)atCommandedTakeOff{
    [self ConnectArDroneUDP];
    [self resetWatchDogTimer];
    [self calibrateHorizontalPlane];
    
    NSLog(@"Sending AT Command to launch");
    NSData *requestData = [ArDroneAtUtilsAtCommandedTakeOff dataUsingEncoding:NSUTF8StringEncoding];
    [_gcdAsyncUdpSocket sendData:requestData withTimeout:-1 tag:3];
    
}

- (void)toggleEmergency{
    [self ConnectArDroneUDP];
    [self resetWatchDogTimer];
    NSLog(@"Sending AT Command to clear emergency");
    NSData *requestData = [ArDroneAtUtilsToggleEmergency dataUsingEncoding:NSUTF8StringEncoding];
    [_gcdAsyncUdpSocket sendData:requestData withTimeout:-1 tag:3];
    
}

- (void)atCommandedLand{
    [self ConnectArDroneUDP];
    [self resetWatchDogTimer];
    NSLog(@"Sending AT Command to land the ArDrone");
    NSData *requestData = [ArDroneAtUtilsAtCommandedLand dataUsingEncoding:NSUTF8StringEncoding];
    [_gcdAsyncUdpSocket sendData:requestData withTimeout:-1 tag:3];
}


- (void)calibrateHorizontalPlane{
    [self ConnectArDroneUDP];
    [self resetWatchDogTimer];
    NSLog(@"Sending AT Command to calibrate the horiziontal plane");
    NSData *requestData = [ArDroneAtUtilsCalibrateHorizontalPlane dataUsingEncoding:NSUTF8StringEncoding];
    [_gcdAsyncUdpSocket sendData:requestData withTimeout:-1 tag:3];
}

- (void)calibrateMagnetometer{
    [self ConnectArDroneUDP];
    [self resetWatchDogTimer];
    NSLog(@"Sending AT Command to calibrate the magnetometer");
    NSData *requestData = [ArDroneAtUtilsCalibrateMagnetometer dataUsingEncoding:NSUTF8StringEncoding];
    [_gcdAsyncUdpSocket sendData:requestData withTimeout:-1 tag:3];
}

- (void)resetWatchDogTimer{
    NSData *requestData = [ArDroneAtUtilsResetWatchDogTimer dataUsingEncoding:NSUTF8StringEncoding];
    [_gcdAsyncUdpSocket sendData:requestData withTimeout:-1 tag:3];
    
}


//The Following 20 Commands are Parrot ArDrone Animations
//Please see the Parrot SDK for information and a possible
//description.
- (void) phiM30{
    [self ConnectArDroneUDP];
    [self resetWatchDogTimer];
    NSData *requestData = [ArDroneAtUtilsPhiM30 dataUsingEncoding:NSUTF8StringEncoding];
    [_gcdAsyncUdpSocket sendData:requestData withTimeout:-1 tag:3];
}

- (void) phi30{
    [self ConnectArDroneUDP];
    [self resetWatchDogTimer];
    NSData *requestData = [ArDroneAtUtilsPhi30 dataUsingEncoding:NSUTF8StringEncoding];
    [_gcdAsyncUdpSocket sendData:requestData withTimeout:-1 tag:3];
}

- (void) thetaM30{
    [self ConnectArDroneUDP];
    [self resetWatchDogTimer];
    NSData *requestData = [ArDroneAtUtilsThetaM30 dataUsingEncoding:NSUTF8StringEncoding];
    [_gcdAsyncUdpSocket sendData:requestData withTimeout:-1 tag:3];
}

- (void) theta30{
    [self ConnectArDroneUDP];
    [self resetWatchDogTimer];
    NSData *requestData = [ArDroneAtUtilsTheta30 dataUsingEncoding:NSUTF8StringEncoding];
    [_gcdAsyncUdpSocket sendData:requestData withTimeout:-1 tag:3];
}

- (void) theta20degYaw200{
    [self ConnectArDroneUDP];
    [self resetWatchDogTimer];
    NSData *requestData = [ArDroneAtUtilsTheta20degYaw200 dataUsingEncoding:NSUTF8StringEncoding];
    [_gcdAsyncUdpSocket sendData:requestData withTimeout:-1 tag:3];
}

- (void) theta20degYawM200{
    [self ConnectArDroneUDP];
    [self resetWatchDogTimer];
    NSData *requestData = [ArDroneAtUtilsTheta20degYawM200 dataUsingEncoding:NSUTF8StringEncoding];
    [_gcdAsyncUdpSocket sendData:requestData withTimeout:-1 tag:3];
}

- (void) turnAround{
    [self ConnectArDroneUDP];
    [self resetWatchDogTimer];
    NSData *requestData = [ArDroneAtUtilsTurnAround dataUsingEncoding:NSUTF8StringEncoding];
    [_gcdAsyncUdpSocket sendData:requestData withTimeout:-1 tag:3];
}

- (void) turnAroundGoDown{
    [self ConnectArDroneUDP];
    [self resetWatchDogTimer];
    NSData *requestData = [ArDroneAtUtilsTurnAroundGoDown dataUsingEncoding:NSUTF8StringEncoding];
    [_gcdAsyncUdpSocket sendData:requestData withTimeout:-1 tag:3];
}


- (void) yawShake{
    [self ConnectArDroneUDP];
    [self resetWatchDogTimer];
    NSData *requestData = [ArDroneAtUtilsYawShake dataUsingEncoding:NSUTF8StringEncoding];
    [_gcdAsyncUdpSocket sendData:requestData withTimeout:-1 tag:3];
}


- (void) yawDance{
    [self ConnectArDroneUDP];
    [self resetWatchDogTimer];
    NSData *requestData = [ArDroneAtUtilsYawDance dataUsingEncoding:NSUTF8StringEncoding];
    [_gcdAsyncUdpSocket sendData:requestData withTimeout:-1 tag:3];
}


- (void) phiDance{
    [self ConnectArDroneUDP];
    [self resetWatchDogTimer];
    NSData *requestData = [ArDroneAtUtilsPhiDance dataUsingEncoding:NSUTF8StringEncoding];
    [_gcdAsyncUdpSocket sendData:requestData withTimeout:-1 tag:3];
}


- (void) thetaDance{
    [self ConnectArDroneUDP];
    [self resetWatchDogTimer];
    NSData *requestData = [ArDroneAtUtilsThetaDance dataUsingEncoding:NSUTF8StringEncoding];
    [_gcdAsyncUdpSocket sendData:requestData withTimeout:-1 tag:3];
}


- (void) vzDance{
    [self ConnectArDroneUDP];
    [self resetWatchDogTimer];
    NSData *requestData = [ArDroneAtUtilsVzDance dataUsingEncoding:NSUTF8StringEncoding];
    [_gcdAsyncUdpSocket sendData:requestData withTimeout:-1 tag:3];
}

- (void) wave{
    [self ConnectArDroneUDP];
    [self resetWatchDogTimer];
    NSData *requestData = [ArDroneAtUtilsWave dataUsingEncoding:NSUTF8StringEncoding];
    [_gcdAsyncUdpSocket sendData:requestData withTimeout:-1 tag:3];
}


- (void) phiThetaMixed{
    [self ConnectArDroneUDP];
    [self resetWatchDogTimer];
    NSData *requestData = [ArDroneAtUtilsPhiThetaMixed dataUsingEncoding:NSUTF8StringEncoding];
    [_gcdAsyncUdpSocket sendData:requestData withTimeout:-1 tag:3];
}


- (void) doublePhiThetaMixed{
    [self ConnectArDroneUDP];
    [self resetWatchDogTimer];
    NSData *requestData = [ArDroneAtUtilsDoublePhiThetaMixed dataUsingEncoding:NSUTF8StringEncoding];
    [_gcdAsyncUdpSocket sendData:requestData withTimeout:-1 tag:3];
}

- (void) flipAhead{
    [self ConnectArDroneUDP];
    [self resetWatchDogTimer];
    NSData *requestData = [ArDroneAtUtilsFlipAhead dataUsingEncoding:NSUTF8StringEncoding];
    [_gcdAsyncUdpSocket sendData:requestData withTimeout:-1 tag:3];
}

- (void) flipBehind{
    [self ConnectArDroneUDP];
    [self resetWatchDogTimer];
    NSData *requestData = [ArDroneAtUtilsFlipBehind dataUsingEncoding:NSUTF8StringEncoding];
    [_gcdAsyncUdpSocket sendData:requestData withTimeout:-1 tag:3];
}

- (void) flipLeft{
    [self ConnectArDroneUDP];
    [self resetWatchDogTimer];
    NSData *requestData = [ArDroneAtUtilsFlipLeft dataUsingEncoding:NSUTF8StringEncoding];
    [_gcdAsyncUdpSocket sendData:requestData withTimeout:-1 tag:3];
}

- (void) flipRight{
    [self ConnectArDroneUDP];
    [self resetWatchDogTimer];
    NSData *requestData = [ArDroneAtUtilsFlipRight dataUsingEncoding:NSUTF8StringEncoding];
    [_gcdAsyncUdpSocket sendData:requestData withTimeout:-1 tag:3];
}
//The previous 20 Commands are Parrot ArDrone Animations
//Please see the Parrot SDK for information and a possible
//description.


- (void) droneMove:(NSString*) moveCommand {
    [self ConnectArDroneUDP];
    [self resetWatchDogTimer];
    NSData *requestData = [moveCommand dataUsingEncoding:NSUTF8StringEncoding];
    [_gcdAsyncUdpSocket sendData:requestData withTimeout:-1 tag:3];
}


- (void)mavlinkCommandedTakeoff {
    NSLog(@"Mav Button Clicked");
    [[CommController sharedInstance].mavLinkInterface sendMavlinkTakeOffCommand];
    
    
}

- (void)mavlinkLand {
    NSLog(@"LND Button Clicked");
    [[CommController sharedInstance].mavLinkInterface sendLand];
    
}

- (void)mavlinkReturnToLaunch {
    NSLog(@"RTL Button Clicked");
    [[CommController sharedInstance].mavLinkInterface sendReturnToLaunch];
    
}

- (void)StartSpektrumPairing {
    NSLog(@"Spec Button Clicked");
    [[CommController sharedInstance].mavLinkInterface sendPairSpektrumDSMX];
    
}


//Request Completed
- (void)requestCompleted:(BRRequest *)request {
    NSLog(@"FTP Request Completed");
    _uploadFile = nil;
    
}

/// requestFailed
/// \param request The request object
- (void)requestFailed:(BRRequest *)request{
    
    NSLog(@"FTP FAILED");
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
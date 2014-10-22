//
//  GCSFirmwareUpdatManager.h
//  iGCS
//
//  Created by Andrew Brown on 7/21/14.
//
//

#import <Foundation/Foundation.h>

@interface GCSFirmwareUpdateManager : NSObject <UIAlertViewDelegate>
-(instancetype)initWithTargetView:(UIView *)aTargetView NS_DESIGNATED_INITIALIZER;
@end

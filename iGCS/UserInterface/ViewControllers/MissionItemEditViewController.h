//
//  MissionItemEditViewController.h
//  iGCS
//
//  Created by Claudio Natoli on 4/05/13.
//
//

#import <UIKit/UIKit.h>
#import "WaypointsHolder.h"


@interface MissionItemEditViewController : UIViewController <UIPickerViewDataSource, UIPickerViewDelegate> {
    IBOutlet UIPickerView *pickerView;
    NSMutableArray *missionItemTypes;
    
    mavlink_mission_item_t missionItem;
    
    UITabBarController* tabVCDetailItemVC;
}

- (void) initInstance:(mavlink_mission_item_t)_missionItem;

@end
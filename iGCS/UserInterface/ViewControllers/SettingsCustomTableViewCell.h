//
//  SettingsCustomTableViewCell.h
//  iGCS
//
//  Created by David Leskowicz on 2/12/15.
//
//

#import <UIKit/UIKit.h>

@interface SettingsCustomTableViewCell : UITableViewCell {
    UILabel *customLabel;
    UITextField *customTextField;

}

@property (nonatomic, retain) UILabel *customLabel;
@property (nonatomic, retain) UITextField *customTextField;

@end

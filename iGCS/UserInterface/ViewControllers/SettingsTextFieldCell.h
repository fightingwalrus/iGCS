//
//  SettingsCustomTableViewCell.h
//  iGCS
//
//  Created by David Leskowicz on 2/12/15.
//
//

#import <UIKit/UIKit.h>

@interface SettingsTextFieldCell : UITableViewCell {
    UITextField *customTextField;
    UILabel *customLabel;

}

@property (nonatomic, retain) UITextField *customTextField;
@property (nonatomic, retain) UILabel *customLabel;

@end

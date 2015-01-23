//
//  UIStoryboardSegue+CustomSegue.m
//  iGCS
//
//  Created by David Leskowicz on 1/23/15.
//
//

#define IS_IPAD (UI_USER_INTERFACE_IDIOM()==UIUserInterfaceIdiomPad)

#import "UIStoryboardSegue+CustomSegue.h"
#import "MissionItemEditViewController.h"

@implementation editItemVC_segue



- (void)perform {
    
    if (IS_IPAD) {

        [[self sourceViewController] showViewController:[self destinationViewController] sender:self] ;
    }
    else {
        UINavigationController *missionItemEditiPhone = [[UINavigationController alloc] initWithRootViewController:self.destinationViewController];
        [[self sourceViewController] presentViewController:missionItemEditiPhone animated:YES completion:nil];
    }
        
}

@end

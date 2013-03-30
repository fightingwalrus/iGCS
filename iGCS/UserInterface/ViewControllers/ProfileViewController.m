//
//  ProfileViewController.m
//  iGCS
//
//  Created by Andrew Aarestad on 3/27/13.
//
//

#import "ProfileViewController.h"
#import "AppDelegate.h"

@implementation ProfileViewController



- (void)viewDidLoad {
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    
    [self updateView];
    
    self.appDelegate = [AppDelegate sharedDelegate];
    
    if (!self.appDelegate.session.isOpen) {
        // create a fresh session object
        self.appDelegate.session = [[FBSession alloc] init];
        
        // if we don't have a cached token, a call to open here would cause UX for login to
        // occur; we don't want that to happen unless the user clicks the login button, and so
        // we check here to make sure we have a token before calling open
        if (self.appDelegate.session.state == FBSessionStateCreatedTokenLoaded) {
            // even though we had a cached token, we need to login to make the session usable
            [self.appDelegate.session openWithCompletionHandler:^(FBSession *session,
                                                             FBSessionState status,
                                                             NSError *error) {
                // we recurse here, in order to update buttons and labels
                [self updateView];
            }];
        }
    }
}

-(void)viewDidAppear {
    [self updateView];
}

// FBSample logic
// main helper method to update the UI to reflect the current state of the session.
- (void)updateView {
    // get the app delegate, so that we can reference the session property
    if (self.appDelegate.session.isOpen) {
        // valid account UI is shown whenever the session is open
        [self.facebookLoginButton setTitle:@"Log out" forState:UIControlStateNormal];
        /*[self.facebookStatusLabel setText:[NSString stringWithFormat:@"https://graph.facebook.com/me/friends?access_token=%@",
                                           self.appDelegate.session.accessTokenData.accessToken]];
        */
         [self.facebookStatusLabel setText:[NSString stringWithFormat:@"Logged in."]];
    } else {
        // login-needed account UI is shown whenever the session is closed
        [self.facebookLoginButton setTitle:@"Log in" forState:UIControlStateNormal];
        [self.facebookStatusLabel setText:@"Click to log in with Facebook."];
    }
}


- (IBAction)facebookLoginButtonPressed:(id)sender {
    
    // this button's job is to flip-flop the session from open to closed
    if (self.appDelegate.session.isOpen) {
        // if a user logs out explicitly, we delete any cached token information, and next
        // time they run the applicaiton they will be presented with log in UX again; most
        // users will simply close the app or switch away, without logging out; this will
        // cause the implicit cached-token login to occur on next launch of the application
        [self.appDelegate.session closeAndClearTokenInformation];
        
    } else {
        if (self.appDelegate.session.state != FBSessionStateCreated) {
            // Create a new, logged out session.
            NSLog(@"Creating new FBSession...");
            self.appDelegate.session = [[FBSession alloc] init];
        }
        
        // if the session isn't open, let's open it now and present the login UX to the user
        NSLog(@"Opening FBSession");
        [self.appDelegate.session openWithCompletionHandler:^(FBSession *session,
                                                         FBSessionState status,
                                                         NSError *error) {
            // and here we make sure to update our UX according to the new session state
            NSLog(@"UpdateView");
            [self updateView];
        }];
    }
    
    /*
    if (![FBSession activeSession].isOpen) {
        FBSession *session = [[FBSession alloc] initWithAppID:nil permissions:nil defaultAudience:FBSessionDefaultAudienceEveryone urlSchemeSuffix:nil tokenCacheStrategy:nil];
        [FBSession setActiveSession:session];
        [session openWithBehavior:FBSessionLoginBehaviorUseSystemAccountIfPresent     completionHandler:^(FBSession *session, FBSessionState status, NSError *error) {
            // NOTE openActiveSessionWithPermissions causes the facebook app to hang with a blank dialog if my app is installed, authed, and then reinstalled. openWithBehavior
            // does not. I think it has something to do with the FBSession activeSession.
            //        [FBSession openActiveSessionWithPermissions:self.permissions allowLoginUI:YES completionHandler:^(FBSession *session, FBSessionState status, NSError *error) {
            switch (status) {
                case FBSessionStateOpen:
                    //[self getFacebookUser];
                    break;
                case FBSessionStateClosed:
                    //[self fbSessionClosed];
                    break;
                case FBSessionStateCreated:
                    //[self fbSessionCreated];
                    break;
                case FBSessionStateCreatedOpening:
                    //[self fbSessionOpening];
                    break;
                case FBSessionStateClosedLoginFailed:
                    //[self fbSessionClosedLoginFailed];
                    break;
                case FBSessionStateOpenTokenExtended:
                    //[self fbSessionOpenTokenExtended];
                    break;
                case FBSessionStateCreatedTokenLoaded:
                    //[self fbSessionCreatedTokenLoaded];
                    break;
            }
        }];
    }

    
    
    // get the app delegate so that we can access the session property
    if ([[[AppDelegate sharedDelegate] session] isOpen])
    {
        
    
    }
    // this button's job is to flip-flop the session from open to closed
    if (self.appDelegate.session.isOpen) {
        // if a user logs out explicitly, we delete any cached token information, and next
        // time they run the applicaiton they will be presented with log in UX again; most
        // users will simply close the app or switch away, without logging out; this will
        // cause the implicit cached-token login to occur on next launch of the application
        [self.appDelegate.session closeAndClearTokenInformation];
        
    } else {
        if (self.appDelegate.session.state != FBSessionStateCreated) {
            // Create a new, logged out session.
            self.appDelegate.session = [[FBSession alloc] init];
        }
        
        // if the session isn't open, let's open it now and present the login UX to the user
        [self.appDelegate.session openWithCompletionHandler:^(FBSession *session,
                                                         FBSessionState status,
                                                         NSError *error) {
            // and here we make sure to update our UX according to the new session state
            [self updateView];
        }];
    }
     
     */
    
}
- (void)viewDidUnload {
    [self setTotalFlightHoursLabel:nil];
    [self setCrashesLabel:nil];
    [self setFacebookLoginButton:nil];
    [self setFacebookStatusLabel:nil];
    [super viewDidUnload];
}
@end

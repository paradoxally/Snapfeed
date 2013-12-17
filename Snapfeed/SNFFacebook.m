//
//  SNFFacebook.m
//  Snapfeed
//
//  Created by Nino Vitale on 12/16/13.
//
//

#import "SNFFacebook.h"
#import "SNFAppDelegate.h"

@implementation SNFFacebook

+ (instancetype)sharedInstance {
	static dispatch_once_t once;
	static id sharedInstance;
    
	dispatch_once(&once, ^
                  {
                      sharedInstance = [self new];
                  });
    
	return sharedInstance;
}

#pragma mark - PUBLIC METHODS

- (FBSessionState)activeSessionState {
    return [[FBSession activeSession] state];
}

- (void)openSession {
	[FBSession openActiveSessionWithReadPermissions:@[@"user_photos", @"read_stream", @"basic_info", @"user_location", @"email", @"user_friends", @"user_birthday"]
	                                   allowLoginUI:YES
	                              completionHandler:
	 ^(FBSession *session,
	   FBSessionState state, NSError *error) {
         [self sessionStateChanged:session state:state error:error];
     }];
}

#pragma mark - PRIVATE METHODS

- (void)sessionStateChanged:(FBSession *)session
                                state:(FBSessionState)state
                                error:(NSError *)error {
	switch (state) {
		case FBSessionStateOpen: {
			// Login done
			DDLogInfo(@"%@: Login finished, show the main view!", THIS_FILE);
            [[NSNotificationCenter defaultCenter] postNotificationName:FBSessionStateOpenedNotification object:self];
			break;
		}
            
		case FBSessionStateClosed:
		case FBSessionStateClosedLoginFailed:
			DDLogError(@"%@: State is closed and/or login failed!", THIS_FILE);
			[FBSession.activeSession closeAndClearTokenInformation];
			break;
            
		default:
			break;
	}
    
    if (error) {
        [self showError:error];
    }
}

- (void)showError:(NSError *)error {
    DDLogError(@"%@: %@", THIS_FILE, error);
    UIAlertView *alertView = [[UIAlertView alloc]
                              initWithTitle:@"Error"
                              message:[error localizedDescription]
                              delegate:nil
                              cancelButtonTitle:@"OK"
                              otherButtonTitles:nil];
    [alertView show];
}

@end

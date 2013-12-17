//
//  SNFFacebook.h
//  Snapfeed
//
//  Created by Nino Vitale on 12/16/13.
//
//

#import <Foundation/Foundation.h>
#import <FacebookSDK/FacebookSDK.h>

@interface SNFFacebook : NSObject

+ (instancetype)sharedInstance;

- (void)openSession;
- (FBSessionState)activeSessionState;

@end

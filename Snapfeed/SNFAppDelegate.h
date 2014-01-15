//
//  SNFAppDelegate.h
//  Snapfeed
//
//  Created by Nino Vitale on 12/14/13.
//
//

#import <UIKit/UIKit.h>
#import <UIColor+MLPFlatColors.h>

#define IS_IPHONE_4_INCH ([[UIScreen mainScreen] bounds].size.height == 568)
#define BOOLtoNSString(aBOOL) aBOOL ? @"YES" : @"NO"

static const int ddLogLevel = LOG_LEVEL_VERBOSE;    // logging level

extern NSString *const FBSessionStateOpenedNotification;

@interface SNFAppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;

@end

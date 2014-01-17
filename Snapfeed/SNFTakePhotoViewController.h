//
//  SNFTakePhotoViewController.h
//  Snapfeed
//
//  Created by Nino Vitale on 1/3/14.
//
//

#import "CaptureSessionManager.h"
#import <UIKit/UIKit.h>

extern NSString *const flashModeChangedNotificationName;

@interface SNFTakePhotoViewController : UIViewController <UIAccelerometerDelegate>

@property (nonatomic, strong) CaptureSessionManager *captureManager;

@end

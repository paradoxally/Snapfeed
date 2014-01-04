//
//  SNFTakePhotoViewController.h
//  Snapfeed
//
//  Created by Nino Vitale on 1/3/14.
//
//

#import "CaptureSessionManager.h"
#import <UIKit/UIKit.h>

@interface SNFTakePhotoViewController : UIViewController

@property (nonatomic, strong) CaptureSessionManager *captureManager;

@end

//
//  SNFCameraOverlayView.h
//  Snapfeed
//
//  Created by Nino Vitale on 1/2/14.
//
//

#import <UIKit/UIKit.h>

@interface SNFCameraOverlayView : UIView

@property (weak, nonatomic) IBOutlet UIView *cameraHeader;
@property (weak, nonatomic) IBOutlet UIButton *closeButton;
@property (weak, nonatomic) IBOutlet UIView *cameraControlBar;
@property (weak, nonatomic) IBOutlet UIView *cameraShutterBar;

@end

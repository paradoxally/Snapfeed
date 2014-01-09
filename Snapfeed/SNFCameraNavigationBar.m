//
//  SNFCameraNavigationBar.m
//  Snapfeed
//
//  Created by Nino Vitale on 1/8/14.
//
//

#import "SNFCameraNavigationBar.h"
#import "SNFCameraNavigationController.h"
#import <UIColor+MLPFlatColors.h>

@implementation SNFCameraNavigationBar

static const CGFloat kTitleVerticalAdjustment = -4;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Set the appearance attributes of the navigation bar
        self.barTintColor = [UIColor flatBlackColor];
        self.alpha = 0.9f;
        
        // Adjust title vertical position to account for the increase of size of the navigation bar (if larger)
        if (self.frame.size.height > 44) {
            [[UINavigationBar appearanceWhenContainedIn:[SNFCameraNavigationController class], nil] setTitleVerticalPositionAdjustment:kTitleVerticalAdjustment forBarMetrics:UIBarMetricsDefault];
        }
    }
    
    return self;
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

@end

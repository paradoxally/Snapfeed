//
//  SNFCameraOverlayView.m
//  Snapfeed
//
//  Created by Nino Vitale on 1/2/14.
//
//

#import "SNFCameraOverlayView.h"
#import "SNFAppDelegate.h"

@implementation SNFCameraOverlayView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}

- (void)awakeFromNib {
    self.cameraHeader.backgroundColor = [UIColor flatBlackColor];
    self.cameraHeader.alpha = 0.9f;
    self.cameraControlBar.backgroundColor = [UIColor flatBlackColor];
    self.cameraControlBar.alpha = 0.9f;
    self.cameraShutterBar.backgroundColor = [UIColor flatDarkBlackColor];
    
    // Debug for square images
    /*UIView *redBorderView = [[UIView alloc] initWithFrame:CGRectMake(0, self.cameraHeader.frame.size.height, 320, ceilf(self.frame.size.height - self.cameraHeader.frame.size.height - self.cameraControlBar.frame.size.height - self.cameraShutterBar.frame.size.height + 2.0f))];
    redBorderView.layer.borderColor = [UIColor redColor].CGColor;
    redBorderView.layer.borderWidth = 1.0f;
    [self addSubview:redBorderView];*/
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

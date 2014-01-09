//
//  SNFCameraControlButton.m
//  Snapfeed
//
//  Created by Nino Vitale on 1/8/14.
//
//

#import "SNFCameraControlButton.h"

@implementation SNFCameraControlButton

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.showsTouchWhenHighlighted = YES;
        self.backgroundColor = [UIColor clearColor];
    }
    return self;
}

@end

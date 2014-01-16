//
//  SNFRoundedRectButton.m
//  Snapfeed
//
//  Created by Nino Vitale on 12/19/13.
//
//

#import "SNFRoundedRectButton.h"

static const CGFloat kRectButtonCornerRadius = 2.5f;

@implementation SNFRoundedRectButton

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    [self.layer setCornerRadius:kRectButtonCornerRadius];
    [self setTitleColor:[UIColor flatDarkWhiteColor] forState:UIControlStateHighlighted];
}

@end

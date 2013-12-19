//
//  SNFLikeButton.m
//  Snapfeed
//
//  Created by Nino Vitale on 12/19/13.
//
//

#import "SNFLikeButton.h"

static const CGFloat kLikeButtonCornerRadius = 4.0f;

@implementation SNFLikeButton

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
    
    [self.layer setCornerRadius:kLikeButtonCornerRadius];
}

@end

//
//  SNFFeedHeaderUserButton.m
//  Snapfeed
//
//  Created by Nino Vitale on 1/11/14.
//
//

#import "SNFFeedHeaderUserButton.h"
#import <UIColor+MLPFlatColors.h>

@implementation SNFFeedHeaderUserButton

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        self.titleLabel.font = [UIFont boldSystemFontOfSize:14];
        self.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
        self.titleLabel.lineBreakMode = NSLineBreakByTruncatingTail;
        [self setTitleColor:[UIColor flatDarkBlueColor] forState:UIControlStateNormal];
        [self setTitleColor:[UIColor flatBlackColor] forState:UIControlStateHighlighted];
    }
    return self;
}

@end

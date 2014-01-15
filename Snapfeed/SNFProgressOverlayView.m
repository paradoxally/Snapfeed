//
//  SNFProgressOverlayView.m
//  Snapfeed
//
//  Created by Nino Vitale on 1/15/14.
//
//

#import "SNFProgressOverlayView.h"
#import <UIColor+MLPFlatColors.h>

@implementation SNFProgressOverlayView

- (M13ProgressViewRing *)progressView {
    if (!_progressView) {
        _progressView = [[M13ProgressViewRing alloc] initWithFrame:CGRectMake(self.bounds.size.width / 3, self.bounds.size.height / 3.7, 110, 110)];
        _progressView.secondaryColor = [UIColor flatDarkBlueColor];
        _progressView.backgroundRingWidth = 4;
        _progressView.showPercentage = NO;
        _progressView.indeterminate = YES;
    }
    
    return _progressView;
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        [self addSubview:self.progressView];
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

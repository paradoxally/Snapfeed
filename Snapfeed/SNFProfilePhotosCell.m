//
//  SNFProfilePhotosCell.m
//  Snapfeed
//
//  Created by Nino Vitale on 1/10/14.
//
//

#import "SNFProfilePhotosCell.h"

@implementation SNFProfilePhotosCell

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}

-(void)prepareForReuse {
    [super prepareForReuse];
    
    self.thumbnail.image = nil;
    
}

@end

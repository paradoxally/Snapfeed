//
//  SNFProfilePictureButton.m
//  Snapfeed
//
//  Created by Nino Vitale on 1/10/14.
//
//

#import "SNFProfilePictureButton.h"
#import <UIColor+MLPFlatColors.h>
#import <SDWebImage/UIButton+WebCache.h>

@implementation SNFProfilePictureButton

- (void)awakeFromNib {
	[super awakeFromNib];
    
	[self setupButtonProperties];
}

- (id)initWithFrame:(CGRect)frame {
	self = [super initWithFrame:frame];
	if (self) {
		[self setupButtonProperties];
	}
	return self;
}

- (void)setupButtonProperties {
	self.layer.cornerRadius = self.frame.size.height / 2.0;
	self.layer.borderColor = [UIColor flatDarkWhiteColor].CGColor;
	self.layer.borderWidth = 1;
	self.clipsToBounds = YES;
}

- (void)setProfileImageFromURL:(NSURL *)url forState:(UIControlState)state {
	[self setBackgroundImageWithURL:url
	                       forState:state
	               placeholderImage:nil
	                        options:SDWebImageRefreshCached
	                      completed: ^(UIImage *image, NSError *error, SDImageCacheType cacheType) {
                              if (error) {
                                  DDLogWarn(@"%@: Error fetching profile image: %@", THIS_FILE, error);
                              }
                          }];
}

@end

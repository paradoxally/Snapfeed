//
//  SNFFeedHeaderView.m
//  Snapfeed
//
//  Created by Nino Vitale on 12/18/13.
//
//

#import "SNFFeedHeaderView.h"
#import "SNFFacebook.h"
#import "SNFAppDelegate.h"
#import "NSDate+ShortTimeAgo.h"
#import <SDWebImage/UIImageView+WebCache.h>

@implementation SNFFeedHeaderView

- (SNFFeedHeaderUserButton *)fromUserButton {
    if (!_fromUserButton) {
        _fromUserButton = [[SNFFeedHeaderUserButton alloc]initWithFrame:CGRectMake(50,10,210,30)];
    }
    
    return _fromUserButton;
}

- (SNFProfilePictureButton *)avatarButton {
    if (!_avatarButton) {
        _avatarButton = [[SNFProfilePictureButton alloc] initWithFrame:CGRectMake(10, 10, 30, 30)];
    }
    
    return _avatarButton;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    [self setBackgroundColor:[UIColor colorWithRed:1.0 green:1.0 blue:1.0 alpha:0.95]];
    
    // ADD BORDER BOTTOM
    UIView *navBorder = [[UIView alloc] initWithFrame:CGRectMake(0,self.frame.size.height-1,self.frame.size.width, 1)];
    [navBorder setBackgroundColor:[UIColor colorWithRed:0.7 green:0.7 blue:0.7 alpha:1.00]];
    [self addSubview:navBorder];
    
    
    // NAME FROM
    [self.fromUserButton setTitle:self.username forState:UIControlStateNormal];
    
    // DATE
    if (![self.datePostedString isEqualToString:@""]) {
        NSDateFormatter *df = [[NSDateFormatter alloc] init];
        [df setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
        NSDate *datePosted = [df dateFromString: self.datePostedString];
        UILabel *relativeTimeLabel = [[UILabel alloc]initWithFrame:CGRectMake(270,10,40,30)];
        relativeTimeLabel.text = [datePosted shortTimeAgo];
        relativeTimeLabel.textAlignment = NSTextAlignmentRight;
        [relativeTimeLabel setFont:[UIFont boldSystemFontOfSize:12.0f]];
        
        // ICON FOR DATE
        CGSize sizeDateText = [relativeTimeLabel.text sizeWithAttributes:@{NSFontAttributeName:[UIFont boldSystemFontOfSize:12.0f]}];
        UIImageView *dateIcon = [[UIImageView alloc] initWithFrame:CGRectMake(320-sizeDateText.width-15-15, 22, 15, 15)];
        //dateIcon.image = [UIImage imageNamed:@"alarm_clock-25"];
        dateIcon.contentMode = UIViewContentModeCenter;
        
        [self addSubview:relativeTimeLabel];
        [self addSubview:dateIcon];
    }
    
    if (self.avatarURL) {
		[self.avatarButton setProfileImageFromURL:self.avatarURL forState:UIControlStateNormal];
	}
    
    [self addSubview:self.fromUserButton];
    [self addSubview:self.avatarButton];
    
    [self setNeedsDisplay];

}

@end

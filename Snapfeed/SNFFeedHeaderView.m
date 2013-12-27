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

- (UIImageView *)avatar {
    if (!_avatar) {
        _avatar = [[UIImageView alloc] init];
        _avatar.frame = CGRectMake(10, 10, 30, 30);
    }
    
    return _avatar;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    [self setBackgroundColor:[UIColor colorWithRed:1.0 green:1.0 blue:1.0 alpha:0.95]];
    
    // ADD BORDER BOTTOM
    UIView *navBorder = [[UIView alloc] initWithFrame:CGRectMake(0,self.frame.size.height-1,self.frame.size.width, 1)];
    [navBorder setBackgroundColor:[UIColor colorWithRed:0.7 green:0.7 blue:0.7 alpha:1.00]];
    [self addSubview:navBorder];
    
    
    // NAME FROM
    UILabel *from = [[UILabel alloc]initWithFrame:CGRectMake(50,0,170,50)];
    from.text = self.username;
    from.font = [UIFont boldSystemFontOfSize:14];
    
    // DATE
    if (![self.datePostedString isEqualToString:@""]) {
        NSDateFormatter *df = [[NSDateFormatter alloc] init];
        [df setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
        NSDate *datePosted = [df dateFromString: self.datePostedString];
        UILabel *relativeTimeLabel = [[UILabel alloc]initWithFrame:CGRectMake(230,0,80,50)];
        relativeTimeLabel.text = [datePosted shortTimeAgo];;
        relativeTimeLabel.textAlignment = NSTextAlignmentRight;
        [relativeTimeLabel setFont:[UIFont boldSystemFontOfSize:12.0f]];
        
        // ICON FOR DATE
        CGSize sizeDateText = [relativeTimeLabel.text sizeWithAttributes:@{NSFontAttributeName:[UIFont boldSystemFontOfSize:12.0f]}];
        UIImageView *dateIcon = [[UIImageView alloc] initWithFrame:CGRectMake(320-sizeDateText.width-15-15, 17, 15, 15)];
        //dateIcon.image = [UIImage imageNamed:@"alarm_clock-25"];
        dateIcon.contentMode = UIViewContentModeCenter;
        
        [self addSubview:relativeTimeLabel];
        [self addSubview:dateIcon];
    }
    
    // AVATAR
    //self.avatar = [[UIImageView alloc] init];
    //self.avatar.frame = CGRectMake(10, 10, 30, 30);
    //avatar.image = [UIImage imageNamed:@"user_male-50"];
    [self.avatar.layer setCornerRadius:15.0];
    [self.avatar.layer setBorderColor:[UIColor flatDarkWhiteColor].CGColor];
    [self.avatar.layer setBorderWidth:0.5f];
    [self.avatar.layer setMasksToBounds:YES];
    
    [self addSubview:from];
    [self addSubview:self.avatar];
    
    [self setNeedsDisplay];

}

@end

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
#import <NSDate+TimeAgo.h>
#import <SDWebImage/UIImageView+WebCache.h>

@implementation SNFFeedHeaderView

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
    NSDateFormatter *df = [[NSDateFormatter alloc] init];
    [df setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    NSString *dateInString = self.datePostedString;
    NSDate *myDate = [df dateFromString: dateInString];
    UILabel *time = [[UILabel alloc]initWithFrame:CGRectMake(230,0,80,50)];
    //time.text = [myDate dateTimeUntilNow];
    time.textAlignment = NSTextAlignmentRight;
    [time setFont:[UIFont systemFontOfSize:10]];
    
    
    // ICON FOR DATE
    CGSize sizeDateText = [time.text sizeWithAttributes:@{NSFontAttributeName:[UIFont systemFontOfSize:10]}];
    UIImageView *dateIcon = [[UIImageView alloc] initWithFrame:CGRectMake(320-sizeDateText.width-15-15, 17, 15, 15)];
    //dateIcon.image = [UIImage imageNamed:@"alarm_clock-25"];
    dateIcon.contentMode = UIViewContentModeCenter;
    
    
    // AVATAR
    __block UIImageView *avatar = [[UIImageView alloc] init];
    avatar.frame = CGRectMake(10, 10, 30, 30);
    //avatar.image = [UIImage imageNamed:@"user_male-50"];
    [avatar.layer setCornerRadius:15.0];
    [avatar.layer setMasksToBounds:YES];
    [[SNFFacebook sharedInstance] myFriendsAvatar:self.userID withReponse:^(FBRequestConnection *request, id result, NSError *error) {
        if(!error) {
            if([[result objectForKey:@"data"] count] > 0) {
                NSURL *imageURL = [NSURL URLWithString:result[@"data"][0][@"picture"][@"data"][@"url"]];
                DDLogVerbose(@"%@: Avatar image URL: %@", THIS_FILE, imageURL);
                
                [avatar setImageWithURL:imageURL];
            }
        }
    }];
    
    
    [self addSubview:from];
    [self addSubview:time];
    [self addSubview:dateIcon];
    [self addSubview:avatar];
    
    [self setNeedsDisplay];

}

@end
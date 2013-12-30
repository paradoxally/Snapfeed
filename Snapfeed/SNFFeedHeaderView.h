//
//  SNFFeedHeaderView.h
//  Snapfeed
//
//  Created by Nino Vitale on 12/18/13.
//
//

#import <UIKit/UIKit.h>

@interface SNFFeedHeaderView : UIView

@property (nonatomic, strong) NSString *userID;
@property (nonatomic, strong) NSString *username;
@property (nonatomic, strong) NSString *datePostedString;
@property (nonatomic, strong) UIImageView *avatar;

@end

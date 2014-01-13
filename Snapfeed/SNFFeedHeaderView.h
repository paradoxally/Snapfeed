//
//  SNFFeedHeaderView.h
//  Snapfeed
//
//  Created by Nino Vitale on 12/18/13.
//
//

#import "SNFProfilePictureButton.h"
#import "SNFFeedHeaderUserButton.h"
#import <UIKit/UIKit.h>

@interface SNFFeedHeaderView : UIView

@property (nonatomic, strong) NSString *userID;
@property (nonatomic, strong) NSString *username;
@property (nonatomic, strong) NSString *datePostedString;
@property (nonatomic, strong) NSURL *avatarURL;

@property (nonatomic, strong) SNFProfilePictureButton *avatarButton;
@property (nonatomic, strong) SNFFeedHeaderUserButton *fromUserButton;

@end

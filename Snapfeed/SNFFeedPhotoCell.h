//
//  SNFFeedPhotoCell.h
//  Snapfeed
//
//  Created by Nino Vitale on 12/17/13.
//
//

#import <UIKit/UIKit.h>
#import <TTTAttributedLabel.h>

@interface SNFFeedPhotoCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UIImageView *photoView;
@property (weak, nonatomic) IBOutlet TTTAttributedLabel *description;
@property (weak, nonatomic) IBOutlet TTTAttributedLabel *likeLabel;
@property (weak, nonatomic) IBOutlet UIButton *likeButton;
@property (weak, nonatomic) IBOutlet UIView *likesSection;

@end

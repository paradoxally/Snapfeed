//
//  SNFFeedPhotoCell.h
//  Snapfeed
//
//  Created by Nino Vitale on 12/17/13.
//
//

#import <UIKit/UIKit.h>

@interface SNFFeedPhotoCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UIImageView *photoView;
@property (weak, nonatomic) IBOutlet UITextView *description;
@property (weak, nonatomic) IBOutlet UIButton *likeButton;

@end

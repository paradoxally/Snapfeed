//
//  SNFFeedPhotoCell.m
//  Snapfeed
//
//  Created by Nino Vitale on 12/17/13.
//
//

#import "SNFFeedPhotoCell.h"
#import "SNFRoundedRectButton.h"
#import "SNFAppDelegate.h"
#import "SNFFacebook.h"
#import "SNFFeedTVC.h"
#import <UIColor+MLPFlatColors.h>

@implementation SNFFeedPhotoCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
    }
    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)setLikeButtonSelected:(BOOL)selected {
    if (selected) {
        [self.likeButton setTitle:@"Liked" forState:UIControlStateSelected];
        [self.likeButton setBackgroundColor:[UIColor flatRedColor]];
        [self.likeButton setSelected:YES];
    } else {
        [self.likeButton setTitle:@"Like" forState:UIControlStateNormal];
        [self.likeButton setBackgroundColor:[UIColor flatDarkGrayColor]];
        [self.likeButton setSelected:NO];
    }
}

- (IBAction)likeButtonTapped:(SNFRoundedRectButton *)button {
    DDLogVerbose(@"%@: Button tapped for cell: #%lu and Facebook post ID: %@", THIS_FILE, (unsigned long)self.sectionIndex, self.postID);
    NSDictionary *post = @{ @"post_id" : self.postID };
    
    if (!button.isSelected) {
        DDLogVerbose(@"%@: Liking post!", THIS_FILE);
        [self setLikeButtonSelected:YES];
        // We ask our Facebook class to like the post remotely, but after giving feedback to the user
        [[SNFFacebook sharedInstance] likePost:self.postID andResponse:^(FBRequestConnection *request, id result, NSError *error) {
            if (error) {
                DDLogVerbose(@"%@: Error liking post: %@", THIS_FILE, error);
            } else {
                // Notify the tableview controller we have liked a post
                [[NSNotificationCenter defaultCenter] postNotificationName:postLikedNotificationName
                                                                    object:self
                                                                  userInfo:post];
            }
        }];
    } else {
        DDLogVerbose(@"%@: Unliking post!", THIS_FILE);
        [self setLikeButtonSelected:NO];
        [[SNFFacebook sharedInstance] unlikePost:self.postID andResponse:^(FBRequestConnection *request, id result, NSError *error) {
            if (error) {
                DDLogVerbose(@"%@: Error unliking post: %@", THIS_FILE, error);
            } else {
                // Notify the tableview controller we have unlike a post
                [[NSNotificationCenter defaultCenter] postNotificationName:postUnlikedNotificationName
                                                                    object:self
                                                                  userInfo:post];
            }
        }];
    }
}

@end

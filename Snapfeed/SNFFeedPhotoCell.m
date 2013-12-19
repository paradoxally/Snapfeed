//
//  SNFFeedPhotoCell.m
//  Snapfeed
//
//  Created by Nino Vitale on 12/17/13.
//
//

#import "SNFFeedPhotoCell.h"

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

-(void)prepareForReuse {
    
    self.photoView.image = nil;
    self.photoView.contentMode = UIViewContentModeScaleAspectFill;
    self.description.text = @"";
}

@end

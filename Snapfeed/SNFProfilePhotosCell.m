//
//  SNFProfilePhotosCell.m
//  Snapfeed
//
//  Created by Nino Vitale on 1/10/14.
//
//

#import "SNFProfilePhotosCell.h"

@implementation SNFProfilePhotosCell

- (void)awakeFromNib {
    self.separatorInset = UIEdgeInsetsMake(0, self.bounds.size.width, 0, 0);
}

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
    }
    return self;
}

@end

//
//  SNFPostingPhotoViewController.h
//  Snapfeed
//
//  Created by Nino Vitale on 1/14/14.
//
//

#import <UIKit/UIKit.h>

@interface SNFPostingPhotoViewController : UIViewController <UITableViewDataSource, UITableViewDelegate>

@property (nonatomic, strong) IBOutlet UITableView *tableView;
@property (nonatomic, strong) UIImage *photo;

@end

//
//  ProfileTVC.h
//  Snapfeed
//
//  Created by Nino Vitale on 1/10/14.
//
//

#import <UIKit/UIKit.h>

@interface ProfileTVC : UITableViewController <UICollectionViewDataSource, UICollectionViewDelegate>

@property (nonatomic, strong) NSString *userID;

@end

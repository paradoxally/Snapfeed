//
//  ProfileTVC.m
//  Snapfeed
//
//  Created by Nino Vitale on 1/10/14.
//
//

#import "ProfileTVC.h"
#import "SNFFacebook.h"
#import "SNFProfilePhotosCollectionViewCell.h"
#import "SNFProfilePictureButton.h"
#import <FacebookSDK/FacebookSDK.h>
#import <SDWebImage/UIButton+WebCache.h>

@interface ProfileTVC ()

@property (nonatomic, strong) NSMutableArray *photos;

@property (strong, nonatomic) IBOutlet SNFProfilePictureButton *profilePicture;
@property (strong, nonatomic) IBOutlet UILabel *nameLabel;
@property (strong, nonatomic) IBOutlet UILabel *descLabel;
@property (strong, nonatomic) IBOutlet UILabel *numberFriendsLabel;
@property (strong, nonatomic) IBOutlet UILabel *numberPhotosLabel;
@property (strong, nonatomic) IBOutlet UICollectionView *collectionView;
@property (strong, nonatomic) IBOutlet UILabel *numberAlbumsLabel;

@end

@implementation ProfileTVC

- (NSMutableArray *)photos {
	if (!_photos) {
		_photos = [NSMutableArray new];
	}
	return _photos;
}

- (void)viewDidLoad {
	[super viewDidLoad];
    
    // This will remove extra separators from tableview
    self.tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    
	[self getPhotos];
}

- (void)viewWillAppear:(BOOL)animated {
	[super viewWillAppear:animated];
    
	if (FBSession.activeSession.isOpen) {
		DDLogVerbose(@"%@: %@", THIS_FILE, self.profilePicture);
		[self populateUserDetails];
	}
}

- (void)didReceiveMemoryWarning {
	[super didReceiveMemoryWarning];
	// Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source


- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
	// Return the number of sections.
	return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	// Return the number of rows in the section.
	return 3;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath  {
	if (indexPath.row == 0) {
		return 100;
	}
	if (indexPath.row == 1) {
		return 86;
	}
	if (self.photos.count > 0) {
		return ceilf((self.photos.count / 3)) * 106;
	}
	return 0;
}

#pragma mark - Collection view data source
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
	return self.photos.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
	static NSString *CellIdentifier = @"PhotoInCollectionView";
    
	SNFProfilePhotosCollectionViewCell *cell = (SNFProfilePhotosCollectionViewCell *)[self.collectionView dequeueReusableCellWithReuseIdentifier:CellIdentifier forIndexPath:indexPath];
    
	[cell prepareForReuse];
    
	// IMAGEM
	dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^{
	    NSString *imageURL = self.photos[indexPath.row][@"src"];
        DDLogVerbose(@"%@: Collection view image URL: %@", THIS_FILE, imageURL);
	    NSURL *url = [NSURL URLWithString:imageURL];
	    UIImage *image = [UIImage imageWithData:[NSData dataWithContentsOfURL:url]];
	    dispatch_sync(dispatch_get_main_queue(), ^{
	        //if ([[self.collectionView indexPathsForVisibleItems] containsObject:indexPath]) {
	        cell.thumbnail.image = image;
	        [cell setNeedsDisplay];
	        //}
		});
	});
    
	return cell;
}

- (void)populateUserDetails {
	if (!self.userID)
		self.userID = @"me";
    
	// PERSONAL INFO
	[[SNFFacebook sharedInstance] detailsFromUser:self.userID andResponse: ^(FBRequestConnection *request, NSDictionary *result, NSError *error) {
	    if (!error) {
	        dispatch_async(dispatch_get_main_queue(), ^{
	            NSString *numberUserID = result[@"id"];
	            self.nameLabel.text = [result objectForKey:@"name"];
	            self.descLabel.text = [[result objectForKey:@"location"] objectForKey:@"name"];
                
	            NSURL *profilePicURL = [[SNFFacebook sharedInstance] picURLForUser:numberUserID andSize:CGSizeMake(100, 100)];
	            if (profilePicURL) {
	                [self.profilePicture setProfileImageFromURL:profilePicURL forState:UIControlStateNormal];
				}
			});
		}
	}];
    
    
	// FRIENDS
	[[SNFFacebook sharedInstance] friendsFromUser:self.userID andResponse: ^(FBRequestConnection *request, NSDictionary *result, NSError *error) {
	    if (!error) {
	        NSArray *friends = [[result objectForKey:@"friends"] objectForKey:@"data"];
	        dispatch_async(dispatch_get_main_queue(), ^{
	            self.numberFriendsLabel.text = [NSString stringWithFormat:@"%lu", (unsigned long)friends.count];
			});
		}
	    else {
	        dispatch_async(dispatch_get_main_queue(), ^{
	            self.numberFriendsLabel.text = @"n/a";
			});
		}
	}];
    
    
	// PHOTOS
	[[SNFFacebook sharedInstance] photosFromUser:self.userID andResponse: ^(FBRequestConnection *request, id result, NSError *error) {
	    if (!error) {
	        int totalPhotos = 0;
	        int totalAlbums = 0;
	        for (NSDictionary * anAlbum in[result objectForKey:@"data"]) {
	            totalAlbums += 1;
	            totalPhotos += [anAlbum count];
			}
	        dispatch_async(dispatch_get_main_queue(), ^{
	            self.numberPhotosLabel.text = [NSString stringWithFormat:@"%d", totalPhotos];
	            self.numberAlbumsLabel.text = [NSString stringWithFormat:@"%d", totalAlbums];
			});
		}
	}];
}

- (void)getPhotos {
	[[SNFFacebook sharedInstance] getRecentPhotosFromUser:(self.userID ? self.userID : @"me()") andResponse: ^(FBRequestConnection *request, NSDictionary *result, NSError *error) {
	    if (!error) {
	        for (NSDictionary * photo in[result objectForKey:@"data"]) {
	            [self.photos addObject:photo];
			}
            
	        dispatch_async(dispatch_get_main_queue(), ^{
	            [self.collectionView reloadData];
	            [self.collectionView setNeedsDisplay];
	            [self.tableView beginUpdates];
	            [self.tableView endUpdates];
			});
		}
	}];
}

@end

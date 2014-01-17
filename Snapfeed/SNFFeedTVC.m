//
//  SNFFeedTVC.m
//  Snapfeed
//
//  Created by Nino Vitale on 12/17/13.
//
//

#import "SNFFeedTVC.h"
#import "SNFFacebook.h"
#import "SNFFeedPhotoCell.h"
#import "SNFFeedHeaderView.h"
#import "SNFAppDelegate.h"
#import "SNFRoundedRectButton.h"
#import "NSArray+PrettyPrint.h"
#import "SVPullToRefresh.h"
#import "SNFProfileTVC.h"
#import "SNFProgressOverlayView.h"
#import <SDWebImage/UIImageView+WebCache.h>
#import <SVWebViewController.h>
#import <UIImage+Resize.h>
#import <MobileCoreServices/MobileCoreServices.h>

NSString *const postLikedNotificationName = @"postLiked";
NSString *const postUnlikedNotificationName = @"postUnliked";

static const NSUInteger kTableViewHeaderHeight = 50;
static const NSUInteger kPhotoViewHeight = 320;

@interface SNFFeedTVC () <TTTAttributedLabelDelegate, UITableViewDelegate, UITableViewDataSource>

@property (nonatomic, strong) UIImagePickerController *picker;
@property (nonatomic, strong) NSMutableArray *posts; // data source
@property (nonatomic, strong) NSDictionary *paging; // data paging
@property (nonatomic, strong) NSMutableArray *postIDs; // all post IDs
@property (nonatomic, strong) NSMutableArray *likedPosts; // post IDs containing user like info
@property (nonatomic) BOOL isLoadingData;
@property (nonatomic, strong) NSString *activeUserID;

@end

@implementation SNFFeedTVC

- (UIImagePickerController *)picker {
	if (!_picker) {
		_picker = [[UIImagePickerController alloc] init];
	}
    
	return _picker;
}

- (NSMutableArray *)posts {
	if (!_posts) {
		_posts = [NSMutableArray new];
	}
    
	return _posts;
}

- (NSMutableArray *)likedPosts {
	if (!_likedPosts) {
		_likedPosts = [NSMutableArray new];
	}
    
	return _likedPosts;
}

- (NSMutableArray *)postIDs {
	if (!_postIDs) {
		_postIDs = [NSMutableArray new];
	}
    
	return _postIDs;
}

- (void)viewDidLoad {
	[super viewDidLoad];
    
	[self.navigationController.navigationBar setBarTintColor:[UIColor flatDarkBlueColor]];
	[self.navigationController.navigationBar setTintColor:[UIColor whiteColor]];
	[self.navigationController.navigationBar setTitleTextAttributes:@{ NSForegroundColorAttributeName : [UIColor whiteColor] }];
	[self.navigationController.navigationBar setTranslucent:NO];
    
	SNFProgressOverlayView *view = [[SNFProgressOverlayView alloc] initWithFrame:self.tableView.bounds];
	view.backgroundColor = [UIColor whiteColor];
	view.opaque = YES;
	[self.tableView addSubview:view];
	//[self.tableView bringSubviewToFront:view];
	[self.tableView setScrollEnabled:NO];
    
    [self setupRefreshControl:@selector(refreshControlgetPhotos)];
    
	if (![self.posts count] > 0)
		[self getPhotosWithURL:nil];
    
	__weak SNFFeedTVC *weakSelf = self;
	// setup infinite scrolling
	[self.tableView addInfiniteScrollingWithActionHandler: ^{
	    [weakSelf requestPostsAtBottom];
	}];
    
	[[NSNotificationCenter defaultCenter] addObserver:self
	                                         selector:@selector(postLiked:)
	                                             name:postLikedNotificationName
	                                           object:nil];
    
	[[NSNotificationCenter defaultCenter] addObserver:self
	                                         selector:@selector(postUnliked:)
	                                             name:postUnlikedNotificationName
	                                           object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(onReachabilityChanged:)
                                                 name:kDefaultNetworkReachabilityChangedNotification
                                               object:nil];
    
	//[self followScrollView:self.tableView];
}

- (void)didReceiveMemoryWarning {
	[super didReceiveMemoryWarning];
	// Dispose of any resources that can be recreated.
}

- (void)dealloc {
	[[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)refreshControlgetPhotos {
    [self getPhotosWithURL:nil];
}

- (void)setupRefreshControl:(SEL)action
{
    UIRefreshControl *refreshControl = [[UIRefreshControl alloc] init];
    [refreshControl addTarget:self action:action forControlEvents:UIControlEventValueChanged];
    self.refreshControl = refreshControl;
}

- (void)getPhotosWithURL:(NSString *)url {
	// We are going to load data
	self.isLoadingData = YES;
    
	DDLogInfo(@"%@: Getting main feed photos...", THIS_FILE);
	[[SNFFacebook sharedInstance] getMainFeedPhotosWithURL:url andResponse: ^(FBRequestConnection *request, NSDictionary *result, NSError *error) {
	    if (error) {
	        // If an error occurs, end all requests
	        DDLogError(@"%@: Error requesting posts: %@", THIS_FILE, error);
	        [self endPhotosFetchwithSuccess:NO firstFetch:(url ? NO : YES)];
            if (error.code == 5) {
                [self showNoConnectionNotification];
            }
		}
	    else {
	        // Add fetched posts to those we already have (if none, append to empty array)
            if (url) {
                [self.posts addObjectsFromArray:result[@"data"]];
            } else {
                self.posts = result[@"data"];
            }
	        // Save the paging for future "infinite scrolling" requests
	        self.paging = result[@"paging"];
            
	        // Reset post IDs and save the ones we just fetched
	        self.postIDs = nil;
	        for (id postID in[result valueForKeyPath:@"data.id"]) {
	            [self.postIDs addObject:postID];
			}
            
	        // Get the like status for the post IDs we saved
	        DDLogInfo(@"%@: Getting liked posts...", THIS_FILE);
	        [[SNFFacebook sharedInstance] getLikedPostsForIDs:[self.postIDs copy] andResponse: ^(FBRequestConnection *request, id result, NSError *error) {
	            // Add the result to our array for reference
                if (url) {
                    [self.likedPosts addObjectsFromArray:result[@"data"]];
                } else {
                    self.likedPosts = result[@"data"];
                }
                
	            // Clean up
	            [self endPhotosFetchwithSuccess:YES firstFetch:(url ? NO : YES)];
			}];
		}
	}];
}

- (void)endPhotosFetchwithSuccess:(BOOL)success firstFetch:(BOOL)first {
	__weak SNFFeedTVC *weakSelf = self;
    
	// Do UI operations on the main queue
	dispatch_async(dispatch_get_main_queue(), ^{
	    DDLogInfo(@"%@: Finished data fetch! First fetch: %@; Success: %@", THIS_FILE, BOOLtoNSString(first), BOOLtoNSString(success));
	    DDLogVerbose(@"%@", self.tableView.subviews);
	    for (id view in self.tableView.subviews) {
	        if ([view isMemberOfClass:[SNFProgressOverlayView class]]) {
	            [UIView animateWithDuration:0.5f
	                             animations: ^{
                                     [(SNFProgressOverlayView *)view setAlpha: 0];
                                 }
                 
	                             completion: ^(BOOL finished) {
                                     if (finished) {
                                         [view removeFromSuperview];
                                     }
                                 }];
	            [self.tableView setScrollEnabled:YES];
			} else {
                [self.refreshControl performSelector:@selector(endRefreshing) withObject:nil afterDelay:0];
            }
		}
	    if (!first) {
	        [weakSelf.tableView.infiniteScrollingView stopAnimating];
		}
	    self.isLoadingData = NO;
	    if (success) {
	        [weakSelf.tableView reloadData];
		}
	});
}

- (void)requestPostsAtBottom {
	__weak SNFFeedTVC *weakSelf = self;
    
	NSString *nextPostsURL = self.paging[@"next"];
	if (nextPostsURL) {
		[self getPhotosWithURL:nextPostsURL];
	}
	else {
		// If there is no post link to query the FB API, just end animation
		[weakSelf.tableView.infiniteScrollingView stopAnimating];
	}
}

- (void)onReachabilityChanged:(NSNotification *)notification
{
    KSReachability *reachability = (KSReachability *)notification.object;
    DDLogVerbose(@"%@: Reachability changed to %d. Flags = %x (NSNotification)", THIS_FILE, reachability.reachable, reachability.flags);
}

- (void)showNoConnectionNotification {
    // Display a non-intrusive alert to remind the user there is no Internet connection
    if (![[SNFAppDelegate sharedInstance] isReachable]) {
        [[TWMessageBarManager sharedInstance] showMessageWithTitle:@"Network Error"
                                                       description:@"Check your network connection. Facebook could also be down."
                                                              type:TWMessageBarMessageTypeError
                                                        duration:3.0];
    }
}

/*- (void)loadingData:(BOOL)isLoading {
 
 if(isLoading) {
 UIActivityIndicatorView * activityIndicator = [[UIActivityIndicatorView alloc] initWithFrame:CGRectMake(0, 0, 20, 20)];
 //set the initial property
 [activityIndicator startAnimating];
 [activityIndicator hidesWhenStopped];
 UIBarButtonItem * barButton = [[UIBarButtonItem alloc] initWithCustomView:activityIndicator];
 [self navigationItem].leftBarButtonItem = barButton;
 } else {
 [self navigationItem].leftBarButtonItem = nil;
 }
 }*/

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
	// Return the number of sections.
	return [self.posts count];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	// Return the number of rows in the section.
	return 1;
}

/*- (void)scrollViewDidScrollToTop:(UIScrollView *)scrollView {
 [self showNavbar];
 }*/

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	static NSString *cellIdentifier = @"FeedCell";
	SNFFeedPhotoCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier forIndexPath:indexPath];
	[cell prepareForReuse];
    
	if (!cell) {
		cell = [[SNFFeedPhotoCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
	}
    
	cell.likeLabel.text = @"";
	cell.likesSection.hidden = NO;
	cell.description.text = @"";
	cell.description.hidden = NO;
	[cell setLikeButtonSelected:NO];
    
	NSDictionary *post = self.posts[indexPath.section];
	cell.sectionIndex = indexPath.section;
	cell.postID = post[@"id"];
	DDLogVerbose(@"%@: Post ID: %@", THIS_FILE, cell.postID);
    
	NSInteger likedPostIndex = [self getLikedPostIndex:cell.postID];
	if (likedPostIndex != -1) {
		NSDictionary *likedPost = [self.likedPosts objectAtIndex:(NSUInteger)likedPostIndex];
		if (likedPost) {
			BOOL userLikesPost = [likedPost[@"like_info"][@"user_likes"] boolValue];
			if (userLikesPost) {
				[cell setLikeButtonSelected:YES];
			}
		}
	}
    
	cell.photoView.contentMode = UIViewContentModeScaleAspectFill;
	// By default, Facebook gives us a thumbnail of the image using the 'picture' key.
	// All thumbnail URLs are terminated with _s. We simply replace them with the _n terminators for normal images to show the large image
	NSURL *imageURL = [NSURL URLWithString:[post[@"picture"] stringByReplacingOccurrencesOfString:@"_s" withString:@"_n"]];
	DDLogVerbose(@"%@: Image URL: %@", THIS_FILE, imageURL);
	[cell.photoView setImageWithURL:imageURL];
    
	cell.likeCount = [post[@"likes"][@"summary"][@"total_count"] unsignedIntegerValue];
	DDLogVerbose(@"Likes: %u", (unsigned int)cell.likeCount);
	[cell setLikeLabelCount];
    
	if (cell.likeCount == 0) {
		cell.likesSection.hidden = YES;
	}
    
	NSString *description = post[@"message"];
	DDLogVerbose(@"Description: %@", description);
	if (!description) {
		description = @"";
		cell.description.hidden = YES;
	}
	else {
		cell.description.linkAttributes = @{ (NSString *)kCTForegroundColorAttributeName : (id)[[UIColor flatBlueColor] CGColor] };
		cell.description.enabledTextCheckingTypes = NSTextCheckingTypeLink; // Automatically detect links when the label text is subsequently changed
		cell.description.delegate = self;
		cell.description.text = description;
	}
    
	return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
	return kTableViewHeaderHeight;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
	SNFFeedHeaderView *header = [[SNFFeedHeaderView alloc]initWithFrame:CGRectMake(0, 0, 320, 50)];
    
	NSDictionary *postAuthor = self.posts[section][@"from"];
	header.userID = postAuthor[@"id"];
	header.username = postAuthor[@"name"];
	DDLogVerbose(@"%@: User ID: %@; Name: %@", THIS_FILE, header.userID, header.username);
	header.datePostedString = [[self.posts[section][@"created_time"] stringByReplacingOccurrencesOfString:@"+0000" withString:@""] stringByReplacingOccurrencesOfString:@"T" withString:@" "];
	DDLogVerbose(@"%@: Post %u date: %@", THIS_FILE, (unsigned int)section, header.datePostedString);
    
	header.avatarURL = [[SNFFacebook sharedInstance] picURLForUser:header.userID andSize:CGSizeMake(100, 100)];
    
	[header.avatarButton addTarget:self action:@selector(showProfileView:) forControlEvents:UIControlEventTouchUpInside];
	[header.fromUserButton addTarget:self action:@selector(showProfileView:) forControlEvents:UIControlEventTouchUpInside];
	// TAP ON FROM TO OPEN
	/*UITapGestureRecognizer *tapOnFromLabel = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(tappedOnFromLabel:)];
     [tapOnFromLabel setNumberOfTapsRequired:1];
     [header setUserInteractionEnabled:YES];
     [header addGestureRecognizer:tapOnFromLabel];*/
    
	return header;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
	NSString *description = self.posts[indexPath.section][@"message"];
	NSUInteger likes = [self.posts[indexPath.section][@"likes"][@"summary"][@"total_count"] unsignedIntegerValue];
    
	if (!description) {
		description = @"";
	}
    
	NSDictionary *attributesDictionary = @{ NSFontAttributeName : [UIFont systemFontOfSize:14.f] };
    
	CGRect extraDescriptionSize = [description boundingRectWithSize:CGSizeMake(295, CGFLOAT_MAX)
	                                                        options:(NSStringDrawingUsesLineFragmentOrigin | NSStringDrawingUsesFontLeading)
	                                                     attributes:attributesDictionary
	                                                        context:nil];
    
	//DDLogVerbose(@"%@: Extra size height: %.1f", THIS_FILE, kTableViewCellHeight + extraSize.size.height);
	return kPhotoViewHeight + (likes == 0 && ![description isEqualToString:@""] ? -25 : 0) + (likes == 0 && [description isEqualToString:@""] ? 10 : 40) + ceilf(extraDescriptionSize.size.height) + ([description isEqualToString:@""] ? 25 : 40);
}

- (void)showProfileView:(UIButton *)sender {
    NSIndexPath *indexPath = [self getIndexPathFromSender:sender];
    if (indexPath) {
        self.activeUserID = self.posts[indexPath.section][@"from"][@"id"];
        DDLogVerbose(@"%@: User ID %@ for post %u", THIS_FILE, self.activeUserID, (unsigned int)indexPath.section);
        [self performSegueWithIdentifier:@"showProfileView" sender:self];
    }
}


- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
	if ([segue.identifier isEqualToString:@"showProfileView"]) {
		SNFProfileTVC *profileVC = (SNFProfileTVC *)segue.destinationViewController;
		profileVC.userID = self.activeUserID;
	}
}

- (void)attributedLabel:(TTTAttributedLabel *)label didSelectLinkWithURL:(NSURL *)url {
	DDLogVerbose(@"%@: Tapped on link %@", THIS_FILE, url);
	SVWebViewController *webViewController = [[SVWebViewController alloc] initWithURL:url];
	webViewController.hidesBottomBarWhenPushed = YES;
	[self.navigationController pushViewController:webViewController animated:YES];
}

- (void)postLiked:(NSNotification *)notification {
	[self updateLikedPostsArrayWithPost:notification.userInfo andLike:YES];
}

- (void)postUnliked:(NSNotification *)notification {
	[self updateLikedPostsArrayWithPost:notification.userInfo andLike:NO];
}

- (NSInteger)getLikedPostIndex:(NSString *)postID {
	for (NSInteger i = 0; i < [self.likedPosts count]; i++) {
		if ([self.likedPosts[i][@"post_id"] isEqualToString:postID]) {
			return i;
		}
	}
    
	return -1;
}

- (void)updateLikedPostsArrayWithPost:(NSDictionary *)post
                              andLike:(BOOL)like {
	if (post) {
		NSInteger likedPostIndex = [self getLikedPostIndex:post[@"post_id"]];
		if (likedPostIndex != -1) {
			NSDictionary *likedPost = [self.likedPosts objectAtIndex:(NSUInteger)likedPostIndex];
			if (likedPost) {
				likedPost[@"like_info"][@"user_likes"] = (like ? @true : @false);
				[self.likedPosts replaceObjectAtIndex:likedPostIndex withObject:likedPost];
				DDLogVerbose(@"%@: Updated dictionary liked post object to %@: %@", THIS_FILE, (like ? @"true" : @"false"), likedPost.description);
			}
		}
	}
}

- (IBAction)postOptionsTapped:(SNFRoundedRectButton *)sender {
    NSIndexPath *indexPath = [self getIndexPathFromSender:sender];
    if (indexPath) {
        UIImage *image = [(UIImageView *)[[[self.tableView cellForRowAtIndexPath:indexPath] contentView] viewWithTag:100] image];
        DDLogVerbose(@"%@: Share image info: %@", THIS_FILE, image);
        [self showShareOptionsForImage:image];
    }
}

- (void)showShareOptionsForImage:(UIImage *)image {
    UIActivityViewController *shareController = [[UIActivityViewController alloc] initWithActivityItems:@[image] applicationActivities:nil];
    shareController.excludedActivityTypes = @[UIActivityTypePrint, UIActivityTypeAssignToContact];
    [self presentViewController:shareController animated:YES completion:nil];
}

- (IBAction)addPhotoTapped:(UIBarButtonItem *)sender {
	[self presentImagePicker:UIImagePickerControllerSourceTypeCamera];
}


#pragma mark - Helper methods

- (NSIndexPath *)getIndexPathFromSender:(id)sender {
    // Get position of the tapped button to figure out which cell header it came from
	CGPoint buttonPosition = [sender convertPoint:CGPointZero toView:self.tableView];
	// Grab the section number
	return [self.tableView indexPathForRowAtPoint:buttonPosition];
}

- (void)presentImagePicker:(UIImagePickerControllerSourceType)sourceType {
	/*NSArray *availableMediaTypes = [UIImagePickerController availableMediaTypesForSourceType:sourceType];
     if ([availableMediaTypes containsObject:(NSString *)kUTTypeImage]) {
     self.picker.sourceType = sourceType;
     self.picker.mediaTypes = @[(NSString *)kUTTypeImage];
     self.picker.allowsEditing = YES;
     self.picker.showsCameraControls = NO;
     self.picker.delegate = self;
     
     CGSize screenBounds = [UIScreen mainScreen].bounds.size;
     CGFloat cameraAspectRatio = 1.0f/1.0f;
     CGFloat camViewHeight = screenBounds.width * cameraAspectRatio;
     CGFloat scale = screenBounds.height / camViewHeight;
     
     self.picker.cameraViewTransform = CGAffineTransformMakeTranslation(0, (screenBounds.height - camViewHeight) / 2.0);
     self.picker.cameraViewTransform = CGAffineTransformScale(self.picker.cameraViewTransform, scale, scale);
     
     [[NSBundle mainBundle] loadNibNamed:@"CameraOverlayView" owner:self options:nil];
     self.cameraOverlayView.frame = self.picker.cameraOverlayView.frame;
     self.picker.cameraOverlayView = self.cameraOverlayView;
     self.cameraOverlayView = nil;
     
     [self presentViewController:self.picker animated:YES completion:nil];
     }*/
}

/*- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker {
 [self dismissViewControllerAnimated:YES completion:nil];
 }
 
 - (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info {
 // Let's get the edited image
 UIImage *image = info[UIImagePickerControllerEditedImage];
 // But if for some reason we disable editing in the future, this is our safeguard
 if (!image) image = info[UIImagePickerControllerOriginalImage];
 if (image) {
 DDLogVerbose(@"%@: Image details: %@", THIS_FILE, image.description);
 [self dismissViewControllerAnimated:YES completion:nil];
 }
 }
 
 - (IBAction)cameraCloseTapped:(UIButton *)sender {
 [self imagePickerControllerDidCancel:self.picker];
 }*/


/*- (UIImage *)imageManager:(SDWebImageManager *)imageManager transformDownloadedImage:(UIImage *)image withURL:(NSURL *)imageURL {
 UIImage *resizedImage = nil;
 
 if ([[imageURL absoluteString] rangeOfString:@"_n."].location != NSNotFound) {
 DDLogVerbose(@"%@: Photo image view original size: %.1f %.1f", THIS_FILE, image.size.width, image.size.height);
 return resizedImage = [image resizedImageToFitInSize:CGSizeMake(kPhotoViewSize, kPhotoViewSize) scaleIfSmaller:YES];
 } else if ([[imageURL absoluteString] rangeOfString:@"picture"].location != NSNotFound) {
 DDLogVerbose(@"%@: Header image view original size: %.1f %.1f", THIS_FILE, image.size.width, image.size.height);
 return resizedImage = [image resizedImageToFitInSize:CGSizeMake(kHeaderAvatarSize, kHeaderAvatarSize) scaleIfSmaller:YES];
 }
 
 DDLogVerbose(@"%@: No resize done, returning original image", THIS_FILE);
 return image;
 }*/

/*
 #pragma mark - Navigation
 
 // In a story board-based application, you will often want to do a little preparation before navigation
 - (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
 {
 // Get the new view controller using [segue destinationViewController].
 // Pass the selected object to the new view controller.
 }
 
 */

@end

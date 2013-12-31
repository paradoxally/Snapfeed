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
#import <SDWebImage/UIImageView+WebCache.h>
#import <SVWebViewController.h>
#import <UIImage+Resize.h>

static const NSUInteger kTableViewHeaderHeight = 50;
static const NSUInteger kTableViewCellHeight = 320;

//static const CGFloat kPhotoViewSize = 320;
//static const CGFloat kHeaderAvatarSize = 30;

@interface SNFFeedTVC () <TTTAttributedLabelDelegate>

@property (nonatomic, strong) NSMutableArray *posts; // data source
@property (nonatomic, strong) NSDictionary *paging; // data paging
@property (nonatomic, strong) NSMutableArray *postIDs; // all post IDs
@property (nonatomic, strong) NSMutableArray *likedPostIDs; // post IDs containing user like info
@property (nonatomic) BOOL isLoadingData;

@end

@implementation SNFFeedTVC

- (NSMutableArray *)likedPostIDs {
    if (!_likedPostIDs) {
        _likedPostIDs = [NSMutableArray new];
    }
    
    return _likedPostIDs;
}

- (NSMutableArray *)postIDs {
    if (!_postIDs) {
        _postIDs = [NSMutableArray new];
    }
    
    return _postIDs;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    //SDWebImageManager.sharedManager.delegate = self;
    
    if(![self.posts count] > 0)
        [self getPhotos];

    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
 
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
}

- (void)viewWillAppear:(BOOL)animated {
    
    [super viewWillAppear:animated];
    
    /*if(![self.posts count] > 0)
        [self getPhotos];*/
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)getPhotos {
    
    //[self loadingData:YES];
    
    self.isLoadingData = YES;
    [[SNFFacebook sharedInstance] getMainFeedPhotos:^(FBRequestConnection *request, NSDictionary *result, NSError *error) {
        self.posts = result[@"data"];
        self.paging = result[@"paging"];

        for (id postID in [result valueForKeyPath:@"data.id"]) {
            [self.postIDs addObject:postID];
        }
        
        [[SNFFacebook sharedInstance] getLikedPostsForIDs:[self.postIDs copy] andResponse:^(FBRequestConnection *request, id result, NSError *error) {
            [self.likedPostIDs addObjectsFromArray:result[@"data"]];
            
            dispatch_async(dispatch_get_main_queue(), ^{
                self.isLoadingData = NO;
                [self.tableView reloadData];
                [self.tableView setNeedsDisplay];
            });
        }];
    }];
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

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return [self.posts count];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    return 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
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
    
    for (NSDictionary *likedPostID in self.likedPostIDs) {
        if ([likedPostID[@"post_id"] isEqualToString:cell.postID]) {
            BOOL userLikesPost = [likedPostID[@"like_info"][@"user_likes"] boolValue];
            if (userLikesPost) {
                [cell setLikeButtonSelected:YES];
            }
            break;
        }
    }
    
    cell.photoView.contentMode = UIViewContentModeScaleAspectFill;
    // By default, Facebook gives us a thumbnail of the image using the 'picture' key.
    // All thumbnail URLs are terminated with _s. We simply replace them with the _n terminators for normal images to show the large image
    NSURL *imageURL = [NSURL URLWithString:[post[@"picture"] stringByReplacingOccurrencesOfString:@"_s" withString:@"_n"]];
    DDLogVerbose(@"%@: Image URL: %@", THIS_FILE, imageURL);
    [cell.photoView setImageWithURL:imageURL];
    
    NSUInteger likes = [post[@"likes"][@"summary"][@"total_count"] unsignedIntegerValue];
    DDLogVerbose(@"Likes: %lu", (unsigned long)likes);
    if (likes == 0) {
        cell.likesSection.hidden = YES;
    } else {
        cell.likeLabel.text = [NSString stringWithFormat:@"%lu likes", (unsigned long)likes];
    }
    
    NSString *description = post[@"message"];
    DDLogVerbose(@"Description: %@", description);;
    if(!description) {
        description = @"";
        cell.description.hidden = YES;
    } else {
        cell.description.linkAttributes = @{(NSString *)kCTForegroundColorAttributeName : (id)[[UIColor flatBlueColor] CGColor]};
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
    DDLogVerbose(@"%@: Post %ld date: %@", THIS_FILE, (long)section, header.datePostedString);
    
    NSURL *avatarURL = [NSURL URLWithString:[NSString stringWithFormat:@"https://graph.facebook.com/%@/picture", header.userID]];
    [header.avatar setImageWithURL:avatarURL placeholderImage:nil options:SDWebImageRefreshCached];
    
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
    
    NSDictionary *attributesDictionary = @{NSFontAttributeName : [UIFont systemFontOfSize:14.f]};
    
    CGRect extraDescriptionSize = [description boundingRectWithSize:CGSizeMake(295, CGFLOAT_MAX)
                                          options:(NSStringDrawingUsesLineFragmentOrigin | NSStringDrawingUsesFontLeading)
                                       attributes:attributesDictionary
                                          context:nil];
    
    //DDLogVerbose(@"%@: Extra size height: %.1f", THIS_FILE, kTableViewCellHeight + extraSize.size.height);
    return kTableViewCellHeight + (likes == 0 && ![description isEqualToString:@""] ? -25 : 0) + (likes == 0 && [description isEqualToString:@""] ? 10 : 40) + ceilf(extraDescriptionSize.size.height) + ([description isEqualToString:@""] ? 40 : 55);
}

- (void)attributedLabel:(TTTAttributedLabel *)label didSelectLinkWithURL:(NSURL *)url {
    DDLogVerbose(@"%@: Tapped on link %@", THIS_FILE, url);
    SVWebViewController *webViewController = [[SVWebViewController alloc] initWithURL:url];
    webViewController.hidesBottomBarWhenPushed = YES;
    [self.navigationController pushViewController:webViewController animated:YES];
}

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

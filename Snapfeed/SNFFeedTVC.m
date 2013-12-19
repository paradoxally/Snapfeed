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
#import <SDWebImage/UIImageView+WebCache.h>

static const NSUInteger kTableViewHeaderHeight = 50;
static const NSUInteger kTableViewCellHeight = 320;

@interface SNFFeedTVC ()

@property (nonatomic, strong) NSMutableArray *posts; // data source

@end

@implementation SNFFeedTVC

- (void)viewDidLoad
{
    [super viewDidLoad];

    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
 
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
}

- (void)viewWillAppear:(BOOL)animated {
    
    [super viewWillAppear:animated];
    
    if(![self.posts count] > 0)
        [self getPhotos];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)getPhotos {
    
    //[self loadingData:YES];
    
    [[SNFFacebook sharedInstance] getMainFeed:^(FBRequestConnection *request, NSDictionary *result, NSError *error) {
        self.posts = [NSMutableArray new];
        for (NSDictionary *post in result[@"data"]) {
            if([post[@"type"] isEqualToString:@"photo"])
                [self.posts addObject:post];
        }
        
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.tableView reloadData];
            [self.tableView setNeedsDisplay];
            [self loadingData:NO];
        });
        
    }];
}

- (void)loadingData:(BOOL)isLoading {
    
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
}

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
    
    NSString *description = (NSString *)self.posts[indexPath.section][@"message"];
    //DDLogVerbose(@"%@: Description for cell #%d: %@", THIS_FILE, indexPath.section,description);
    if(!description) {
        description = @"";
    }
    
    cell.description.text = description;
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
        // By default, Facebook gives us a thumbnail of the image using the 'picture' key.
        // All thumbnail URLs are terminated with _s. We simply replace them with the _n terminators for regular images to show the large image
        NSURL *imageURL = [NSURL URLWithString:[self.posts[indexPath.section][@"picture"] stringByReplacingOccurrencesOfString:@"_s" withString:@"_n"]];
        DDLogVerbose(@"%@: Image URL: %@", THIS_FILE, imageURL);
        dispatch_sync(dispatch_get_main_queue(), ^{
            [cell.photoView setImageWithURL:imageURL];
        });
    });
    
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return kTableViewHeaderHeight;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    
    SNFFeedHeaderView *header = [[SNFFeedHeaderView alloc]initWithFrame:CGRectMake(0, 0, 320, 50)];
    
    header.userID = [[[self.posts objectAtIndex:section] objectForKey:@"from"] objectForKey:@"id"];
    header.username = [[[self.posts objectAtIndex:section] objectForKey:@"from"] objectForKey:@"name"];
    header.datePostedString = [[[[self.posts objectAtIndex:section] objectForKey:@"created_time"] stringByReplacingOccurrencesOfString:@"+0000" withString:@""] stringByReplacingOccurrencesOfString:@"T" withString:@" "];
    header.sectionIndex = section;
    
    // TAP ON FROM TO OPEN
    /*UITapGestureRecognizer *tapOnFromLabel = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(tappedOnFromLabel:)];
    [tapOnFromLabel setNumberOfTapsRequired:1];
    [header setUserInteractionEnabled:YES];
    [header addGestureRecognizer:tapOnFromLabel];*/
    
    return header;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    NSString *description = (NSString *)[[self.posts objectAtIndex:indexPath.section]objectForKey:@"message"];
    if (!description) {
        description = @"";
    }
    
    NSDictionary *attributesDictionary = @{NSFontAttributeName : [UIFont systemFontOfSize:14.f]};
    
    CGRect extraSize = [description boundingRectWithSize:CGSizeMake(295, CGFLOAT_MAX)
                                          options:(NSStringDrawingUsesLineFragmentOrigin | NSStringDrawingUsesFontLeading)
                                       attributes:attributesDictionary
                                          context:nil];
    
    DDLogVerbose(@"%@: Extra size height: %.1f", THIS_FILE, kTableViewCellHeight + extraSize.size.height);
    return kTableViewCellHeight + ceilf(extraSize.size.height) + (!description ? 20 : 24+20+10);
}

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

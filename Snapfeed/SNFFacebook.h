//
//  SNFFacebook.h
//  Snapfeed
//
//  Created by Nino Vitale on 12/16/13.
//
//

#import <Foundation/Foundation.h>
#import <FacebookSDK/FacebookSDK.h>

@interface SNFFacebook : NSObject

typedef void (^FBRequestResponseWithUser)(FBRequestConnection *request, NSDictionary <FBGraphUser> *user, NSError *error);
typedef void (^FBRequestResponseWithDictionary)(FBRequestConnection *request, NSDictionary *result, NSError *error);
typedef void (^FBRequestResponseWithID)(FBRequestConnection *request, id result, NSError *error);

+ (instancetype)sharedInstance;

- (void)openSession;
- (FBSessionState)activeSessionState;

- (void)detailsFromUser:(NSString *)userID andResponse:(FBRequestResponseWithDictionary)response;
- (void)friendsFromUser:(NSString *)userID andResponse:(FBRequestResponseWithDictionary)response;
- (void)photosFromUser:(NSString *)userID andResponse:(FBRequestResponseWithID)response;
- (void)getRecentPhotosFromUser:(NSString *)userID andResponse:(FBRequestResponseWithDictionary)response;

- (void)getMainFeedPhotos:(FBRequestResponseWithDictionary)response;
- (void)getLikedPostsForIDs:(NSArray *)postIDs andResponse:(FBRequestResponseWithID)response;

- (void)likePost:(NSString *)postID andResponse:(FBRequestResponseWithID)response;
- (void)unlikePost:(NSString *)postID andResponse:(FBRequestResponseWithID)response;

- (NSURL *)picURLForUser:(NSString *)userID andSize:(CGSize)size;

@end

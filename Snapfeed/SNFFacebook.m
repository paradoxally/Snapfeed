//
//  SNFFacebook.m
//  Snapfeed
//
//  Created by Nino Vitale on 12/16/13.
//
//

#import "SNFFacebook.h"
#import "SNFAppDelegate.h"
#import "NSArray+PrettyPrint.h"

@implementation SNFFacebook

+ (instancetype)sharedInstance {
	static dispatch_once_t once;
	static id sharedInstance;
    
	dispatch_once(&once, ^
                  {
                      sharedInstance = [self new];
                  });
    
	return sharedInstance;
}

#pragma mark - PUBLIC METHODS

- (FBSessionState)activeSessionState {
	return [[FBSession activeSession] state];
}

- (void)openSession {
	[FBSession openActiveSessionWithReadPermissions:@[@"user_photos", @"read_stream", @"basic_info", @"user_location", @"email", @"user_friends", @"user_birthday"]
	                                   allowLoginUI:YES
	                              completionHandler:
	 ^(FBSession *session,
	   FBSessionState state, NSError *readPermissionsError) {
         [self sessionStateChanged:session state:state error:readPermissionsError];
         if (!readPermissionsError) {
             DDLogInfo(@"%@: Read permissions acquired for active session", THIS_FILE);
             if (![FBSession.activeSession.permissions containsObject:@"publish_stream"]) {
                 // We don't have publish permissions, so let's ask for them
                 DDLogVerbose(@"%@: No publish permissions, requesting...", THIS_FILE);
                 [FBSession.activeSession requestNewPublishPermissions:@[@"publish_stream"] defaultAudience:FBSessionDefaultAudienceFriends completionHandler:^(FBSession *session, NSError *publishPermissionsError) {
                     if (!publishPermissionsError) {
                         DDLogInfo(@"%@: Publish permissions acquired for active session", THIS_FILE);
                     } else {
                         DDLogError(@"%@: Error acquiring publish permissions - %@", THIS_FILE, publishPermissionsError);
                     }
                 }];
             } else {
                 DDLogInfo(@"%@: Already had publish permissions for active session", THIS_FILE);
             }
         } else {
             DDLogError(@"%@: Error acquiring read permissions - %@", THIS_FILE, readPermissionsError);
         }
     }];
}

- (void)detailsFromUser:(NSString *)userID andResponse:(FBRequestResponseWithDictionary)response {
	// DETAILS
	[[FBRequest requestForGraphPath:[NSString stringWithFormat:@"%@?fields=name,location", userID]] startWithCompletionHandler: ^(FBRequestConnection *connection, NSDictionary *result, NSError *error) {
	    response(connection, result, error);
	}];
}

- (void)myFriends:(FBRequestResponseWithDictionary)response {
	// FRIENDS
	[[FBRequest requestForGraphPath:@"me/friends?fields=picture.type(normal),name,id"] startWithCompletionHandler: ^(FBRequestConnection *connection, NSDictionary *result, NSError *error) {
	    response(connection, result, error);
	}];
}

- (void)friendsFromUser:(NSString *)userID andResponse:(FBRequestResponseWithDictionary)response {
	// FRIENDS
	[[FBRequest requestForGraphPath:[NSString stringWithFormat:@"%@/?fields=friends.fields(id,name,picture)", userID]] startWithCompletionHandler: ^(FBRequestConnection *connection, NSDictionary *result, NSError *error) {
	    response(connection, result, error);
	}];
}

- (void)myPhotos:(FBRequestResponseWithID)response {
	// TOTAL PHOTOS
	[[FBRequest requestForGraphPath:@"me/albums"] startWithCompletionHandler: ^(FBRequestConnection *connection, id result, NSError *error) {
	    response(connection, result, error);
	}];
}

- (void)photosFromUser:(NSString *)userID andResponse:(FBRequestResponseWithID)response {
	// TOTAL PHOTOS
	[[FBRequest requestForGraphPath:[NSString stringWithFormat:@"%@/albums", userID]] startWithCompletionHandler: ^(FBRequestConnection *connection, id result, NSError *error) {
	    response(connection, result, error);
	}];
}

- (void)getMainFeedPhotos:(FBRequestResponseWithDictionary)response {
	// MAIN FEED
	[[FBRequest requestForGraphPath:@"me/home?fields=type,from,picture,message,comments.limit(3).summary(true),likes.limit(1).summary(true)&filter=app_2305272732&limit=10"] startWithCompletionHandler: ^(FBRequestConnection *connection,
	                                                                                                                         NSDictionary *result,
	                                                                                                                         NSError *error) {
	    response(connection, result, error);
	}];
}

- (void)getLikedPostsForIDs:(NSArray *)postIDs andResponse:(FBRequestResponseWithID)response {
    NSString *query = [NSString stringWithFormat:
                       @"SELECT post_id, like_info.user_likes "
                       @"FROM stream "
                       @"WHERE post_id IN (%@) ", postIDs.prettyPrint];
    
    DDLogVerbose(@"%@: FQL query: %@", THIS_FILE, query);
    NSDictionary *queryParam = @{@"q" : query};
    
    [FBRequestConnection startWithGraphPath:@"/fql"
                                 parameters:queryParam
                                 HTTPMethod:@"GET"
                          completionHandler:^(FBRequestConnection *connection, id result, NSError *error) {
        response(connection, result, error);
    }];
}

- (void)likePost:(NSString *)postID andResponse:(FBRequestResponseWithID)response {
    [FBRequestConnection startWithGraphPath:[NSString stringWithFormat:@"%@/likes", postID]
                                  parameters:nil
                                  HTTPMethod:@"POST"
                           completionHandler:^(FBRequestConnection *connection, id result, NSError *error) {                               response(connection, result, error);
    }];
}

- (void)unlikePost:(NSString *)postID andResponse:(FBRequestResponseWithID)response {
    [FBRequestConnection startWithGraphPath:[NSString stringWithFormat:@"%@/likes", postID]
                                 parameters:nil
                                 HTTPMethod:@"DELETE"
                          completionHandler:^(FBRequestConnection *connection, id result, NSError *error) {                               response(connection, result, error);
                          }];
}

- (void)getRecentPhotosFromUser:(NSString *)pid andResponse:(FBRequestResponseWithDictionary)response {
	NSString *ors = @"me()";
	if (pid.length > 2) ors = pid;
    
	NSString *query = [NSString stringWithFormat:
	                   @"select caption, src from photo where owner=%@ order by created desc limit 18", ors];
    
	// Set up the query parameter
	NSDictionary *queryParam = @{ @"q": query };
	// Make the API request that uses FQL
	[FBRequestConnection startWithGraphPath:@"/fql"
	                             parameters:queryParam
	                             HTTPMethod:@"GET"
	                      completionHandler: ^(FBRequestConnection *connection,
	                                           id result,
	                                           NSError *error) {
                              response(connection, result, error);
                          }];
}

#pragma mark - PRIVATE METHODS

- (void)sessionStateChanged:(FBSession *)session
                      state:(FBSessionState)state
                      error:(NSError *)error {
	switch (state) {
		case FBSessionStateOpen: {
			// Login done
			DDLogInfo(@"%@: Login finished, show the main view!", THIS_FILE);
			[[NSNotificationCenter defaultCenter] postNotificationName:FBSessionStateOpenedNotification object:self];
			break;
		}
            
		case FBSessionStateClosed:
		case FBSessionStateClosedLoginFailed:
			DDLogError(@"%@: State is closed and/or login failed!", THIS_FILE);
			[FBSession.activeSession closeAndClearTokenInformation];
			break;
            
		default:
			break;
	}
    
	if (error) {
		[self showError:error];
	}
}

- (void)showError:(NSError *)error {
	DDLogError(@"%@: %@", THIS_FILE, error);
	UIAlertView *alertView = [[UIAlertView alloc]
	                          initWithTitle:@"Error"
                              message:[error localizedDescription]
                              delegate:nil
                              cancelButtonTitle:@"OK"
                              otherButtonTitles:nil];
	[alertView show];
}

@end

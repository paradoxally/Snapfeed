//
//  NSArray+PrettyPrint.m
//  Snapfeed
//
//  Created by Nino Vitale on 12/30/13.
//
//

#import "NSArray+PrettyPrint.h"

@implementation NSArray (PrettyPrint)

- (NSString *)prettyPrint {
    NSMutableString *outputString = [[NSMutableString alloc] init];
    BOOL firstItem = YES;
    for( id item in self ) {
        if (firstItem) {
            [outputString appendString:[NSString stringWithFormat:@"\"%@\"", [item description]]];
            firstItem = NO;
        } else {
            [outputString appendString:[NSString stringWithFormat:@", \"%@\"", [item description]]];
        }
    }
    
    return [outputString copy];
}

@end

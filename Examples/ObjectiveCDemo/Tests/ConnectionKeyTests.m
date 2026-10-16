#import <XCTest/XCTest.h>
#import "BrightSDKClient.h"
@interface ConnectionKeyTests : XCTestCase
@end
@implementation ConnectionKeyTests

- (void)testOptionalKeyResetsPreviouslyConfiguredSDKCredential {
    NSUserDefaults *defaults = NSUserDefaults.standardUserDefaults;
    id previous = [defaults objectForKey:@"BRIGHTSDK_APPKEY"];
    @try {
        NSString *key = @"aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa";
        [BrightSDKClient configureConnectionKey:[NSString stringWithFormat:@"  %@\n", key]];
        XCTAssertEqualObjects([defaults stringForKey:@"BRIGHTSDK_APPKEY"], key);
        [BrightSDKClient configureConnectionKey:@" \n"];
        XCTAssertEqualObjects([defaults stringForKey:@"BRIGHTSDK_APPKEY"],
                              @"00000000000000000000000000000000");
        [BrightSDKClient configureConnectionKey:@"bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb"];
        [BrightSDKClient configureConnectionKey:@""];
        XCTAssertEqualObjects([defaults stringForKey:@"BRIGHTSDK_APPKEY"],
                              @"00000000000000000000000000000000");
    } @finally {
        if (previous)
            [defaults setObject:previous forKey:@"BRIGHTSDK_APPKEY"];
        else
            [defaults removeObjectForKey:@"BRIGHTSDK_APPKEY"];
    }
}

@end

//
//  NetEngine.h
//  
//
//  Created by hetao on 12-11-13.
//
//

#import <Foundation/Foundation.h>

typedef void (^myCompletionHandler)(NSString *dataStr);
typedef void (^myErrorHandler)(NSError *error);

@interface NetEngine : NSObject 

+ (void)sendRequest:(NSString*)url completionHandler:(myCompletionHandler)myCompletionHandler errorHandler:(myErrorHandler)myErrorHandler;

@end

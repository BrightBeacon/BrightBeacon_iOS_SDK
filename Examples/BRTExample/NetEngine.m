//
//  NetEngine.m
//  
//
//  Created by hetao on 12-11-13.
//
//

#import "NetEngine.h"

@implementation NetEngine

+ (void)sendRequest:(NSString*)url completionHandler:(myCompletionHandler)myCompletionHandler errorHandler:(myErrorHandler)myErrorHandler
{
    
    //准备发送httprequest
    NSString *urlString = url;
    
    NSMutableURLRequest *request = [[[NSMutableURLRequest alloc] init] autorelease];
    
    [request setURL:[NSURL URLWithString:urlString]];
    
    [request setHTTPMethod:@"POST"];
    
    //设置http头
    
    NSString *contentType = [NSString stringWithFormat:@"text/xml"];
    
    [request addValue:contentType forHTTPHeaderField: @"Content-Type"];
    
    //创建http内容
    
    //NSMutableData *postBody = [NSMutableData data];
    
    //[postBody appendData:[[NSString stringWithFormat:@""] dataUsingEncoding:NSUTF8StringEncoding]];
    
    //[postBody appendData:[[NSString stringWithFormat:@""]
    
    //dataUsingEncoding:NSUTF8StringEncoding]];
    
    //[postBody appendData:[[NSString stringWithFormat:@""] dataUsingEncoding:NSUTF8StringEncoding]];
    
    //设置发送内容
    
    //[request setHTTPBody:postBody];
    
    //获取响应
    
    /*
    NSHTTPURLResponse* urlResponse = nil;
    
    NSError *error = [[[NSError alloc] init] autorelease];
    
    NSData *responseData = [NSURLConnection sendSynchronousRequest:request returningResponse:&urlResponse error:&error];
    
    NSString *result = [[[NSString alloc] initWithData:responseData encoding:NSUTF8StringEncoding] autorelease];
    
    //返回的http状态
    
    NSLog(@"Response Code: %d", [urlResponse statusCode]);
    
    //获取返回的内容
    
    if ([urlResponse statusCode] >= 200 && [urlResponse statusCode] < 300)
        
    {
        
        NSLog(@"Response: %@", result);
        
        return result;
        
        //执行你想要的内容，代码可以写在这里
        
    }
     */
    
    [NSURLConnection sendAsynchronousRequest:request queue:[NSOperationQueue mainQueue] completionHandler:
     ^(NSURLResponse *response,
       NSData *data,
       NSError *error){
         if (error == nil) {
             NSString *dataStr = [[[NSString alloc]initWithData:data encoding:NSUTF8StringEncoding] autorelease];
             myCompletionHandler(dataStr);
         } else {
             myErrorHandler(error);
         }
     }];
}

@end

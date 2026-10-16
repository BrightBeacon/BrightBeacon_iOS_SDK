//
//  BRTTools.h
//  BrightSDK
//
//  Created by thomasho on 16/9/18.
//  Copyright © 2016年 thomasho. All rights reserved.
//

#import <Foundation/Foundation.h>

#define subString(str,loc,len) [str substringWithRange:NSMakeRange(loc, len)]

@class CBUUID;
@interface BRTTools : NSObject

+ (NSData *)hex2data:(NSString *)hex;
+ (NSString *)data2hex:(NSData *)data;
+ (NSString *)data2UTF8:(NSData *)data;

//小端模式(little-endian) 0x0100 = 0001
+ (int32_t)data2Integer:(NSData *)data;
+ (NSData *)integer2data:(int32_t )value;
+ (NSData *)uinteger2data:(uint32_t )value;

+ (NSString *)toString:(CBUUID *)uuid;

+ (NSData *)number2leftPaddingZeroData:(NSNumber *)number withSize:(NSInteger)size;
+ (NSData *)hex2leftPaddingZeroData:(NSString *)data withSize:(NSInteger)size;

/**
*  转换Url为eddystone模式NSData
*  参考：https://github.com/google/eddystone/tree/master/eddystone-url
*
*  @param url 例(https://www.brtbeacon.com)->()
*
*  @return NSData
*/
+ (NSData *)eddystoneFromUrl:(NSString *)url;

/**
*  将eddystone模式下的Url字符串转换为普通url
*
*  @param eddystoneUrl eddystone-URL字符串
*
*  @return NSString
*/
+ (NSString *)urlFromEddystone:(NSString *)eddyUrl;

/**
距离估算方法，用于衡量不同设备距离差值，相对实际距离可能有误差

@param rssi 接收信号强度
@param mpower 1米处信号强度
@return 估算距离值
*/
+ (double)distanceByRssi:(NSInteger)rssi oneMeterRssi:(NSInteger)mpower;
@end

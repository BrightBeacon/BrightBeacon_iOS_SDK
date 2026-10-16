//
//  BrightC.h
//  BrightSDK
//
//  Created by thomasho on 16/1/13.
//  Copyright © 2016年 thomasho. All rights reserved.
//

#ifndef CBright_h
#define CBright_h

#define CBDataLen 23
typedef enum : int
{
    CB_Service=0,
    CB_RWData,
    CB_RData
} CB_IBeacon;

#define CB_SERVICE_IBeacon(x) [NSString stringWithFormat:@"E24BF79%d-334A-4F2B-AFA5-A5C960C29C06",x]

#endif /* BrightC_h */

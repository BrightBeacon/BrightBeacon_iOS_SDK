//
//  AntiLose.h
//  BrightSDK
//
//  Created by thomasho on 15-4-24.
//  Copyright (c) 2015年 thomasho. All rights reserved.
//

#ifndef BrightSDK_AntiLose_h
#define BrightSDK_AntiLose_h

typedef enum : int
{
    AL_IB_Service=0,
    AL_IB_UUID16_Major2_Minor2,
    AL_IB_Name20,
    AL_IB_Key16,//key
    AL_IB_Battery1_Temperature1,
    AL_IB_Mode2_Tx1_MPower1_Interval2_BateryInterval2_TempInterval2,//_LightInterval2_swInterval2_userdata2_reserved1
    AL_IB_Reserved20,
    AL_IB_SerialData
} AL_IBeacon;

typedef enum : int
{
    AL_P_Service=0,
    AL_P1_Distance3_Press4_PressLong5_AutoAnti6_Speaker7,
    AL_P_Time2,
    AL_P_Data8
} AL_Proximity;

typedef enum : int
{
    AL_DFU_Service = 0,
    AL_DFU_Ver4_Status4 = 1,
    AL_DFU_Data20 = 2
} AL_DFU;

#define AL_SERVICE_IBeacon(x) [NSString stringWithFormat:@"E204915%d-4645-417C-8125-983EC406D54A",x]
#define AL_SERVICE_Proximity(x) [NSString stringWithFormat:@"BB008B5%d-EC80-40BA-A6D2-4CE9D5BA5585",x]
#define AL_SERVICE_DFU(x) [NSString stringWithFormat:@"D2F17AA%d-3C68-4BD5-AAEA-57CC05371F86",x]

#endif

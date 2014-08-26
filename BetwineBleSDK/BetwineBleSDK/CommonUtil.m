//
//  CommonUtil.m
//  BetwineBleSDK
//
//  Created by imlab_DEV on 14-8-20.
//  Copyright (c) 2014年 imlab.cc. All rights reserved.
//

#import "CommonUtil.h"

@implementation CommonUtil

#pragma mark -- File related methods
+(NSString*)getDocumentDir
{
    return [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
}

+(NSString*)getCacheDir
{
    return [NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) objectAtIndex:0];
}

+(BOOL)fileExistAtPath:(NSString *)filePath
{
    return [[NSFileManager defaultManager] fileExistsAtPath:filePath];
}


#pragma mark -- Date related methods
+(NSInteger)getHourFromDate:(NSDate *)date
{
    NSDateComponents *components = [CommonUtil getTimeComponentsFromDate:date calenarUnit:NSHourCalendarUnit];
    
    return [components hour];
}

+(NSInteger)getMinutesFromDate:(NSDate *)date
{
    NSDateComponents *components = [CommonUtil getTimeComponentsFromDate:date calenarUnit:NSMinuteCalendarUnit];
    
    return [components minute];
}

+(NSDateComponents*)getTimeComponentsFromDate:(NSDate*)date calenarUnit:(NSUInteger)calendarUnit
{
    NSCalendar *calendar = [NSCalendar currentCalendar];
    NSDateComponents *components = [calendar components:calendarUnit fromDate:date];
    
    return components;
}

+(NSTimeInterval)differenceFromDate:(NSDate*)fromDate toDate:(NSDate*)toDate
{
    return [fromDate timeIntervalSinceDate:toDate];
}

@end

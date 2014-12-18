//
//  Created by imlab_DEV on 14-8-20.
//  Copyright (c) 2014 imlab.cc. All rights reserved.
//
//  Licensed under the Apache License, Version 2.0 (the "License");
//  you may not use this file except in compliance with the License.
//  You may obtain a copy of the License at
//
//      http://www.apache.org/licenses/LICENSE-2.0
//
//  Unless required by applicable law or agreed to in writing, software
//  distributed under the License is distributed on an "AS IS" BASIS,
//  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
//  See the License for the specific language governing permissions and
//  limitations under the License.
//

#import "BTCommonUtil.h"

@implementation BTCommonUtil

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
    NSDateComponents *components = [BTCommonUtil getTimeComponentsFromDate:date calenarUnit:NSHourCalendarUnit];
    
    return [components hour];
}

+(NSInteger)getMinutesFromDate:(NSDate *)date
{
    NSDateComponents *components = [BTCommonUtil getTimeComponentsFromDate:date calenarUnit:NSMinuteCalendarUnit];
    
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

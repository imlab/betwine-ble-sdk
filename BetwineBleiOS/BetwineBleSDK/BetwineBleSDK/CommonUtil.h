//
//  CommonUtil.h
//  BetwineBleSDK
//
//  Created by imlab_DEV on 14-8-20.
//  Copyright (c) 2014年 imlab.cc. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface CommonUtil : NSObject

/* File related methods */
+(NSString*)getDocumentDir;
+(NSString*)getCacheDir;
+(BOOL)fileExistAtPath:(NSString *)filePath;


/* Date utility methods */
+(NSInteger)getHourFromDate:(NSDate *)date;
+(NSInteger)getMinutesFromDate:(NSDate *)date;
+(NSTimeInterval)differenceFromDate:(NSDate*)fromDate toDate:(NSDate*)toDate;

@end

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

#import <Foundation/Foundation.h>

@interface BTCommonUtil : NSObject

/* File related methods */
+(NSString*)getDocumentDir;
+(NSString*)getCacheDir;
+(BOOL)fileExistAtPath:(NSString *)filePath;


/* Date utility methods */
+(NSInteger)getHourFromDate:(NSDate *)date;
+(NSInteger)getMinutesFromDate:(NSDate *)date;
+(NSTimeInterval)differenceFromDate:(NSDate*)fromDate toDate:(NSDate*)toDate;

@end

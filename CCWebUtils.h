//
//  CCWebUtils.h
//  CCWebUtils
//
//  Created by James Womack on 4/14/11.
//  Copyright 2011 Cirrostratus Co. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface CCWebUtils : NSObject

+ (NSString*)urlEscape:(NSString *)unencodedString;
+ (NSString*)addQueryStringToUrl:(NSString *)url params:(NSDictionary *)params;
+ (NSString*)postToUrl:(NSString *)urlString params:(NSDictionary *)params;
+ (NSData *)ut8postToUrl:(NSString *)urlString params:(NSDictionary *)params;
+ (NSData *)postImage:(UIImage *)theImage toUrl:(NSString *)urlString params:(NSDictionary *)params;
+ (BOOL)validateEmail:(NSString *)candidate;


@end

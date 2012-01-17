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
+ (NSString*)postToUrl:(id)url params:(NSDictionary *)params;
+ (NSString*)getFromUrl:(NSString *)url params:(NSDictionary *)params;
+ (NSString*)getFromUrl:(id)url;
+ (NSString*)stringWithContentsOfURL:(id)url method:(NSString *)HTTPMethod;
+ (NSData *)ut8postToUrl:(id)url params:(NSDictionary *)params;
+ (NSData *)postImage:(UIImage *)theImage toUrl:(id)url params:(NSDictionary *)params;
+ (NSData *)postImage:(UIImage *)theImage toUrl:(id)url params:(NSDictionary *)params withName:(NSString *)theName key:(NSString *)theKey;
+ (NSData *)postFile:(NSData *)theFile withName:(NSString *)theName key:(NSString *)theKey toUrl:(id)url params:(NSDictionary *)params;
+ (BOOL)validateEmail:(NSString *)candidate;
+ (void)handleError:(NSError *)error;

@end

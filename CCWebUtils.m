//
//  CCWebUtils.m
//  CCWebUtils
//
//  Created by James Womack on 4/14/11.
//  Copyright 2011 Cirrostratus Co. All rights reserved.
//

#import "CCWebUtils.h"

#ifndef __has_feature
#define __has_feature(x) 0
#endif

#ifdef __OBJC_GC__
#error CCWebUtils does not support Objective-C Garbage Collection
#endif

#if __has_feature(objc_arc)
#error CCWebUtils does not support Objective-C Automatic Reference Counting (ARC)
#endif

@implementation CCWebUtils

+ (NSString*)urlEscape:(NSString *)unencodedString {
	NSString *s = (NSString *)CFURLCreateStringByAddingPercentEscapes(NULL,
																	  (CFStringRef)unencodedString,
																	  NULL,
																	  (CFStringRef)@"!*'\"();:@&=+$,/?%#[]% ",
																	  kCFStringEncodingUTF8);
	return [s autorelease]; // Due to the 'create rule' we own the above and must autorelease it
}

// Put a query string onto the end of a url
+ (NSString*)addQueryStringToUrl:(NSString *)url params:(NSDictionary *)params {
	NSMutableString *urlWithQuerystring = [[[NSMutableString alloc] initWithString:url] autorelease];
	// Convert the params into a query string
	if (params) {
		for(id key in params) {
			NSString *sKey = [key description];
			NSString *sVal = [[params objectForKey:key] description];
			// Do we need to add ?k=v or &k=v ?
			if ([urlWithQuerystring rangeOfString:@"?"].location==NSNotFound) {
				[urlWithQuerystring appendFormat:@"?%@=%@", [CCWebUtils urlEscape:sKey], [CCWebUtils urlEscape:sVal]];
			} else {
				[urlWithQuerystring appendFormat:@"&%@=%@", [CCWebUtils urlEscape:sKey], [CCWebUtils urlEscape:sVal]];
			}
		}
	}
	return urlWithQuerystring;
}


+ (NSData *)ut8postToUrl:(NSString *)urlString params:(NSDictionary *)params; {	
	NSString *post = @"";
	// Convert the params into a query string
	if (params) {
		for(id key in params) {
			if ([post length]) {
				post = [post stringByAppendingString:@"&"];
			}
			post = [post stringByAppendingFormat:@"%@=%@",key,[params objectForKey:key]];
		}
	}
	
	ILogPlus(@"url:%@ post: %@",urlString,post);
	
	NSData *postData = [post dataUsingEncoding:NSUTF8StringEncoding];
	
	NSString *postLength = String(@"%d", [postData length]);
	
	NSMutableURLRequest *request = [[[NSMutableURLRequest alloc] init] autorelease];
	[request setURL:[NSURL URLWithString:urlString]];
	[request setHTTPMethod:@"POST"];
	[request setValue:postLength forHTTPHeaderField:@"Content-Length"];
	[request setValue:@"application/x-www-form-urlencoded" forHTTPHeaderField:@"Content-Type"];
	[request setHTTPBody:postData];
	
	NSError *error = nil;
	
	NSData *returnData2 = [NSURLConnection sendSynchronousRequest: request returningResponse: nil error: &error ];
	if (error) {
		ILogPlus(@"Error: %@",error);
	}
	
	return returnData2;
}

// Put a query string onto the end of a url
+ (NSString*)postToUrl:(NSString *)urlString params:(NSDictionary *)params {
	NSData *returnData2 = [self ut8postToUrl:urlString params:params];
    
	NSString *s = [[NSString alloc] initWithBytes:[returnData2 bytes] length:[returnData2 length] encoding:NSUTF8StringEncoding];	
	
	ILogPlus(@"%@, %@",s,returnData2);

	return [s autorelease];
}

+ (BOOL)validateEmail:(NSString *)candidate; {
    NSString *emailRegEx =
	@"(?:[a-z0-9!#$%\\&'*+/=?\\^_`{|}~-]+(?:\\.[a-z0-9!#$%\\&'*+/=?\\^_`{|}"
	@"~-]+)*|\"(?:[\\x01-\\x08\\x0b\\x0c\\x0e-\\x1f\\x21\\x23-\\x5b\\x5d-\\"
	@"x7f]|\\\\[\\x01-\\x09\\x0b\\x0c\\x0e-\\x7f])*\")@(?:(?:[a-z0-9](?:[a-"
	@"z0-9-]*[a-z0-9])?\\.)+[a-z0-9](?:[a-z0-9-]*[a-z0-9])?|\\[(?:(?:25[0-5"
	@"]|2[0-4][0-9]|[01]?[0-9][0-9]?)\\.){3}(?:25[0-5]|2[0-4][0-9]|[01]?[0-"
	@"9][0-9]?|[a-z0-9-]*[a-z0-9]:(?:[\\x01-\\x08\\x0b\\x0c\\x0e-\\x1f\\x21"
	@"-\\x5a\\x53-\\x7f]|\\\\[\\x01-\\x09\\x0b\\x0c\\x0e-\\x7f])+)\\])";
	
	
	NSPredicate *regExPredicate = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", emailRegEx];
	return [regExPredicate evaluateWithObject:candidate];
}

@end

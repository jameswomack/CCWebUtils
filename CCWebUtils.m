//
//  CCWebUtils.m
//  CCWebUtils
//
//  Created by James Womack on 4/14/11.
//  Copyright 2011 Cirrostratus Co. All rights reserved.
//

#import "CCWebUtils.h"


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

@end

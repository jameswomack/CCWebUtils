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


+ (NSString*)getFromUrl:(NSString *)url params:(NSDictionary *)params; {    
	return [self getFromUrl:[self addQueryStringToUrl:url params:params]];
}

+ (NSString*)getFromUrl:(id)url; {
    NSMutableURLRequest *request = [[[NSMutableURLRequest alloc] init] autorelease];
    if ([url isKindOfClass:[NSURL class]]) {
        [request setURL:url];
    }else {
        [request setURL:[NSURL URLWithString:url]];
    }	
	[request setHTTPMethod:@"GET"];
    [request setTimeoutInterval:30.0f];
    
	NSError *error = nil;
	NSData *returnData2 = [NSURLConnection sendSynchronousRequest: request returningResponse: nil error: &error];
    
	if (error) {
		ALog(@"Error: %@",error);
        [self performSelectorOnMainThread:@selector(handleError:) withObject:error waitUntilDone:NO];
	}
	
	NSString *s = [[[NSString alloc] initWithBytes:[returnData2 bytes] length:[returnData2 length] encoding:NSUTF8StringEncoding] autorelease];	
    
	return [NSString stringWithString:s];
}

+ (NSString*)stringWithContentsOfURL:(id)url method:(NSString *)HTTPMethod; {
	//implement later
	return nil;
}

+ (NSData *)ut8postToUrl:(id)url params:(NSDictionary *)params; {

    
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
	
	//ILogPlus(@"url:%@ post: %@",url,post);
	
	NSData *postData = [post dataUsingEncoding:NSUTF8StringEncoding];

	NSString *postLength = String(@"%d", [postData length]);

	NSMutableURLRequest *request = [[[NSMutableURLRequest alloc] init] autorelease];
    if ([url isKindOfClass:[NSURL class]]) {
        [request setURL:url];
    }else {
        [request setURL:[NSURL URLWithString:url]];
    }	
	[request setHTTPMethod:@"POST"];
	[request setValue:postLength forHTTPHeaderField:@"Content-Length"];
	[request setValue:@"application/x-www-form-urlencoded" forHTTPHeaderField:@"Content-Type"];
	[request setHTTPBody:postData];
    [request setTimeoutInterval:30.0f];

	NSError *error = nil;
	NSData *returnData2 = [NSURLConnection sendSynchronousRequest: request returningResponse: nil error: &error];
    
	if (error) 
    {
		ALog(@"Error: %@",error);
        [self performSelectorOnMainThread:@selector(handleError:) withObject:error waitUntilDone:NO];
	}
	NSParameterAssert(returnData2!=nil);
    
	return [NSData dataWithData:returnData2];
}

+ (void)handleError:(NSError *)error; {
    Alert(0, nil, [error localizedDescription], @"Ok", nil);
}

+ (NSData *)postImage:(UIImage *)theImage toUrl:(id)url params:(NSDictionary *)params; {		
	return [self postFile:UIImageJPEGRepresentation(theImage, 1.0) withName:@"image.jpg" key:@"image" toUrl:url params:params];
}

+ (NSData *)postImage:(UIImage *)theImage toUrl:(id)url params:(NSDictionary *)params withName:(NSString *)theName key:(NSString *)theKey; {
    return [self postFile:UIImageJPEGRepresentation(theImage, 1.0) withName:theName key:theKey toUrl:url params:params];
}

+ (NSData *)postFile:(NSData *)theFile withName:(NSString *)theName key:(NSString *)theKey toUrl:(id)url params:(NSDictionary *)params; {	
    NSMutableURLRequest *request = [[[NSMutableURLRequest alloc] init] autorelease];
    
    NSString *boundary = [NSString stringWithString:@"---------------------------14737809831466499882746641449"];  
    NSString *contentType = [NSString stringWithFormat:@"multipart/form-data; boundary=%@",boundary];  
    [request addValue:contentType forHTTPHeaderField: @"Content-Type"];  
    
    NSMutableData *body = [NSMutableData data]; 
    
	// Convert the params into form data
	if (params) {
		for(id key in params) { 
            if (![key isEqualToString:theKey]) {
                [body appendData:[[NSString stringWithFormat:@"Content-Disposition: form-data; name=\"%@\"\r\n\r\n%@",key,[params objectForKey:key]] dataUsingEncoding:NSUTF8StringEncoding]];  
                [body appendData:[[NSString stringWithFormat:@"\r\n--%@\r\n",boundary] dataUsingEncoding:NSUTF8StringEncoding]];
            }else {

            }
		}
	}
    
    [request setHTTPMethod:@"POST"];
    // Add the image to the form data
    [body appendData:[String(@"Content-Disposition: form-data; name=\"%@\"; filename=\"%@\"\r\n",theKey,theName) dataUsingEncoding:NSUTF8StringEncoding]];  
    [body appendData:[[NSString stringWithString:@"Content-Type: application/octet-stream\r\n\r\n"] dataUsingEncoding:NSUTF8StringEncoding]];  
    [body appendData:theFile];  
    [body appendData:[[NSString stringWithFormat:@"\r\n--%@--\r\n",boundary] dataUsingEncoding:NSUTF8StringEncoding]]; 
	
	//ILogPlus(@"url:%@ post: %@",url,body);
    
	if ([url isKindOfClass:[NSURL class]]) {
        [request setURL:url];
    }else {
        [request setURL:[NSURL URLWithString:url]];
    }

	//[request setValue:postLength forHTTPHeaderField:@"Content-Length"];
    [request setHTTPBody:body];

	
	NSError *error = nil;
	
	NSData *returnData2 = [NSURLConnection sendSynchronousRequest: request returningResponse: nil error: &error ];
	if (error) {
		ALog(@"Error: %@",error);
	}
	
	return [NSData dataWithData:returnData2];
}

// Put a query string onto the end of a url
+ (NSString*)postToUrl:(id)url params:(NSDictionary *)params {

    
	NSData *returnData2 = [self ut8postToUrl:url params:params];
    
	NSString *s = [[NSString alloc] initWithBytes:[returnData2 bytes] length:[returnData2 length] encoding:NSUTF8StringEncoding];	
	
    NSParameterAssert(s);

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

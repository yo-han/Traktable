//
//  TMDBRequest.m
//  iTMDb
//
//  Created by Christian Rasmussen on 04/11/10.
//  Copyright 2010 Apoltix. All rights reserved.
//  Modified by Alessio Moiso on 16/01/13,
//  Copyright 2013 MrAsterisco. All rights reserved.
//

#import "TMDBRequest.h"

#import "SBJson.h"

@implementation TMDBRequest

@synthesize delegate=_delegate;

+ (TMDBRequest *)requestWithURL:(NSURL *)url delegate:(id <TMDBRequestDelegate>)aDelegate
{
	return [[TMDBRequest alloc] initWithURL:url delegate:aDelegate];
}

+ (TMDBRequest *)requestWithURL:(NSURL *)url completionBlock:(void (^)(NSDictionary *parsedData))block
{
	return [[TMDBRequest alloc] initWithURL:url completionBlock:block];
}

- (id)initWithURL:(NSURL *)url delegate:(id<TMDBRequestDelegate>)delegate
{
	if ((self = [super init]))
	{
		NSMutableURLRequest *req = [NSMutableURLRequest requestWithURL:url cachePolicy:NSURLRequestReloadIgnoringCacheData timeoutInterval:30.0];
		
		if ([NSURLConnection connectionWithRequest:req delegate:self])
		{
			_data = [NSMutableData data];
			_delegate = delegate;
		}
	}
	return self;
}

- (id)initWithURL:(NSURL *)url completionBlock:(void (^)(NSDictionary *parsedData))block
{
	if ((self = [super init]))
	{
		NSMutableURLRequest *req = [NSMutableURLRequest requestWithURL:url cachePolicy:NSURLRequestReloadIgnoringCacheData timeoutInterval:30.0];
		
		if ([NSURLConnection connectionWithRequest:req delegate:self])
		{
			_data = [NSMutableData data];
			_completionBlock = [block copy];
		}
	}
	return self;
}

#pragma mark -
- (NSDictionary *)parsedData
{
	NSDictionary *jsonData = nil;

	if (NSClassFromString(@"NSJSONSerialization"))
	{
		jsonData = [NSJSONSerialization JSONObjectWithData:_data options:0 error:NULL];
	}
	else
	{
		NSString *parsedDataString = [[NSString alloc] initWithData:_data encoding:NSUTF8StringEncoding];
		jsonData = (NSDictionary *)[parsedDataString JSONValue];
	}
	//if (!jsonData)

	return jsonData;
}

#pragma mark -
#pragma mark NSURLConnection delegate
- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response
{
	[_data setLength:0];
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)thedata
{
	[_data appendData:thedata];
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error
{
	_data = nil;

	if (self.delegate && [self.delegate respondsToSelector:@selector(request:didFinishLoading:)])
		[self.delegate request:self didFinishLoading:error];
	if (_completionBlock)
		_completionBlock(nil);
	//else
	//	NSLog(@"TMDBRequest did fail with error: %@", error);
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection
{
	if (self.delegate && [self.delegate respondsToSelector:@selector(request:didFinishLoading:)])
		[self.delegate request:self didFinishLoading:nil];
	if (_completionBlock)
		_completionBlock([self parsedData]);
	//else
	//	NSLog(@"TMDBRequest: Neither a delegate nor a block was set.");

	_data = nil;
}

#pragma mark -

@end
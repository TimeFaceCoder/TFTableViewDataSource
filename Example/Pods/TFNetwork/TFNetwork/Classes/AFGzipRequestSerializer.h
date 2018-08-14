//
//  AFgzipRequestSerializer.h
//  Pods
//
//  Created by Melvin on 24/11/2016.
//
//

#import <AFNetworking/AFNetworking.h>

@interface AFGzipRequestSerializer : AFHTTPRequestSerializer

@property (readonly, nonatomic, strong) id <AFURLRequestSerialization> serializer;


+ (instancetype)serializerWithSerializer:(id <AFURLRequestSerialization>)serializer;

@end

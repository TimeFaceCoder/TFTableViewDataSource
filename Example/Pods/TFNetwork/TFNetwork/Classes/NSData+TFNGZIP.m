//
//  NSData+TFNGZIP.m
//  TFNetwork
//
//  Created by Melvin on 3/17/16.
//  Copyright © 2016 TimeFace. All rights reserved.
//

#import "NSData+TFNGZIP.h"
#import <zlib.h>
#import <dlfcn.h>

static const int kTFNzippaChunkSize = 1024;
static const int kTFNzippaDefaultMemoryLevel = 8;
static const int kTFNzippaDefaultWindowBits = 15;
static const int kTFNzippaDefaultWindowBitsWithGZipHeader = 16 + kTFNzippaDefaultWindowBits;

NSString * const TFNzippaZlibErrorDomain = @"cn.timeface.zlib.error";

@implementation NSData (TFNGZIP)

- (NSData *)dataByGZipCompressingWithError:(NSError * __autoreleasing *)error {
    return [self dataByGZipCompressingAtLevel:Z_DEFAULT_COMPRESSION windowSize:kTFNzippaDefaultWindowBitsWithGZipHeader memoryLevel:kTFNzippaDefaultMemoryLevel strategy:Z_DEFAULT_STRATEGY error:error];
}

- (NSData *)dataByGZipCompressingAtLevel:(int)level
                              windowSize:(int)windowBits
                             memoryLevel:(int)memLevel
                                strategy:(int)strategy
                                   error:(NSError * __autoreleasing *)error
{
    if ([self length] == 0) {
        return self;
    }
    
    z_stream zStream;
    bzero(&zStream, sizeof(z_stream));
    
    zStream.zalloc = Z_NULL;
    zStream.zfree = Z_NULL;
    zStream.opaque = Z_NULL;
    zStream.next_in = (Bytef *)[self bytes];
    zStream.avail_in = (unsigned int)[self length];
    zStream.total_out = 0;
    
    OSStatus status;
    if ((status = deflateInit2(&zStream, level, Z_DEFLATED, windowBits, memLevel, strategy)) != Z_OK) {
        if (error) {
            NSDictionary *userInfo = [NSDictionary dictionaryWithObject:NSLocalizedString(@"Failed deflateInit", nil) forKey:NSLocalizedDescriptionKey];
            *error = [[NSError alloc] initWithDomain:TFNzippaZlibErrorDomain code:status userInfo:userInfo];
        }
        
        return nil;
    }
    
    NSMutableData *compressedData = [NSMutableData dataWithLength:kTFNzippaChunkSize];
    
    do {
        if ((status == Z_BUF_ERROR) || (zStream.total_out == [compressedData length])) {
            [compressedData increaseLengthBy:kTFNzippaChunkSize];
        }
        
        zStream.next_out = (Bytef*)[compressedData mutableBytes] + zStream.total_out;
        zStream.avail_out = (unsigned int)([compressedData length] - zStream.total_out);
        
        status = deflate(&zStream, Z_FINISH);
    } while ((status == Z_OK) || (status == Z_BUF_ERROR));
    
    deflateEnd(&zStream);
    
    if ((status != Z_OK) && (status != Z_STREAM_END)) {
        if (error) {
            NSDictionary *userInfo = [NSDictionary dictionaryWithObject:NSLocalizedString(@"Error deflating payload", nil) forKey:NSLocalizedDescriptionKey];
            *error = [[NSError alloc] initWithDomain:TFNzippaZlibErrorDomain code:status userInfo:userInfo];
        }
        
        return nil;
    }
    
    [compressedData setLength:zStream.total_out];
    
    return compressedData;
}

- (NSData *)dataByGZipDecompressingDataWithError:(NSError * __autoreleasing *)error {
    return [self dataByGZipDecompressingDataWithWindowSize:kTFNzippaDefaultWindowBitsWithGZipHeader error:error];
}

- (NSData *)dataByGZipDecompressingDataWithWindowSize:(int)windowBits
                                                error:(NSError * __autoreleasing *)error
{
    if ([self length] == 0) {
        return self;
    }
    
    z_stream zStream;
    bzero(&zStream, sizeof(z_stream));
    
    zStream.zalloc = Z_NULL;
    zStream.zfree = Z_NULL;
    zStream.opaque = Z_NULL;
    zStream.avail_in = (unsigned int)[self length];
    zStream.next_in = (Byte *)[self bytes];
    
    OSStatus status;
    if ((status = inflateInit2(&zStream, windowBits)) != Z_OK) {
        if (error) {
            NSDictionary *userInfo = [NSDictionary dictionaryWithObject:NSLocalizedString(@"Failed inflateInit", nil) forKey:NSLocalizedDescriptionKey];
            *error = [[NSError alloc] initWithDomain:TFNzippaZlibErrorDomain code:status userInfo:userInfo];
        }
        
        return nil;
    }
    
    NSUInteger estimatedLength = (NSUInteger)((double)[self length] * 1.5);
    NSMutableData *decompressedData = [NSMutableData dataWithLength:estimatedLength];
    
    do {
        if ((status == Z_BUF_ERROR) || (zStream.total_out == [decompressedData length])) {
            [decompressedData increaseLengthBy:estimatedLength / 2];
        }
        
        zStream.next_out = (Bytef*)[decompressedData mutableBytes] + zStream.total_out;
        zStream.avail_out = (unsigned int)([decompressedData length] - zStream.total_out);
        
        status = inflate(&zStream, Z_FINISH);
    } while ((status == Z_OK) || (status == Z_BUF_ERROR));
    
    inflateEnd(&zStream);
    
    if ((status != Z_OK) && (status != Z_STREAM_END)) {
        if (error) {
            NSDictionary *userInfo = [NSDictionary dictionaryWithObject:NSLocalizedString(@"Error inflating payload", nil) forKey:NSLocalizedDescriptionKey];
            *error = [[NSError alloc] initWithDomain:TFNzippaZlibErrorDomain code:status userInfo:userInfo];
        }
        
        return nil;
    }
    
    [decompressedData setLength:zStream.total_out];
    
    return decompressedData;
}
@end

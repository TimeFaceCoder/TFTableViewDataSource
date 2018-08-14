//
//  NSData+TFNGZIP.h
//  TFNetwork
//
//  Created by Melvin on 3/17/16.
//  Copyright © 2016 TimeFace. All rights reserved.
//

#import <Foundation/Foundation.h>

extern NSString * const TFNzippaZlibErrorDomain;


@interface NSData (TFNGZIP)

- (NSData *)dataByGZipCompressingWithError:(NSError * __autoreleasing *)error;
- (NSData *)dataByGZipCompressingAtLevel:(int)level
                              windowSize:(int)windowBits
                             memoryLevel:(int)memLevel
                                strategy:(int)strategy
                                   error:(NSError * __autoreleasing *)error;
- (NSData *)dataByGZipDecompressingDataWithError:(NSError * __autoreleasing *)error;
- (NSData *)dataByGZipDecompressingDataWithWindowSize:(int)windowBits
                                                error:(NSError * __autoreleasing *)error;
@end

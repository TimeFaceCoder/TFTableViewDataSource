//
//  NSData+TFNGZIP.h
//  TFNetwork
//
//  Created by Melvin on 3/17/16.
//  Copyright © 2016 TimeFace. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSData (TFNGZIP)

- (nullable NSData *)tfn_gzippedDataWithCompressionLevel:(float)level;
- (nullable NSData *)tfn_gzippedData;
- (nullable NSData *)tfn_gunzippedData;
- (BOOL)tfn_isGzippedData;

@end

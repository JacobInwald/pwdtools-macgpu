//
//  GPUBruteForceEngine.h
//  pwd-crackl
//
//  Created by Jacob Inwald on 04/12/2023.
//

#import <Foundation/Foundation.h>
#import <Metal/Metal.h>


NS_ASSUME_NONNULL_BEGIN

@interface GPUBruteForceMD5Engine: NSObject
- (instancetype) initWithDevice: (id<MTLDevice>) device;
- (void) prepareData: (char*) hash, uint n;
- (void) sendComputeCommand;
@end

NS_ASSUME_NONNULL_END

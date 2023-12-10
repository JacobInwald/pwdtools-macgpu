/*
See LICENSE folder for this sample’s licensing information.

Abstract:
An app that performs a simple calculation on a GPU.
*/

#import <Foundation/Foundation.h>
#import <Metal/Metal.h>
#import "GPUBruteForceEngine.h"
#import "GPUBruteForceMD5Engine.h"
#include "constants.h"
#include <inttypes.h>

// This is the C version of the function that the sample
// implements in Metal Shading Language.
//

int main(int argc, const char * argv[]) {
    
//    @autoreleasepool {
//        
//        id<MTLDevice> device = MTLCreateSystemDefaultDevice();
//
//        // Create the custom object used to encapsulate the Metal code.
//        // Initializes objects to communicate with the GPU.
//        GPUBruteForceEngine* cracker = [[GPUBruteForceEngine alloc] initWithDevice:device];
//        
//        // Create buffers to hold data
//        [cracker prepareData];
//        
//        // Send a command to the GPU to perform the calculation.
//        [cracker sendComputeCommand];
//        NSLog(@"Execution finished");
//    }
    
    @autoreleasepool {
        
        id<MTLDevice> device = MTLCreateSystemDefaultDevice();

        // Create the custom object used to encapsulate the Metal code.
        // Initializes objects to communicate with the GPU.
        GPUBruteForceMD5Engine* cracker = [[GPUBruteForceMD5Engine alloc] initWithDevice:device];
        
        // Create buffers to hold data
        [cracker prepareData];
        
        // Send a command to the GPU to perform the calculation.
        [cracker sendComputeCommand];
        NSLog(@"Execution finished");
    }
//    return 0;
}



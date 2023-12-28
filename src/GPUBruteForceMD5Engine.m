//
//  GPUBruteForceTestEngine.m
//  pwdcrack
//
//  Created by Jacob Inwald on 04/12/2023.
//

#import <Foundation/Foundation.h>
#import "GPUBruteForceMD5Engine.h"
#include "constants.h"
#include "time.h"
#include <stdlib.h>
#include <curses.h>


// The number of floats in each array, and the size of the arrays in bytes.


@implementation GPUBruteForceMD5Engine
{
    id<MTLDevice> _mDevice;

    // The compute pipeline generated from the compute kernel in the .metal shader file.
    id<MTLComputePipelineState> _mBruteForcePSA;

    // The command queue used to pass commands to the device.
    id<MTLCommandQueue> _mCommandQueue;

    // Buffers to hold data.
    id<MTLBuffer> _mBufferTgtHash;     //  Holds the hash to crack
    id<MTLBuffer> _mBufferResult;   //  Holds the result of the operation
//    id<MTLBuffer> _mBufferWords;    //  The working space for the GPU
    id<MTLBuffer> _mBufferIndices;  //  Tells each kernel which permutation number they are (may change this)
    
    unsigned long long _gridSize;
    unsigned int _pwd_size;
}

- (instancetype) initWithDevice: (id<MTLDevice>) device
{
    self = [super init];
    if (self)
    {
        
        
        _mDevice = device;

        NSError* error = nil;

        // Load the shader files with a .metal file extension in the project

        id<MTLLibrary> defaultLibrary = [_mDevice newDefaultLibrary];
        if (defaultLibrary == nil)
        {
            NSLog(@"Failed to find the default library.");
            return nil;
        }

        id<MTLFunction> addFunction = [defaultLibrary newFunctionWithName:@"brute_force_md5"];
        if (addFunction == nil)
        {
            NSLog(@"Failed to find the brute force function.");
            return nil;
        }

        // Create a compute pipeline state object.
        _mBruteForcePSA = [_mDevice newComputePipelineStateWithFunction: addFunction error:&error];
        if (_mBruteForcePSA == nil)
        {
            //  If the Metal API validation is enabled, you can find out more information about what
            //  went wrong.  (Metal API validation is enabled by default when a debug build is run
            //  from Xcode)
            NSLog(@"Failed to created pipeline state object, error %@.", error);
            return nil;
        }

        _mCommandQueue = [_mDevice newCommandQueue];
        if (_mCommandQueue == nil)
        {
            NSLog(@"Failed to find the command queue.");
            return nil;
        }
        
        
        _gridSize = 512*_mBruteForcePSA.threadExecutionWidth*_mBruteForcePSA.maxTotalThreadsPerThreadgroup;
    }

    return self;
}

- (void) prepareData: (char*) hash, uint n
{
    _pwd_size = n;
    // Allocate Buffers
    _mBufferTgtHash = [_mDevice newBufferWithLength:_md5_length options:MTLResourceStorageModeShared];
    _mBufferResult = [_mDevice newBufferWithLength:_pwd_size options:MTLResourceStorageModeShared];
    // Working space of the GPU (think it might be too big?)
//    _mBufferWords = [_mDevice newBufferWithLength:_md5_length*_gridSize options:MTLResourceStorageModeShared];
    _mBufferIndices = [_mDevice newBufferWithLength:_mBruteForcePSA.threadExecutionWidth*_mBruteForcePSA.maxTotalThreadsPerThreadgroup options:MTLResourceStorageModeShared];
    
    [self setHashBuffer:_mBufferTgtHash, hash];
    [self setBufferToString:_mBufferResult, "failedfailedfailed"];
//    [self generateGPUWords:_mBufferWords];
    [self writeIndex:_mBufferIndices,0];
    
}

- (void) sendComputeCommand
{
    // Create a command buffer to hold commands.
    id<MTLCommandBuffer> commandBuffer;
//    assert(commandBuffer != nil);

    // Start a compute pass.
    id<MTLComputeCommandEncoder> computeEncoder;
    NSUInteger total_size = 0;
    for (int i = 0; i <= _pwd_size; i++) total_size += (NSUInteger)(pow(_char_length, i));
    
    unsigned long* indexes = _mBufferIndices.contents;
    unsigned long divisions = total_size / _gridSize;
    
    printf("-------------------------        PASSWORD CRACKER       -----------------------------\n");
    printf("Info | total words: %lu | split into %lu divisions\n | terminates at password length %u", total_size, divisions, _pwd_size);
    printf("\n");
    
    struct timespec before, after;
    double time_left, diff_av, words_per_sec;
    
    timespec_get(&before, 1);
    
    for(unsigned long i = 1; i <= divisions; i++) {
        
        // End the compute pass._mBufferIndices.contents[0]);
        commandBuffer = [_mCommandQueue commandBuffer];
        assert(commandBuffer != nil);
        computeEncoder  = [commandBuffer computeCommandEncoder];
        assert(computeEncoder != nil);
        [self encodeBruteForceCommand:computeEncoder];
        // Execute the command.
        [computeEncoder endEncoding];
        [commandBuffer commit];
        [commandBuffer waitUntilCompleted];
        
        if([self verifyResults]) break;
        timespec_get(&after, TIME_UTC);
        diff_av = (after.tv_sec - before.tv_sec);
        time_left = (diff_av / i) * (divisions-i);
        words_per_sec = (indexes[0] / diff_av) / 1000000;
        
        //remove line
        fputs("\033[A\033[2K",stdout);
        rewind(stdout);
        
        printf("Pass %lu | Tested %lu words | %.3f done | est. %.2fs remaining | @ %.2f MH/s\n",
               i, indexes[0], (double)i/divisions, time_left, words_per_sec);
        
        
    }

    [self showResults];
}

- (void)encodeBruteForceCommand:(id<MTLComputeCommandEncoder>)computeEncoder {

    // Encode the pipeline state object and its parameters.
    [computeEncoder setComputePipelineState:_mBruteForcePSA];
    [computeEncoder setBuffer:_mBufferTgtHash offset:0 atIndex:0];
    [computeEncoder setBuffer:_mBufferResult offset:0 atIndex:1];
    [computeEncoder setBuffer:_mBufferIndices offset:0 atIndex:2];
    
    
    NSUInteger w = _mBruteForcePSA.threadExecutionWidth;
    NSUInteger h = _mBruteForcePSA.maxTotalThreadsPerThreadgroup / w;
    
    MTLSize threadgroupSize = MTLSizeMake(w, h, 1);
    MTLSize gridSize = MTLSizeMake(_gridSize, 1, 1);
    
    // Encode the compute command.
    [computeEncoder dispatchThreads:gridSize
              threadsPerThreadgroup:threadgroupSize];
}


- (void) writeIndex: (id<MTLBuffer>) buffer, unsigned long index
{
    unsigned long* dataPtr = buffer.contents;
    dataPtr[0] = index;
    dataPtr[1] = 0;
}

- (void) generateGPUWords: (id<MTLBuffer>) buffer
{
    char* dataPtr = buffer.contents;
    
    for (unsigned long buf_index = 0; buf_index < buffer.length; buf_index+=_md5_length)
    {
        for (unsigned long word_index = 0; word_index < _md5_length; word_index++){
            dataPtr[buf_index+word_index] = 0x00;
        }
    }
}

- (void) setBufferToString: (id<MTLBuffer>) buffer, char* hash
{
    char* dataPtr = buffer.contents;
    
    for (int i = 0; i < _pwd_size; i++)
    {
        dataPtr[i] = hash[i];
    }
}

- (void) setHashBuffer: (id<MTLBuffer>) buffer, char* hash
{
    uint32_t* dataPtr = buffer.contents;
    char hashes[4][9];
    
    for(int i = 0; i < 8; i++){
        hashes[0][i] = hash[i];
        hashes[1][i] = hash[i+8];
        hashes[2][i] = hash[i+16];
        hashes[3][i] = hash[i+24];
    }
        
    hashes[0][8] = '\0';
    hashes[1][8] = '\0';
    hashes[2][8] = '\0';
    hashes[3][8] = '\0';
    
    dataPtr[0] = __builtin_bswap32((uint32_t)strtoul(hashes[0], NULL, 16));
    dataPtr[1] = __builtin_bswap32((uint32_t)strtoul(hashes[1], NULL, 16));
    dataPtr[2] = __builtin_bswap32((uint32_t)strtoul(hashes[2], NULL, 16));
    dataPtr[3] = __builtin_bswap32((uint32_t)strtoul(hashes[3], NULL, 16));
    
}

- (void) printGPUMem: (id<MTLBuffer>) buffer
{
    char* words = buffer.contents;
    char word[_md5_length+1] = "";
    char* w = &word[0];
    int n_divs = 8;
    printf("\n\tStart of word buffer:\n");
    unsigned long lineBreak = 1;
    for (int i = 0; i < (64*_md5_length); i+=_md5_length) {
        w = strncpy(w, words+i, _md5_length);
        w[_md5_length] = '\0';
        printf("%s ", w);
        if (lineBreak % n_divs == 0) printf("\n");
        lineBreak++;
    }
    if ((lineBreak-1) % n_divs != 0)    printf("\n");
    printf("%*s...", (_pwd_size/2)-3, "");
    for(int i = 1; i<n_divs;i++)
        printf("%*s...", (_pwd_size-2), "");
    
    printf("\n");
    lineBreak = 1;
    for (unsigned long i = buffer.length-(64*_md5_length); i < buffer.length; i+=_md5_length) {
        w = strncpy(w, words+i, _md5_length);
        w[_md5_length] = '\0';
        printf("%s ", w);
        if (lineBreak % n_divs == 0) printf("\n");
        lineBreak++;
    }
    
}

- (bool) verifyResults
{
    char* result = _mBufferResult.contents;
    return (strncmp(result, "failedfailedfailed", _pwd_size) != 0);
}

- (void) showResults
{
    
    char* result = _mBufferResult.contents;
    uint32_t* hash = _mBufferTgtHash.contents;
    unsigned long* index = _mBufferIndices.contents;
//    [self printGPUMem:_mBufferWords];
    printf("\n");
    printf("%s ", result);
    
    // Print Hash
    uint8_t *p;
    p=(uint8_t *)&hash[0];
    printf("%2.2x%2.2x%2.2x%2.2x", p[0], p[1], p[2], p[3], hash[0]);
    p=(uint8_t *)&hash[1];
    printf("%2.2x%2.2x%2.2x%2.2x", p[0], p[1], p[2], p[3], hash[1]);
    p=(uint8_t *)&hash[2];
    printf("%2.2x%2.2x%2.2x%2.2x", p[0], p[1], p[2], p[3], hash[2]);
    p=(uint8_t *)&hash[3];
    printf("%2.2x%2.2x%2.2x%2.2x\n", p[0], p[1], p[2], p[3], hash[3]);
    
    printf("%lu %lu %lu\n", index[0], index[1], index[2]);
    
    printf("Compute results as expected\n");

}
@end

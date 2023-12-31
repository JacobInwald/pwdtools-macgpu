/*
See LICENSE folder for this sample’s licensing information.

Abstract:
An app that performs a simple calculation on a GPU.
*/

#import <Foundation/Foundation.h>
#import <Metal/Metal.h>
#import "GPUBruteForceMD5Engine.h"
#include "constants.h"


int main(int argc, const char * argv[]) {
    
    if (argc != 3) {
        printf("usage: %s <hash> <search depth>\n", argv[0]);
        return 0;
    }
    
    char hash[32];
    for (int i = 0; i < 32; i ++) hash[i] = argv[1][i];
    
    uint n = (uint) strtoul(argv[2], NULL, 10);
    
    
    @autoreleasepool {
        
        id<MTLDevice> device = MTLCreateSystemDefaultDevice();

        // Create the custom object used to encapsulate the Metal code.
        // Initializes objects to communicate with the GPU.
        GPUBruteForceMD5Engine* cracker = [[GPUBruteForceMD5Engine alloc] initWithDevice:device];
        
        // Create buffers to hold data
        [cracker prepareData:hash, n];
        
        // Send a command to the GPU to perform the calculation.
        [cracker sendComputeCommand];
        NSLog(@"Execution finished");
    }
    return 0;
}



// const char _characters[88] = {'a', 'b', 'c', 'd', 'e', 'f', 'g', 'h', 'i', 'j', 'k', 'l', 'm', 'n', 'o', 'p', 'q', 'r', 's', 't', 'u', 'v', 'w', 'x', 'y', 'z', 'A', 'B', 'C', 'D', 'E', 'F', 'G', 'H', 'I', 'J', 'K', 'L', 'M', 'N', 'O', 'P', 'Q', 'R', 'S', 'T', 'U', 'V', 'W', 'X', 'Y', 'Z', '1', '2', '3', '4', '5', '6', '7', '8', '9', '0', '!', '@', '#', '$', '%', '^', '&', '*', '(', ')', '_', '+', '-', '=', '[', ']', ':', ',', '.', '/', '\\', '<', '>', '?', '#', '>'};
//
//
//void md5_gen_and_check(uint64_t n) {
//
//    uint32_t a=0,b=0,c=0,d=0;
//    uint32_t e=0,p=0,q=0;
//
//    uint64_t old_char_i =  n / 88;
//    uint64_t new_char_i = n - _char_length*(old_char_i);
//    old_char_i--;
//    uint64_t temp = 0;
//
//    uint16_t shift=0;
//    uint8_t len=1;
//    // Generate old suffix little-endian format
//    for (int i = 0; i < 16; i++) {
//        if (old_char_i+2 <= 1) break;
//        temp = old_char_i / 88;
//        if(len <= 4)
//            a += (_characters[old_char_i - _char_length*temp] << (shift));
//        else if (len <= 8)
//            b += (_characters[old_char_i - _char_length*temp] << (shift));
//        else if (len <= 12)
//            c += (_characters[old_char_i - _char_length*temp] << (shift));
//        else if (len <= 16)
//            d += (_characters[old_char_i - _char_length*temp] << (shift));
//        old_char_i = temp - 1;
//        shift = (shift+8) & 31;
//        len++;
//    }
//    // Append new character
//    if(len <= 4)
//        a += _characters[new_char_i] << (shift);
//    else if (len <= 8)
//        b += _characters[new_char_i] << (shift);
//    else if (len <= 12)
//        c += _characters[new_char_i] << (shift);
//    else if (len <= 16)
//        d += _characters[new_char_i] << (shift);
//
//    len++;
//    shift = (shift+8) & 31;
//
//    if(len <= 4)
//        a = a ^ (1 << ((shift)+7));
//    else if (len <= 8)
//        b = b ^ (1 << ((shift)+7));
//    else if (len <= 12)
//        c = c ^ (1 << ((shift)+7));
//    else if (len <= 16)
//        d = d ^ (1 << ((shift)+7));
//    else
//        e = e ^ (1 << ((shift)+7));
//
//    p = (len-1)<<3;
//
//    printf("0x%x 0x%x 0x%x 0x%x 0x%x 0x%x \n", a,b,c,d,p,q);
//
//}
//
//void get_permutation(uint64_t n) {
//    char* w = calloc(64, sizeof(char));
//    uint64_t old_char_i = n / 88;
//    uint64_t new_char_i = n - _char_length*(old_char_i);
//    old_char_i--;
//    uint i = 0;
//
//    while (old_char_i+2 > 1) {
//        n = old_char_i/88;
//        w[i] = _characters[old_char_i - _char_length*n];
//        old_char_i = n - 1;
//        i++;
//    }
//
//    w[i] = _characters[new_char_i];
//    //
//    w[i+1] = 128;
//    w[56] = (i+1)<<3;
//    uint32_t* w_1 = w;
//    printf("0x%x 0x%x 0x%x 0x%x 0x%x 0x%x \n", w_1[0],w_1[1],w_1[2],w_1[3],w_1[14],w_1[15]);
//}

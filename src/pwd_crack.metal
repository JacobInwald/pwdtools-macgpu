//
//  pwd_crackl.metal
//  pwd-crackl
//
//  Created by Jacob Inwald on 03/12/2023.
//


#include "md5GPU.h"


// Gets the permutation given by n
void get_permutation(uint64_t n, device char* w) {
    uint64_t old_char_i =  n / _char_length;
    uint64_t new_char_i = n - _char_length*(old_char_i);
    old_char_i--;
    uint i = 0;

    while (old_char_i+2 > 1) {
        n = old_char_i / _char_length;
        w[i] = _characters[old_char_i - _char_length*n];
        old_char_i = n - 1;
        i++;
    }
    
    w[i] = _characters[new_char_i];
    
    w[i+1] = 0;
}


kernel void brute_force_md5(device uint32_t* hash             [[buffer(0)]],
                                device char* result          [[buffer(1)]],
                                device ulong* indexes        [[buffer(2)]],
                                uint2 position               [[thread_position_in_grid]],
                                uint2 gridSize               [[ threads_per_grid ]]) {
    // Function has lg(n) runtime, where n is indexes[0]
    ulong index_in_whole = position.y*gridSize.x+position.x;

    if (md5_gen_and_check(hash, (index_in_whole) + indexes[0]))
        get_permutation((index_in_whole) + indexes[0], result);
    
    if(index_in_whole == gridSize.x*gridSize.y-1) indexes[0] += gridSize.x*gridSize.y;
    
    
}


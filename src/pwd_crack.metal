//
//  pwd_crackl.metal
//  pwd-crackl
//
//  Created by Jacob Inwald on 03/12/2023.
//

#include <metal_stdlib>
using namespace metal;
#include "md5GPU.h"

constant int _word_length = 7;
constant int _md5_length = 128;
constant const int _char_length = 88;
constant const char _characters[88] = {'a', 'b', 'c', 'd', 'e', 'f', 'g', 'h', 'i', 'j', 'k', 'l', 'm', 'n', 'o', 'p', 'q', 'r', 's', 't', 'u', 'v', 'w', 'x', 'y', 'z', 'A', 'B', 'C', 'D', 'E', 'F', 'G', 'H', 'I', 'J', 'K', 'L', 'M', 'N', 'O', 'P', 'Q', 'R', 'S', 'T', 'U', 'V', 'W', 'X', 'Y', 'Z', '1', '2', '3', '4', '5', '6', '7', '8', '9', '0', '!', '@', '#', '$', '%', '^', '&', '*', '(', ')', '_', '+', '-', '=', '[', ']', ':', ',', '.', '/', '\\', '<', '>', '?', '#', '>'};

// Can Handle up to 2^46, the search space of length = 7 equates to 2^45 so this will run on that with out error
// However, after word_length 7 its not guaranteed that this will work. But it is 8 * faster soooooo
uint64_t divu88(uint64_t n) {
        uint64_t q, r;
        q = (n >> 1) + (n >> 2) - (n >> 5) + (n >> 7);
        q = q + (q >> 10);
        q = q + (q >> 20);
        q = q >> 3;
        r = n - q*11;
        return ((q + ((r + 5) >> 4)) >> 3);
}

// Validates password
bool check_password(device char* hash, device char* pwd, int length) {
    for (int i = 0; i < length; i++){
        if(hash[i] != pwd[i]) return false;
    }
    return _word_length == length;
}

// Validates hashes are the same
bool check_hash(device uint32_t* hash, device uint32_t* pwd) {
    for (int i = 0; i < 4; i++){
        if(hash[i] != pwd[i]) return false;
    }
    return true;
}



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


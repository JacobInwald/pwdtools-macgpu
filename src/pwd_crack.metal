//
//  pwd_crackl.metal
//  pwd-crackl
//
//  Created by Jacob Inwald on 03/12/2023.
//

#include <metal_stdlib>
using namespace metal;

constant int _word_length = 7;
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


// Gets the permutation given by n
int get_permutation(uint64_t n, device char* w) {
// 1.     OG method - 550MH/s // changing back soon but again slow but precise. 
//    uint new_char_i = n % _char_length;
//    ulong old_char_i = (ulong(n * x)>>16)- 1;
//    uint i = 0;
//    
//    while (old_char_i+2 > 1) {
//        w[i] = _characters[old_char_i % _char_length];
//        old_char_i = (ulong(old_char_i * x)>>16) - 1;
//        i++;
//    }
//    
//    w[i] = _characters[new_char_i];
//
//  -----------------------------------------------------------------------------
// 2.   Method for n=64, which is mega fast (4GH/s), only works on powers of two though but
    //  no loss of accuracy
//    uint new_char_i = n & (64 - 1);
//    ulong old_char_i = (n >> 6) - 1;
//    uint i = 0;
//    
//    while (old_char_i+2 > 1) {
//        w[i] = _characters[old_char_i & (64 - 1)];
//        old_char_i = (old_char_i >> 6) - 1;
//        i++;
//    }
//    
//    w[i] = _characters[new_char_i];
// -----------------------------------------------------------------------------
// 3.  Replaces the modulo with integer division using the equality shown below. Faster than the base by
//    //  100MH/s on average. 620MH/s
//    // C = A % B
//    // C = A – B * (A / B)
// -----------------------------------------------------------------------------
// 4. Precomputes the magic number and Applies method 3, runs at 4GH/s
    // TODO: Fix case where n^46 as divu88 loses accuracy here
    uint32_t old_char_i =  divu88(n);
    uint32_t new_char_i = n - _char_length*(old_char_i);
    old_char_i--;
    uint i = 0;
    uint32_t temp = 0;
    
    while (old_char_i+2 > 1) {
        temp = divu88(old_char_i);
        w[i] = _characters[old_char_i - _char_length*temp];
        old_char_i = temp - 1;
        i++;
    }
    
    w[i] = _characters[new_char_i];
    
    return i+1;
}


kernel void brute_force(device char* hash             [[buffer(0)]],
                               device char* words           [[buffer(1)]],
                               device char* result          [[buffer(2)]],
                               device ulong* indexes        [[buffer(3)]],
                               uint2 position               [[thread_position_in_grid]],
                               uint2 gridSize               [[ threads_per_grid ]]) {
    
    ulong index_in_whole = position.y*gridSize.x+position.x;
    device char* w = &words[index_in_whole*_word_length];
    ulong n = (index_in_whole) + indexes[0];
    
    int len = get_permutation(n, w);
    if (check_password(hash, w, len)) {
        get_permutation(n, result);
    }
    if(index_in_whole == gridSize.x*gridSize.y-1) {
        indexes[0] += gridSize.x*gridSize.y;
        indexes[1] = n;
    }
    
}

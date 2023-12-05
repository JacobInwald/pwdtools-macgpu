//
//  pwd_crackl.metal
//  pwd-crackl
//
//  Created by Jacob Inwald on 03/12/2023.
//

#include <metal_stdlib>
using namespace metal;

constant int _word_length = 6;
constant const int _char_length = 86;
constant const char _characters[86] = {'a', 'b', 'c', 'd', 'e', 'f', 'g', 'h', 'i', 'j', 'k', 'l', 'm', 'n', 'o', 'p', 'q', 'r', 's', 't', 'u', 'v', 'w', 'x', 'y', 'z', 'A', 'B', 'C', 'D', 'E', 'F', 'G', 'H', 'I', 'J', 'K', 'L', 'M', 'N', 'O', 'P', 'Q', 'R', 'S', 'T', 'U', 'V', 'W', 'X', 'Y', 'Z', '1', '2', '3', '4', '5', '6', '7', '8', '9', '0', '!', '@', '#', '$', '%', '^', '&', '*', '(', ')', '_', '+', '-', '=', '[', ']', ':', ',', '.', '/', '\\', '<', '>', '?'};


// Validates password
bool check_password(device char* hash, device char* pwd, int length) {
    for (int i = 0; i < length; i++){
        if(hash[i] != pwd[i]) return false;
    }
    return _word_length == length;
}


// Gets the permutation given by n
int get_permutation(ulong n, device char* w) {

    uint new_char_i = n % _char_length;
    ulong old_char_i = (n / _char_length) - 1;
    
    uint i = 0;
    while (old_char_i+2 > 1) {
        w[i] = _characters[old_char_i % _char_length];
        old_char_i = (old_char_i / _char_length) - 1;
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
        indexes[1] = index_in_whole+1;
        indexes[2] = n;
    }
    
}




//kernel void brute_force(device char* hash                   [[buffer(0)]],
//                               device char* words           [[buffer(1)]],
//                               device char* result          [[buffer(2)]],
//                               device char* quitFound       [[buffer(3)]],
//                               device ulong* totalSize      [[buffer(4)]],
//                               uint2 position               [[ thread_position_in_grid ]],
//                               uint2 gridSize               [[ threads_per_grid ]]) {
//
//
//    int index_in_whole = position.y*gridSize.x+position.x;
//    device char* w = &words[(index_in_whole)*_word_length];
//    int w_length;
//    threadgroup bool groupFound = false;
//
//    for (ulong i = index_in_whole; i <= totalSize[0]; i += gridSize.x*gridSize.y) {
//        w_length = get_permutation(i, w);
//
//        if (groupFound || quitFound[0] == 'b') {
//
//        }
//        if (check_password(hash, w, w_length)) {
//            get_permutation(i, result);
//            quitFound[0] = 'b';
//            groupFound = true;
//
//        }
//    }
//
//}

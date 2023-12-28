//
//  md5-arm.metal
//  pwdcrack
//
//  Created by Jacob Inwald on 27/12/2023.
//
#include "md5-arm-asm.h"
#include <metal_stdlib>
using namespace metal;


template<typename HT>
void md5_init(MD5_STATE<HT>* state) {
    state->A = 0x67452301;
    state->B = 0xefcdab89;
    state->C = 0x98badcfe;
    state->D = 0x10325476;
}
#ifdef __AVX512VL__
#include <immintrin.h>
template<>
void md5_init<__m128i>(MD5_STATE<__m128i>* state) {
    state->A = _mm_cvtsi32_si128(0x67452301);
    state->B = _mm_cvtsi32_si128(0xefcdab89);
    state->C = _mm_cvtsi32_si128(0x98badcfe);
    state->D = _mm_cvtsi32_si128(0x10325476);
}
#endif

template<typename HT, void(&fn)(MD5_STATE<HT>*, const void*)>
void md5(MD5_STATE<HT>* state, const void* __restrict__ src, size_t len) {
    md5_init<HT>(state);
    char* __restrict__ _src = (char* __restrict__)src;
    uint64_t totalLen = len << 3; // length in bits
    
    for(; len >= 64; len -= 64) {
        fn(state, _src);
        _src += 64;
    }
    len &= 63;
    
    
    // finalize
    char block[64];
    memcpy(block, _src, len);
    block[len++] = 0x80;
    
    // write this in a loop to avoid duplicating the force-inlined process_block function twice
    for(int iter = (len <= 64-8); iter < 2; iter++) {
        if(iter == 0) {
            memset(block + len, 0, 64-len);
            len = 0;
        } else {
            memset(block + len, 0, 64-8 - len);
            memcpy(block + 64-8, &totalLen, 8);
        }
        
        fn(state, block);
    }
}

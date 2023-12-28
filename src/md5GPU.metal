#include <metal_stdlib>
using namespace metal;
#include "md5GPU.h"


constant const int _char_length = 88;
constant const char _characters[88] = {'a', 'b', 'c', 'd', 'e', 'f', 'g', 'h', 'i', 'j', 'k', 'l', 'm', 'n', 'o', 'p', 'q', 'r', 's', 't', 'u', 'v', 'w', 'x', 'y', 'z', 'A', 'B', 'C', 'D', 'E', 'F', 'G', 'H', 'I', 'J', 'K', 'L', 'M', 'N', 'O', 'P', 'Q', 'R', 'S', 'T', 'U', 'V', 'W', 'X', 'Y', 'Z', '1', '2', '3', '4', '5', '6', '7', '8', '9', '0', '!', '@', '#', '$', '%', '^', '&', '*', '(', ')', '_', '+', '-', '=', '[', ']', ':', ',', '.', '/', '\\', '<', '>', '?', '#', '>'};



// leftrotate function definition
uint32_t LEFTROTATE(uint32_t x, uint32_t c)     { return (((x) << (c)) | ((x) >> (32 - (c)))); };

uint32_t F(uint32_t b, uint32_t c, uint32_t d)  { return (b & c) | ((~b) & d); };
uint32_t G(uint32_t b, uint32_t c, uint32_t d)  { return ((d & b) | (~d & c)); };
uint32_t H(uint32_t b, uint32_t c, uint32_t d)  { return b ^ c ^ d; };
uint32_t I(uint32_t b, uint32_t c, uint32_t d)  { return c ^ (b | (~d)); };

uint64_t divu88_2(uint64_t n) {
    uint64_t q;
    n >>= 3;
    q = (n >> 1) + (n >> 2) - (n >> 5) + (n >> 7);
    q += (q >> 10);
    q += (q >> 20);
    q >>= 3;
    return (q + ((n - 11*q + 5) >> 4));
}

// Use binary integer part of the sines of integers (in radians) as constants// Initialize variables:
constant uint32_t k_1[] = {
    0xd76aa478, 0xe8c7b756, 0x242070db, 0xc1bdceee,
    0xf57c0faf, 0x4787c62a, 0xa8304613, 0xfd469501,
    0x698098d8, 0x8b44f7af, 0xffff5bb1, 0x895cd7be,
    0x6b901122, 0xfd987193, 0xa679438e, 0x49b40821};
constant uint32_t k_2[] = {
    0xf61e2562, 0xc040b340, 0x265e5a51, 0xe9b6c7aa,
    0xd62f105d, 0x02441453, 0xd8a1e681, 0xe7d3fbc8,
    0x21e1cde6, 0xc33707d6, 0xf4d50d87, 0x455a14ed,
    0xa9e3e905, 0xfcefa3f8, 0x676f02d9, 0x8d2a4c8a};
constant uint32_t k_3[] = {
    0xfffa3942, 0x8771f681, 0x6d9d6122, 0xfde5380c,
    0xa4beea44, 0x4bdecfa9, 0xf6bb4b60, 0xbebfbc70,
    0x289b7ec6, 0xeaa127fa, 0xd4ef3085, 0x04881d05,
    0xd9d4d039, 0xe6db99e5, 0x1fa27cf8, 0xc4ac5665};
constant uint32_t k_4[] = {
    0xf4292244, 0x432aff97, 0xab9423a7, 0xfc93a039,
    0x655b59c3, 0x8f0ccc92, 0xffeff47d, 0x85845dd1,
    0x6fa87e4f, 0xfe2ce6e0, 0xa3014314, 0x4e0811a1,
    0xf7537e82, 0xbd3af235, 0x2ad7d2bb, 0xeb86d391};


bool md5_gen_and_check(device uint32_t * abcd, uint64_t n) {
    
    uint32_t a=0,b=0,c=0,d=0,e=0,p=0,q=0;
    
    uint64_t old_char_i =  divu88_2(n);
    uint64_t new_char_i = n - _char_length*(old_char_i);
    old_char_i--;

    // Generate old suffix little-endian format
    uint64_t temp = 0;
    uint16_t shift=0;
    uint8_t len=1;
    for (int i = 0; i < 16; i++) {
        if (old_char_i+2 <= 1) break;
        
        temp = divu88_2(old_char_i);
        
        if(len <= 4)
            a += (_characters[old_char_i - _char_length*temp] << (shift));
        else if (len <= 8)
            b += (_characters[old_char_i - _char_length*temp] << (shift));
        else if (len <= 12)
            c += (_characters[old_char_i - _char_length*temp] << (shift));
        else if (len <= 16)
            d += (_characters[old_char_i - _char_length*temp] << (shift));
        
        old_char_i = temp - 1;
        shift = (shift+8) & 31;
        len++;
    }
    
    // Append new character
    if(len <= 4)
        a += _characters[new_char_i] << (shift);
    else if (len <= 8)
        b += _characters[new_char_i] << (shift);
    else if (len <= 12)
        c += _characters[new_char_i] << (shift);
    else if (len <= 16)
        d += _characters[new_char_i] << (shift);
    
    len++;
    shift = (shift+8) & 31;
    
    if(len <= 4)
        a = a ^ (1 << ((shift)+7));
    else if (len <= 8)
        b = b ^ (1 << ((shift)+7));
    else if (len <= 12)
        c = c ^ (1 << ((shift)+7));
    else if (len <= 16)
        d = d ^ (1 << ((shift)+7));
    else
        e = e ^ (1 << ((shift)+7));
    
    p = (len-1)<<3;
    
    uint32_t w[16] = {a, b, c, d, e, 0, 0, 0, 0, 0, 0, 0, 0, 0, p, q};

    // F rounds
    // rounds 1-4
    a = 0xefcdab89 + LEFTROTATE((0x1d76aa477 + w[0]), 7);
    d = a + LEFTROTATE(F(a,0xefcdab89,0x98badcfe) + 0xf8fa0bcc + w[1], 12);
    c = d + LEFTROTATE(F(d,a,0xefcdab89) + 0xbcdb4dd9 + w[2], 17);
    b = c + LEFTROTATE(F(c,d,a) + 0x1b18b7a77 + w[3], 22);
    // rounds 5-8
    a = b + LEFTROTATE(F(b,c,d) + a + k_1[4] + w[4], 7);
    d = a + LEFTROTATE(F(a,b,c) + d + k_1[5] + w[5], 12);
    c = d + LEFTROTATE(F(d,a,b) + c + k_1[6] + w[6], 17);
    b = c + LEFTROTATE(F(c,d,a) + b + k_1[7] + w[7], 22);
    // rounds 9-12
    a = b + LEFTROTATE(F(b,c,d) + a + k_1[8] + w[8], 7);
    d = a + LEFTROTATE(F(a,b,c) + d + k_1[9] + w[9], 12);
    c = d + LEFTROTATE(F(d,a,b) + c + k_1[10] + w[10], 17);
    b = c + LEFTROTATE(F(c,d,a) + b + k_1[11] + w[11], 22);
    // rounds 13-16
    a = b + LEFTROTATE(F(b,c,d) + a + k_1[12] + w[12], 7);
    d = a + LEFTROTATE(F(a,b,c) + d + k_1[13] + w[13], 12);
    c = d + LEFTROTATE(F(d,a,b) + c + k_1[14] + w[14], 17);
    b = c + LEFTROTATE(F(c,d,a) + b + k_1[15] + w[15], 22);
    
    // G rounds
    // rounds 17-20
    a = b + LEFTROTATE(G(b,c,d) + a + k_2[0] + w[1], 5);
    d = a + LEFTROTATE(G(a,b,c) + d + k_2[1] + w[6], 9);
    c = d + LEFTROTATE(G(d,a,b) + c + k_2[2] + w[11], 14);
    b = c + LEFTROTATE(G(c,d,a) + b + k_2[3] + w[0], 20);
    // rounds 21-24
    a = b + LEFTROTATE(G(b,c,d) + a + k_2[4] + w[5], 5);
    d = a + LEFTROTATE(G(a,b,c) + d + k_2[5] + w[10], 9);
    c = d + LEFTROTATE(G(d,a,b) + c + k_2[6] + w[15], 14);
    b = c + LEFTROTATE(G(c,d,a) + b + k_2[7] + w[4], 20);
    // rounds 25-28
    a = b + LEFTROTATE(G(b,c,d) + a + k_2[8] + w[9], 5);
    d = a + LEFTROTATE(G(a,b,c) + d + k_2[9] + w[14], 9);
    c = d + LEFTROTATE(G(d,a,b) + c + k_2[10] + w[3], 14);
    b = c + LEFTROTATE(G(c,d,a) + b + k_2[11] + w[8], 20);
    // rounds 29-32
    a = b + LEFTROTATE(G(b,c,d) + a + k_2[12] + w[13], 5);
    d = a + LEFTROTATE(G(a,b,c) + d + k_2[13] + w[2], 9);
    c = d + LEFTROTATE(G(d,a,b) + c + k_2[14] + w[7], 14);
    b = c + LEFTROTATE(G(c,d,a) + b + k_2[15] + w[12], 20);
    
    // H rounds
    // rounds 33-36
    a = b + LEFTROTATE(H(b,c,d) + a + k_3[0] + w[5], 4);
    d = a + LEFTROTATE(H(a,b,c) + d + k_3[1] + w[8], 11);
    c = d + LEFTROTATE(H(d,a,b) + c + k_3[2] + w[11], 16);
    b = c + LEFTROTATE(H(c,d,a) + b + k_3[3] + w[14], 23);
    // rounds 37-40
    a = b + LEFTROTATE(H(b,c,d) + a + k_3[4] + w[1], 4);
    d = a + LEFTROTATE(H(a,b,c) + d + k_3[5] + w[4], 11);
    c = d + LEFTROTATE(H(d,a,b) + c + k_3[6] + w[7], 16);
    b = c + LEFTROTATE(H(c,d,a) + b + k_3[7] + w[10], 23);
    // rounds 41-44
    a = b + LEFTROTATE(H(b,c,d) + a + k_3[8] + w[13], 4);
    d = a + LEFTROTATE(H(a,b,c) + d + k_3[9] + w[0], 11);
    c = d + LEFTROTATE(H(d,a,b) + c + k_3[10] + w[3], 16);
    b = c + LEFTROTATE(H(c,d,a) + b + k_3[11] + w[6], 23);
    // rounds 45-48
    a = b + LEFTROTATE(H(b,c,d) + a + k_3[12] + w[9], 4);
    d = a + LEFTROTATE(H(a,b,c) + d + k_3[13] + w[12], 11);
    c = d + LEFTROTATE(H(d,a,b) + c + k_3[14] + w[15], 16);
    b = c + LEFTROTATE(H(c,d,a) + b + k_3[15] + w[2], 23);

    // I rounds
    // rounds 49-52
    a = b + LEFTROTATE(I(b,c,d) + a + k_4[0] + w[0], 6);
    d = a + LEFTROTATE(I(a,b,c) + d + k_4[1] + w[7], 10);
    c = d + LEFTROTATE(I(d,a,b) + c + k_4[2] + w[14], 15);
    b = c + LEFTROTATE(I(c,d,a) + b + k_4[3] + w[5], 21);
    // rounds 53-56
    a = b + LEFTROTATE(I(b,c,d) + a + k_4[4] + w[12], 6);
    d = a + LEFTROTATE(I(a,b,c) + d + k_4[5] + w[3], 10);
    c = d + LEFTROTATE(I(d,a,b) + c + k_4[6] + w[10], 15);
    b = c + LEFTROTATE(I(c,d,a) + b + k_4[7] + w[1], 21);
    // rounds 57-60
    a = b + LEFTROTATE(I(b,c,d) + a + k_4[8] + w[8], 6);
    d = a + LEFTROTATE(I(a,b,c) + d + k_4[9] + w[15], 10);
    c = d + LEFTROTATE(I(d,a,b) + c + k_4[10] + w[6], 15);
    b = c + LEFTROTATE(I(c,d,a) + b + k_4[11] + w[13], 21);
    // rounds 61-64
    a = b + LEFTROTATE(I(b,c,d) + a + k_4[12] + w[4], 6);
    d = a + LEFTROTATE(I(a,b,c) + d + k_4[13] + w[11], 10);
    c = d + LEFTROTATE(I(d,a,b) + c + k_4[14] + w[2], 15);
    b = c + LEFTROTATE(I(c,d,a) + b + k_4[15] + w[9], 21);
    
    return abcd[0] == 0x67452301 + a &&
            abcd[1] == 0xefcdab89 + b &&
            abcd[2] == 0x98badcfe + c &&
            abcd[3] == 0x10325476 + d;
}



//----------------------------------------------------------------------------------
bool md5_check(device uint32_t * abcd, device uint32_t * w) {
    
    uint32_t a,b,c,d;
    
    // F rounds
    // rounds 1-4
    a = 0xefcdab89 + LEFTROTATE((0x1d76aa477 + w[0]), 7);
    d = a + LEFTROTATE(F(a,0xefcdab89,0x98badcfe) + 0xf8fa0bcc + w[1], 12);
    c = d + LEFTROTATE(F(d,a,0xefcdab89) + 0xbcdb4dd9 + w[2], 17);
    b = c + LEFTROTATE(F(c,d,a) + 0x1b18b7a77 + w[3], 22);
    // rounds 5-8
    a = b + LEFTROTATE(F(b,c,d) + a + k_1[4] + w[4], 7);
    d = a + LEFTROTATE(F(a,b,c) + d + k_1[5] + w[5], 12);
    c = d + LEFTROTATE(F(d,a,b) + c + k_1[6] + w[6], 17);
    b = c + LEFTROTATE(F(c,d,a) + b + k_1[7] + w[7], 22);
    // rounds 9-12
    a = b + LEFTROTATE(F(b,c,d) + a + k_1[8] + w[8], 7);
    d = a + LEFTROTATE(F(a,b,c) + d + k_1[9] + w[9], 12);
    c = d + LEFTROTATE(F(d,a,b) + c + k_1[10] + w[10], 17);
    b = c + LEFTROTATE(F(c,d,a) + b + k_1[11] + w[11], 22);
    // rounds 13-16
    a = b + LEFTROTATE(F(b,c,d) + a + k_1[12] + w[12], 7);
    d = a + LEFTROTATE(F(a,b,c) + d + k_1[13] + w[13], 12);
    c = d + LEFTROTATE(F(d,a,b) + c + k_1[14] + w[14], 17);
    b = c + LEFTROTATE(F(c,d,a) + b + k_1[15] + w[15], 22);
    
    // G rounds
    // rounds 17-20
    a = b + LEFTROTATE(G(b,c,d) + a + k_2[0] + w[1], 5);
    d = a + LEFTROTATE(G(a,b,c) + d + k_2[1] + w[6], 9);
    c = d + LEFTROTATE(G(d,a,b) + c + k_2[2] + w[11], 14);
    b = c + LEFTROTATE(G(c,d,a) + b + k_2[3] + w[0], 20);
    // rounds 21-24
    a = b + LEFTROTATE(G(b,c,d) + a + k_2[4] + w[5], 5);
    d = a + LEFTROTATE(G(a,b,c) + d + k_2[5] + w[10], 9);
    c = d + LEFTROTATE(G(d,a,b) + c + k_2[6] + w[15], 14);
    b = c + LEFTROTATE(G(c,d,a) + b + k_2[7] + w[4], 20);
    // rounds 25-28
    a = b + LEFTROTATE(G(b,c,d) + a + k_2[8] + w[9], 5);
    d = a + LEFTROTATE(G(a,b,c) + d + k_2[9] + w[14], 9);
    c = d + LEFTROTATE(G(d,a,b) + c + k_2[10] + w[3], 14);
    b = c + LEFTROTATE(G(c,d,a) + b + k_2[11] + w[8], 20);
    // rounds 29-32
    a = b + LEFTROTATE(G(b,c,d) + a + k_2[12] + w[13], 5);
    d = a + LEFTROTATE(G(a,b,c) + d + k_2[13] + w[2], 9);
    c = d + LEFTROTATE(G(d,a,b) + c + k_2[14] + w[7], 14);
    b = c + LEFTROTATE(G(c,d,a) + b + k_2[15] + w[12], 20);
    
    // H rounds
    // rounds 33-36
    a = b + LEFTROTATE(H(b,c,d) + a + k_3[0] + w[5], 4);
    d = a + LEFTROTATE(H(a,b,c) + d + k_3[1] + w[8], 11);
    c = d + LEFTROTATE(H(d,a,b) + c + k_3[2] + w[11], 16);
    b = c + LEFTROTATE(H(c,d,a) + b + k_3[3] + w[14], 23);
    // rounds 37-40
    a = b + LEFTROTATE(H(b,c,d) + a + k_3[4] + w[1], 4);
    d = a + LEFTROTATE(H(a,b,c) + d + k_3[5] + w[4], 11);
    c = d + LEFTROTATE(H(d,a,b) + c + k_3[6] + w[7], 16);
    b = c + LEFTROTATE(H(c,d,a) + b + k_3[7] + w[10], 23);
    // rounds 41-44
    a = b + LEFTROTATE(H(b,c,d) + a + k_3[8] + w[13], 4);
    d = a + LEFTROTATE(H(a,b,c) + d + k_3[9] + w[0], 11);
    c = d + LEFTROTATE(H(d,a,b) + c + k_3[10] + w[3], 16);
    b = c + LEFTROTATE(H(c,d,a) + b + k_3[11] + w[6], 23);
    // rounds 45-48
    a = b + LEFTROTATE(H(b,c,d) + a + k_3[12] + w[9], 4);
    d = a + LEFTROTATE(H(a,b,c) + d + k_3[13] + w[12], 11);
    c = d + LEFTROTATE(H(d,a,b) + c + k_3[14] + w[15], 16);
    b = c + LEFTROTATE(H(c,d,a) + b + k_3[15] + w[2], 23);

    // I rounds
    // rounds 49-52
    a = b + LEFTROTATE(I(b,c,d) + a + k_4[0] + w[0], 6);
    d = a + LEFTROTATE(I(a,b,c) + d + k_4[1] + w[7], 10);
    c = d + LEFTROTATE(I(d,a,b) + c + k_4[2] + w[14], 15);
    b = c + LEFTROTATE(I(c,d,a) + b + k_4[3] + w[5], 21);
    // rounds 53-56
    a = b + LEFTROTATE(I(b,c,d) + a + k_4[4] + w[12], 6);
    d = a + LEFTROTATE(I(a,b,c) + d + k_4[5] + w[3], 10);
    c = d + LEFTROTATE(I(d,a,b) + c + k_4[6] + w[10], 15);
    b = c + LEFTROTATE(I(c,d,a) + b + k_4[7] + w[1], 21);
    // rounds 57-60
    a = b + LEFTROTATE(I(b,c,d) + a + k_4[8] + w[8], 6);
    d = a + LEFTROTATE(I(a,b,c) + d + k_4[9] + w[15], 10);
    c = d + LEFTROTATE(I(d,a,b) + c + k_4[10] + w[6], 15);
    b = c + LEFTROTATE(I(c,d,a) + b + k_4[11] + w[13], 21);
    // rounds 61-64
    a = b + LEFTROTATE(I(b,c,d) + a + k_4[12] + w[4], 6);
    d = a + LEFTROTATE(I(a,b,c) + d + k_4[13] + w[11], 10);
    c = d + LEFTROTATE(I(d,a,b) + c + k_4[14] + w[2], 15);
    b = c + LEFTROTATE(I(c,d,a) + b + k_4[15] + w[9], 21);
    
    return abcd[0] == 0x67452301 + a &&
            abcd[1] == 0xefcdab89 + b &&
            abcd[2] == 0x98badcfe + c &&
            abcd[3] == 0x10325476 + d;
}



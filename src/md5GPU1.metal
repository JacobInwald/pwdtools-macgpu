//
//  md5GPU1.metal
//  pwdcrack
//
//  Created by Jacob Inwald on 10/12/2023.
//



/*
 #include <metal_stdlib>
 using namespace metal;
 #include "md5GPU.h"



 constant uint32_t r[] = {7, 12, 17, 22, 7, 12, 17, 22, 7, 12, 17, 22, 7, 12, 17, 22,
     5,  9, 14, 20, 5,  9, 14, 20, 5,  9, 14, 20, 5,  9, 14, 20,
     4, 11, 16, 23, 4, 11, 16, 23, 4, 11, 16, 23, 4, 11, 16, 23,
     6, 10, 15, 21, 6, 10, 15, 21, 6, 10, 15, 21, 6, 10, 15, 21};

 // Use binary integer part of the sines of integers (in radians) as constants// Initialize variables:
 constant uint32_t k[] = {
     0xd76aa478, 0xe8c7b756, 0x242070db, 0xc1bdceee,
     0xf57c0faf, 0x4787c62a, 0xa8304613, 0xfd469501,
     0x698098d8, 0x8b44f7af, 0xffff5bb1, 0x895cd7be,
     0x6b901122, 0xfd987193, 0xa679438e, 0x49b40821,
     0xf61e2562, 0xc040b340, 0x265e5a51, 0xe9b6c7aa,
     0xd62f105d, 0x02441453, 0xd8a1e681, 0xe7d3fbc8,
     0x21e1cde6, 0xc33707d6, 0xf4d50d87, 0x455a14ed,
     0xa9e3e905, 0xfcefa3f8, 0x676f02d9, 0x8d2a4c8a,
     0xfffa3942, 0x8771f681, 0x6d9d6122, 0xfde5380c,
     0xa4beea44, 0x4bdecfa9, 0xf6bb4b60, 0xbebfbc70,
     0x289b7ec6, 0xeaa127fa, 0xd4ef3085, 0x04881d05,
     0xd9d4d039, 0xe6db99e5, 0x1fa27cf8, 0xc4ac5665,
     0xf4292244, 0x432aff97, 0xab9423a7, 0xfc93a039,
     0x655b59c3, 0x8f0ccc92, 0xffeff47d, 0x85845dd1,
     0x6fa87e4f, 0xfe2ce6e0, 0xa3014314, 0x4e0811a1,
     0xf7537e82, 0xbd3af235, 0x2ad7d2bb, 0xeb86d391};

      

 void md5_block(device uint32_t * abcd, device uint8_t * msg, size_t initial_len) {
     

     // Should do padding but as the GPU words are all zeroed to begin with and each successive
     // word is guaranteed to be longer this step can be skipped
     // for(int i = initial_len; i < new_len+64; i++) *(msg + i) = 0x00;
     
     // IV
     abcd[0] = 0x67452301;
     abcd[1] = 0xefcdab89;
     abcd[2] = 0x98badcfe;
     abcd[3] = 0x10325476;
     
     int new_len = ((((initial_len + 8) >> 6) + 1) << 6) - 8;
     msg[initial_len] = 128;                             //write the "1" bit
     msg[new_len] = initial_len << 3;                    // append length

     // Start rolling
     int offset;
     uint32_t a,b,c,d,f,g,temp;
     uint32_t i;
     device uint32_t* w;
     
     for(offset=0; offset < new_len; offset += 128) {
   
         // break chunk into sixteen 32-bit words w[j], 0 ≤ j ≤ 15
         device uint32_t* w = (device uint32_t*) (msg + offset);

         // Initialize hash value for this chunk:
         a = abcd[0];
         b = abcd[1];
         c = abcd[2];
         d = abcd[3];
         
         // Main loop:
         
         for(i = 0; i < 16; i++) {
             f = (b & c) | ((~b) & d);
             g = i;
             temp = d;
             d = c;
             c = b;
             b = b + LEFTROTATE((a + f + k[i] + w[g]), r[i]);
             a = temp;
         }
         for(i = 0; i < 16; i++) {
             f = (d & b) | ((~d) & c);
             g = (i+i+i+i+i + 1) & (15);
             temp = d;
             d = c;
             c = b;
             b = b + LEFTROTATE((a + f + k[i+16] + w[g]), r[i+16]);
             a = temp;
         }

         for(i = 0; i < 16; i++) {
             f = b ^ c ^ d;
             g = (i+i+i + 5) & (15);
             temp = d;
             d = c;
             c = b;
             b = b + LEFTROTATE((a + f + k[i+32] + w[g]), r[i+32]);
             a = temp;
         }

         for(i = 0; i < 16; i++) {
             f = c ^ (b | (~d));
             g = (i+i+i+i+i+i+i) & (15);
             temp = d;
             d = c;
             c = b;
             b = b + LEFTROTATE((a + f + k[i+48] + w[g]), r[i+48]);
             a = temp;
         }
         // Add this chunk's hash to result so far:
         abcd[0] += a;
         abcd[1] += b;
         abcd[2] += c;
         abcd[3] += d;
     }
 }

*/


//for(i = 0; i < 16; i++) {
//    fn = F(b,c,d) + a + k_1[i] + w[i];
//    temp = d;
//    d = c;
//    c = b;
//    b = b + LEFTROTATE((fn), r_1[i]);
//    a = temp;
//}
//for(i = 0; i < 16; i++) {
//    fn = G(b,c,d) + a + k_2[i] + w[(5*i + 1) & (15)];
//    temp = d;
//    d = c;
//    c = b;
//    b = b + LEFTROTATE((fn), r_2[i]);
//    a = temp;
//}
//for(i = 0; i < 16; i++) {
//    fn = H(b,c,d) + a + k_3[i] + w[(3*i + 5) & (15)];
//    temp = d;
//    d = c;
//    c = b;
//    b = b + LEFTROTATE((fn), r_3[i]);
//    a = temp;
//}
//for(i = 0; i < 16; i++) {
//    fn = I(b,c,d) + a + k_4[i] + w[(7*i) & (15)];
//    temp = d;
//    d = c;
//    c = b;
//    b = b + LEFTROTATE((fn), r_4[i]);
//    a = temp;
//}
//
//
//#include <metal_stdlib>
//using namespace metal;
//#include "md5GPU.h"
//
//
//
//constant uint32_t r[] = {7, 12, 17, 22, 7, 12, 17, 22, 7, 12, 17, 22, 7, 12, 17, 22,
//    5,  9, 14, 20, 5,  9, 14, 20, 5,  9, 14, 20, 5,  9, 14, 20,
//    4, 11, 16, 23, 4, 11, 16, 23, 4, 11, 16, 23, 4, 11, 16, 23,
//    6, 10, 15, 21, 6, 10, 15, 21, 6, 10, 15, 21, 6, 10, 15, 21};
//
//// Use binary integer part of the sines of integers (in radians) as constants// Initialize variables:
//constant uint32_t k[] = {
//    0xd76aa478, 0xe8c7b756, 0x242070db, 0xc1bdceee,
//    0xf57c0faf, 0x4787c62a, 0xa8304613, 0xfd469501,
//    0x698098d8, 0x8b44f7af, 0xffff5bb1, 0x895cd7be,
//    0x6b901122, 0xfd987193, 0xa679438e, 0x49b40821,
//    0xf61e2562, 0xc040b340, 0x265e5a51, 0xe9b6c7aa,
//    0xd62f105d, 0x02441453, 0xd8a1e681, 0xe7d3fbc8,
//    0x21e1cde6, 0xc33707d6, 0xf4d50d87, 0x455a14ed,
//    0xa9e3e905, 0xfcefa3f8, 0x676f02d9, 0x8d2a4c8a,
//    0xfffa3942, 0x8771f681, 0x6d9d6122, 0xfde5380c,
//    0xa4beea44, 0x4bdecfa9, 0xf6bb4b60, 0xbebfbc70,
//    0x289b7ec6, 0xeaa127fa, 0xd4ef3085, 0x04881d05,
//    0xd9d4d039, 0xe6db99e5, 0x1fa27cf8, 0xc4ac5665,
//    0xf4292244, 0x432aff97, 0xab9423a7, 0xfc93a039,
//    0x655b59c3, 0x8f0ccc92, 0xffeff47d, 0x85845dd1,
//    0x6fa87e4f, 0xfe2ce6e0, 0xa3014314, 0x4e0811a1,
//    0xf7537e82, 0xbd3af235, 0x2ad7d2bb, 0xeb86d391};
//
//
//
//void md5_block(device uint32_t * abcd, device uint8_t * msg, size_t initial_len) {
//
//
//    // Should do padding but as the GPU words are all zeroed to begin with and each successive
//    // word is guaranteed to be longer this step can be skipped
//    // for(int i = initial_len; i < new_len+64; i++) *(msg + i) = 0x00;
//
//    // IV
//    abcd[0] = 0x67452301;
//    abcd[1] = 0xefcdab89;
//    abcd[2] = 0x98badcfe;
//    abcd[3] = 0x10325476;
//
//    int new_len = ((((initial_len + 8) >> 6) + 1) << 6) - 8;
//    msg[initial_len] = 128;                             //write the "1" bit
//    msg[new_len] = initial_len << 3;                    // append length
//
//    // Start rolling
//    int offset;
//    uint32_t a,b,c,d,f,g,temp;
//    uint32_t i;
//    device uint32_t* w;
//
//    for(offset=0; offset < new_len; offset += 128) {
//
//        // break chunk into sixteen 32-bit words w[j], 0 ≤ j ≤ 15
//        device uint32_t* w = (device uint32_t*) (msg + offset);
//
//        // Initialize hash value for this chunk:
//        a = abcd[0];
//        b = abcd[1];
//        c = abcd[2];
//        d = abcd[3];
//
//        // Main loop:
//
//        for(i = 0; i < 16; i++) {
//            f = (b & c) | ((~b) & d);
//            g = i;
//            temp = d;
//            d = c;
//            c = b;
//            b = b + LEFTROTATE((a + f + k[i] + w[g]), r[i]);
//            a = temp;
//        }
//        for(i = 0; i < 16; i++) {
//            f = (d & b) | ((~d) & c);
//            g = (i+i+i+i+i + 1) & (15);
//            temp = d;
//            d = c;
//            c = b;
//            b = b + LEFTROTATE((a + f + k[i+16] + w[g]), r[i+16]);
//            a = temp;
//        }
//
//        for(i = 0; i < 16; i++) {
//            f = b ^ c ^ d;
//            g = (i+i+i + 5) & (15);
//            temp = d;
//            d = c;
//            c = b;
//            b = b + LEFTROTATE((a + f + k[i+32] + w[g]), r[i+32]);
//            a = temp;
//        }
//
//        for(i = 0; i < 16; i++) {
//            f = c ^ (b | (~d));
//            g = (i+i+i+i+i+i+i) & (15);
//            temp = d;
//            d = c;
//            c = b;
//            b = b + LEFTROTATE((a + f + k[i+48] + w[g]), r[i+48]);
//            a = temp;
//        }
//        // Add this chunk's hash to result so far:
//        abcd[0] += a;
//        abcd[1] += b;
//        abcd[2] += c;
//        abcd[3] += d;
//    }
//}

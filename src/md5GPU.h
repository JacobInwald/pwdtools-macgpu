//
//  md5GPU.h
//  pwdcrack
//
//  Created by Jacob Inwald on 10/12/2023.
//

#ifndef md5GPU_h
#define md5GPU_h

// leftrotate function definition
#define LEFTROTATE(x, c) (((x) << (c)) | ((x) >> (32 - (c))))

void md5_block(device uint32_t * abcd, device uint8_t * msg, size_t initial_len);

#endif /* md5GPU_h */

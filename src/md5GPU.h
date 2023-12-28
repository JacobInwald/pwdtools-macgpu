//
//  md5GPU.h
//  pwdcrack
//
//  Created by Jacob Inwald on 10/12/2023.
//

#ifndef md5GPU_h
#define md5GPU_h

bool md5_check(device uint32_t * abcd, device uint32_t * msg);

bool md5_gen_and_check(device uint32_t * abcd, uint64_t n);
#endif /* md5GPU_h */

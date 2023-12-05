//
//  constants.h
//  pwdcrack
//
//  Created by Jacob Inwald on 03/12/2023.
//
#ifndef constants_h
#define constants_h
#import <Metal/Metal.h>

// To change settings right now:
//      1. set the pwd to crack in _tgt_word
//      2. change the word_length to the corresponding length
//      3. play with the character array
//      4. MAKE SURE THAT THE PWD_CRACK FILE REFLECTS ALL CHANGES YOU MAKE

static const int _word_length = 6;
static const char _characters[86] = {'a', 'b', 'c', 'd', 'e', 'f', 'g', 'h', 'i', 'j', 'k', 'l', 'm', 'n', 'o', 'p', 'q', 'r', 's', 't', 'u', 'v', 'w', 'x', 'y', 'z', 'A', 'B', 'C', 'D', 'E', 'F', 'G', 'H', 'I', 'J', 'K', 'L', 'M', 'N', 'O', 'P', 'Q', 'R', 'S', 'T', 'U', 'V', 'W', 'X', 'Y', 'Z', '1', '2', '3', '4', '5', '6', '7', '8', '9', '0', '!', '@', '#', '$', '%', '^', '&', '*', '(', ')', '_', '+', '-', '=', '[', ']', ':', ',', '.', '/', '\\', '<', '>', '?'};
static const int _char_length = 86;
static const char* _tgt_word = "abbbbb";

#endif

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

static const int _word_length = 7;
static const int _char_length = 88;
static const char* _tgt_word = "98bf8007a4656507ecf422888d9fbbd6";


static const uint _md5_length = 128; // Length in bytes

#endif

//
//  main.cpp
//  Chip-8-Emulator
//
//  Created by Marco Mussini on 04/06/2020.
//  Copyright © 2020 Marco Mussini. All rights reserved.
//

#include <iostream>

#include "Chip8.hpp"

int main(int argc, const char * argv[]) {
    if (argc < 2) {
        std::cout << "Usage: chip8 <imagefilename>" << std::endl;
        return 0;
    }

    Chip8 *chip8 = new Chip8();
    
    if (!chip8->LoadProgramIntoMemory(argv[1])) {
        std::cerr << "Program couldn't be loaded" << std::endl;
        exit(EXIT_FAILURE);
    }
    
    // TODO: init window and output
    
    chip8->RunLoop();
    
    std::cout << "End" << std::endl;
    
    return 0;
}

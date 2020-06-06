//
//  main.cpp
//  Chip-8-Emulator
//
//  Created by Marco Mussini on 04/06/2020.
//  Copyright © 2020 Marco Mussini. All rights reserved.
//

#include <iostream>

class Chip8 {

private:
    const short int programStartAddress = 0x200;
    static const short int memorySize = 4096;

    uint8_t memory[memorySize]{};
    uint8_t registersV[16]{};
    uint16_t registerI;

public:
    bool LoadProgramIntoMemory(const char *filename) {
        FILE *file = fopen(filename, "rb");
        if (file == nullptr) {
            return false;
        }

        size_t result = fread(memory + programStartAddress, 1, memorySize - programStartAddress, file);
        if (result == 0 || ferror(file))
        {
            fclose(file);
            return false;
        }

        fclose(file);

        return true;
    }
};

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

    return 0;
}

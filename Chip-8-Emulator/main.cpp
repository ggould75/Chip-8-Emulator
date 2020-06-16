//
//  main.cpp
//  Chip-8-Emulator
//
//  Created by Marco Mussini on 04/06/2020.
//  Copyright © 2020 Marco Mussini. All rights reserved.
//

#include <iostream>
#include <SDL2/SDL.h>

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
    
    if (SDL_Init( SDL_INIT_VIDEO ) < 0) {
        printf( "SDL could not initialize! SDL_Error: %s\n", SDL_GetError() );
        exit(EXIT_FAILURE);
    }
    
    SDL_Window *window = SDL_CreateWindow("Chip8 Emulator", SDL_WINDOWPOS_UNDEFINED, SDL_WINDOWPOS_UNDEFINED,
                                          640, 480, SDL_WINDOW_SHOWN);
    if (!window) {
        printf("Window could not be created! SDL_Error: %s\n", SDL_GetError());
        exit(EXIT_FAILURE);
    }
    
    SDL_Surface *screenSurface = SDL_GetWindowSurface( window );
    SDL_FillRect(screenSurface, NULL, SDL_MapRGB(screenSurface->format, 0xFF, 0x0, 0x0));
    SDL_UpdateWindowSurface(window);
    SDL_Event event;
    SDL_PollEvent(&event);
    SDL_Delay(2000);
    SDL_DestroyWindow(window);
    SDL_Quit();
    
    return 0;
}

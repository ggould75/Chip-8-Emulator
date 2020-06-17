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

const int PIXEL_SIZE = 20;

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
    
    int screenWidth = 64 * PIXEL_SIZE;
    int screenHeight = 32 * PIXEL_SIZE;
    
    SDL_Window *window = SDL_CreateWindow("Chip8 Emulator", SDL_WINDOWPOS_UNDEFINED, SDL_WINDOWPOS_UNDEFINED,
                                          screenWidth, screenHeight, SDL_WINDOW_SHOWN);
    if (!window) {
        printf("Window could not be created! SDL_Error: %s\n", SDL_GetError());
        SDL_Quit();
        exit(EXIT_FAILURE);
    }
  
/**
    // 1/3) Test draw a pixel using renderer
    SDL_Renderer *renderer = SDL_CreateRenderer(window, -1, SDL_RENDERER_ACCELERATED);
    if (!renderer) {
        SDL_DestroyWindow(window);
        SDL_Quit();
        exit(EXIT_FAILURE);
    }

    SDL_SetRenderDrawColor(renderer, 255, 255, 255, 255);
    SDL_RenderDrawPoint(renderer, 100, 100);
    SDL_RenderPresent(renderer);
    
    // 2/3) Test draw a pixel using surface
    SDL_Surface *screenSurface = SDL_GetWindowSurface( window );
    SDL_FillRect(screenSurface, NULL, SDL_MapRGB(screenSurface->format, 0xFF, 0x0, 0x0));
    uint8_t *pixels = (uint8_t *)screenSurface->pixels;
    pixels[256 * screenSurface->pitch + 512 * 4] = 0xFF;
    pixels[256 * screenSurface->pitch + 512 * 4 + 1] = 0xFF;
    SDL_UpdateWindowSurface(window);
*/
    // 3/3) Test draw pixels using renderer and texture
    SDL_Renderer *renderer = SDL_CreateRenderer(window, -1, SDL_RENDERER_ACCELERATED);
    if (!renderer) {
        SDL_DestroyWindow(window);
        SDL_Quit();
        exit(EXIT_FAILURE);
    }
    
    SDL_Texture *texture =
        SDL_CreateTexture(renderer, SDL_PIXELFORMAT_ARGB8888, SDL_TEXTUREACCESS_STATIC,
                          screenWidth, screenHeight);
    Uint32 *pixels = new Uint32[screenWidth * screenHeight];

    memset(pixels, 255, screenWidth * screenHeight * sizeof(Uint32));
    int x = 400;
    int y = 200;
    pixels[y * screenWidth + x] = 0;
    pixels[y * screenWidth + (x + 1)] = 0;
    SDL_UpdateTexture(texture, NULL, pixels, screenWidth * sizeof(Uint32));
    SDL_RenderCopy(renderer, texture, NULL, NULL);
    SDL_RenderPresent(renderer);
    delete[] pixels;
    SDL_DestroyTexture(texture);
    
    SDL_Event event;
    bool quit = false;
    while (!quit)
    {
        SDL_WaitEvent(&event);
        switch (event.type)
        {
            case SDL_QUIT:
                quit = true;
                break;
        }
    }
    
    SDL_DestroyRenderer(renderer);
    SDL_DestroyWindow(window);
    SDL_Quit();
    
    return 0;
}

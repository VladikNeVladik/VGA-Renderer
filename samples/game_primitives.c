// No copytight. Konstantin Nazarov, 2020
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

//===============================
// OTHER MEMORY LOCATION 
//===============================

#define HEX_DISPLAY ((char*) 0x00000100)

//===============================
// VIDEO MEMORY CHARACTERISTICS 
//===============================

#define VIDEO_MEMORY ((char*) 0xEEEE0000)
#define WIDTH        160
#define HEIGHT       120

#define RED   1
#define GREEN 2
#define BLUE  4

//===============================
// TIMING CHARACTERISTICS
//===============================

#define SEC 24000000

//====================
// UTILS
//====================

inline void set_pix(u_int32_t x, u_int32_t y, char color) {
    VIDEO_MEMORY[WIDTH * y + x] = color;
}

//====================
// VISUALIZER
//====================

void vis_enemy_corvette(u_int32_t x, u_int32_t y) {
    if (!(4 <= x && x <= WIDTH - 5 && 6 <= y && y <= HEIGHT - 7))
        return;

    const char color = RED;

    set_pix(x + 0, y + 0, color);
    set_pix(x + 0, y + 1, color);
    set_pix(x + 0, y + 2, color);
    set_pix(x + 0, y + 3, color);
    set_pix(x + 0, y + 4, color);
    set_pix(x + 0, y - 1, color);
    set_pix(x + 0, y - 2, color);
    set_pix(x + 0, y - 3, color);
    set_pix(x + 1, y + 0, color);
    set_pix(x + 1, y - 2, color);
    set_pix(x + 1, y - 3, color);
    set_pix(x + 1, y - 4, color);
    set_pix(x + 1, y + 1, color);
    set_pix(x + 1, y + 2, color);
    set_pix(x - 1, y + 0, color);
    set_pix(x - 1, y - 2, color);
    set_pix(x - 1, y - 3, color);
    set_pix(x - 1, y - 4, color);
    set_pix(x - 1, y + 1, color);
    set_pix(x - 1, y + 2, color);
    set_pix(x + 2, y + 0, color);
    set_pix(x + 2, y - 1, color);
    set_pix(x + 2, y - 2, color);
    set_pix(x + 2, y + 1, color);
    set_pix(x + 2, y + 2, color);
    set_pix(x + 2, y + 3, color);
    set_pix(x - 2, y + 0, color);
    set_pix(x - 2, y - 1, color);
    set_pix(x - 2, y - 2, color);
    set_pix(x - 2, y + 1, color);
    set_pix(x - 2, y + 2, color);
    set_pix(x - 2, y + 3, color);
    set_pix(x + 3, y + 0, color);
    set_pix(x + 3, y - 1, color);
    set_pix(x + 3, y - 4, color);
    set_pix(x + 3, y + 1, color);
    set_pix(x + 3, y + 3, color);
    set_pix(x - 3, y + 0, color);
    set_pix(x - 3, y - 1, color);
    set_pix(x - 3, y - 4, color);
    set_pix(x - 3, y + 1, color);
    set_pix(x - 3, y + 3, color);
    set_pix(x + 4, y + 0, color);
    set_pix(x + 4, y + 4, color);
    set_pix(x + 4, y - 2, color);
    set_pix(x + 4, y - 3, color);
    set_pix(x - 4, y + 0, color);
    set_pix(x - 4, y + 4, color);
    set_pix(x - 4, y - 2, color);
    set_pix(x - 4, y - 3, color);
    set_pix(x + 5, y + 1, color);
    set_pix(x + 5, y + 2, color);
    set_pix(x + 5, y - 4, color);
    set_pix(x - 5, y + 1, color);
    set_pix(x - 5, y + 2, color);
    set_pix(x - 5, y - 4, color);
    set_pix(x + 6, y + 3, color);
    set_pix(x - 6, y - 3, color);
}

void vis_enemy_projectile(u_int32_t x, u_int32_t y) {
    if (!(1 <= x && x <= WIDTH - 2 && 1 <= y && y <= HEIGHT - 2))
        return;

    const char color = RED|BLUE;

    set_pix(x + 0, y + 0, color);
    set_pix(x + 0, y + 1, color);
    set_pix(x + 0, y - 1, color);
    set_pix(x + 1, y + 1, color);
    set_pix(x + 1, y - 1, color);
    set_pix(x - 1, y + 1, color);
    set_pix(x - 1, y - 1, color);
    set_pix(x + 1, y + 0, color);
    set_pix(x - 1, y + 0, color);
}

void vis_player_ship(u_int32_t x, u_int32_t y) {
    if (!(8 <= x && x <= WIDTH - 9 && 4 <= y && y <= HEIGHT - 5))
        return;

    const char color = GREEN;

    set_pix(x + 0, y + 0, color);
    set_pix(x + 0, y + 1, color);
    set_pix(x + 0, y + 2, color);
    set_pix(x + 0, y + 4, color);
    set_pix(x + 0, y - 1, color);
    set_pix(x + 0, y - 2, color);
    set_pix(x + 0, y - 3, color);
    set_pix(x + 2, y + 0, color);
    set_pix(x - 2, y + 0, color);
    set_pix(x - 1, y - 1, color);
    set_pix(x - 2, y - 1, color);
    set_pix(x + 1, y - 1, color);
    set_pix(x + 2, y - 1, color);
    set_pix(x - 1, y - 2, color);
    set_pix(x - 2, y - 2, color);
    set_pix(x + 1, y - 2, color);
    set_pix(x + 2, y - 2, color);
    set_pix(x - 1, y - 3, color);
    set_pix(x + 1, y - 3, color);
    set_pix(x + 1, y + 4, color);
    set_pix(x - 1, y + 4, color);
    set_pix(x + 2, y + 4, color);
    set_pix(x + 2, y + 3, color);
    set_pix(x + 2, y + 2, color);
    set_pix(x - 2, y + 4, color);
    set_pix(x - 2, y + 3, color);
    set_pix(x - 2, y + 2, color);
    set_pix(x + 3, y - 4, color);
    set_pix(x + 3, y + 2, color);
    set_pix(x + 3, y + 3, color);
    set_pix(x - 3, y - 4, color);
    set_pix(x - 3, y + 2, color);
    set_pix(x - 3, y + 3, color);
    set_pix(x + 4, y + 1, color);
    set_pix(x + 4, y + 0, color);
    set_pix(x + 4, y - 1, color);
    set_pix(x + 4, y - 2, color);
    set_pix(x + 4, y - 3, color);
    set_pix(x + 4, y - 4, color);
    set_pix(x - 4, y + 1, color);
    set_pix(x - 4, y + 0, color);
    set_pix(x - 4, y - 1, color);
    set_pix(x - 4, y - 2, color);
    set_pix(x - 4, y - 3, color);
    set_pix(x - 4, y - 4, color);
    set_pix(x + 5, y - 3, color);
    set_pix(x - 5, y - 3, color);
    set_pix(x + 6, y + 1, color);
    set_pix(x + 6, y + 0, color);
    set_pix(x + 6, y - 1, color);
    set_pix(x + 6, y - 2, color);
    set_pix(x + 6, y - 3, color);
    set_pix(x - 6, y + 1, color);
    set_pix(x - 6, y + 0, color);
    set_pix(x - 6, y - 1, color);
    set_pix(x - 6, y - 2, color);
    set_pix(x - 6, y - 3, color);
    set_pix(x + 7, y + 0, color);
    set_pix(x + 7, y - 1, color);
    set_pix(x + 7, y - 2, color);
    set_pix(x + 7, y - 3, color);
    set_pix(x + 7, y - 4, color);
    set_pix(x - 7, y + 0, color);
    set_pix(x - 7, y - 1, color);
    set_pix(x - 7, y - 2, color);
    set_pix(x - 7, y - 3, color);
    set_pix(x - 7, y - 4, color);
    set_pix(x + 8, y + 1, color);
    set_pix(x + 8, y + 0, color);
    set_pix(x + 8, y - 1, color);
    set_pix(x + 8, y - 2, color);
    set_pix(x + 8, y - 3, color);
    set_pix(x - 8, y + 1, color);
    set_pix(x - 8, y + 0, color);
    set_pix(x - 8, y - 1, color);
    set_pix(x - 8, y - 2, color);
    set_pix(x - 8, y - 3, color);
}

void vis_player_projectile(u_int32_t x, u_int32_t y) {
    if (!(0 <= x && x <= WIDTH - 1 && 2 <= y && y <= HEIGHT - 3))
        return;

    const char color = GREEN|BLUE;

    set_pix(x, y + 2, color);
    set_pix(x, y + 1, color);
    set_pix(x, y + 0, color);
    set_pix(x, y - 1, color);
    set_pix(x, y - 2, color);
}

void vis_start_screen() {
}

void vis_death_screen() {
    char color = RED|GREEN|BLUE;

    const u_int32_t x = 10, y = 70;

    set_pix(x +  6, y -  3, color);
    set_pix(x +  6, y -  4, color);
    set_pix(x +  6, y -  5, color);
    set_pix(x +  6, y -  6, color);
    set_pix(x +  6, y -  7, color);
    set_pix(x +  6, y -  8, color);
    set_pix(x +  7, y -  7, color);
    set_pix(x +  7, y -  8, color);
    set_pix(x +  7, y -  9, color);
    set_pix(x +  7, y - 10, color);
    set_pix(x +  7, y - 11, color);
    set_pix(x +  8, y - 11, color);
    set_pix(x +  8, y - 12, color);
    set_pix(x +  9, y - 11, color);
    set_pix(x +  9, y - 12, color);
    set_pix(x + 10, y - 10, color);
    set_pix(x + 10, y - 11, color);
    set_pix(x + 11, y - 10, color);
    set_pix(x + 11, y - 11, color);
    set_pix(x + 12, y -  3, color);
    set_pix(x + 12, y -  4, color);
    set_pix(x + 12, y -  5, color);
    set_pix(x + 12, y -  9, color);
    set_pix(x + 12, y - 10, color);
    set_pix(x + 13, y -  5, color);
    set_pix(x + 13, y -  6, color);
    set_pix(x + 13, y -  9, color);
    set_pix(x + 13, y - 17, color);
    set_pix(x + 13, y - 18, color);
    set_pix(x + 13, y - 19, color);
    set_pix(x + 13, y -  9, color);
    set_pix(x + 14, y -  6, color);
    set_pix(x + 14, y -  8, color);
    set_pix(x + 14, y -  9, color);
    set_pix(x + 14, y - 15, color);
    set_pix(x + 14, y - 16, color);
    set_pix(x + 14, y - 17, color);
    set_pix(x + 14, y - 18, color);
    set_pix(x + 14, y - 19, color);
    set_pix(x + 14, y - 20, color);
    set_pix(x + 15, y -  6, color);
    set_pix(x + 15, y -  7, color);
    set_pix(x + 15, y -  8, color);
    set_pix(x + 15, y -  9, color);
    set_pix(x + 15, y - 12, color);
    set_pix(x + 15, y - 14, color);
    set_pix(x + 15, y - 15, color);
    set_pix(x + 15, y - 16, color);
    set_pix(x + 15, y - 17, color);
    set_pix(x + 15, y - 18, color);
    set_pix(x + 15, y - 19, color);
    set_pix(x + 15, y - 20, color);
    set_pix(x + 15, y - 21, color);
    set_pix(x + 16, y -  3, color);
    set_pix(x + 16, y -  4, color);
    set_pix(x + 16, y -  8, color);
    set_pix(x + 16, y -  9, color);
    set_pix(x + 16, y - 12, color);
    set_pix(x + 16, y - 14, color);
    set_pix(x + 16, y - 15, color);
    set_pix(x + 16, y - 19, color);
    set_pix(x + 16, y - 20, color);
    set_pix(x + 16, y - 21, color);
    set_pix(x + 17, y -  4, color);
    set_pix(x + 17, y -  5, color);
    set_pix(x + 17, y -  6, color);
    set_pix(x + 17, y -  7, color);
    set_pix(x + 17, y -  8, color);
    set_pix(x + 17, y -  9, color);
    set_pix(x + 17, y - 10, color);
    set_pix(x + 17, y - 11, color);
    set_pix(x + 17, y - 12, color);
    set_pix(x + 17, y - 14, color);
    set_pix(x + 17, y - 15, color);
    set_pix(x + 17, y - 19, color);
    set_pix(x + 17, y - 20, color);
    set_pix(x + 17, y - 21, color);
    set_pix(x + 17, y - 22, color);
    set_pix(x + 18, y -  8, color);
    set_pix(x + 18, y -  9, color);
    set_pix(x + 18, y - 10, color);
    set_pix(x + 18, y - 11, color);
    set_pix(x + 18, y - 12, color);
    set_pix(x + 18, y - 14, color);
    set_pix(x + 18, y - 15, color);
    set_pix(x + 18, y - 19, color);
    set_pix(x + 18, y - 20, color);
    set_pix(x + 18, y - 21, color);
    set_pix(x + 18, y - 22, color);
    set_pix(x + 18, y - 23, color);
    set_pix(x + 19, y -  4, color);
    set_pix(x + 19, y -  5, color);
    set_pix(x + 19, y -  6, color);
    set_pix(x + 19, y -  7, color);
    set_pix(x + 19, y -  8, color);
    set_pix(x + 19, y -  9, color);
    set_pix(x + 19, y - 10, color);
    set_pix(x + 19, y - 11, color);
    set_pix(x + 19, y - 12, color);
    set_pix(x + 19, y - 14, color);
    set_pix(x + 19, y - 15, color);
    set_pix(x + 19, y - 16, color);
    set_pix(x + 19, y - 20, color);
    set_pix(x + 19, y - 21, color);
    set_pix(x + 19, y - 22, color);
    set_pix(x + 19, y - 23, color);
    set_pix(x + 19, y - 24, color);
    set_pix(x + 20, y -  3, color);
    set_pix(x + 20, y -  4, color);
    set_pix(x + 20, y -  8, color);
    set_pix(x + 20, y -  9, color);
    set_pix(x + 20, y - 12, color);
    set_pix(x + 20, y - 13, color);
    set_pix(x + 20, y - 15, color);
    set_pix(x + 20, y - 16, color);
    set_pix(x + 20, y - 19, color);
    set_pix(x + 20, y - 20, color);
    set_pix(x + 20, y - 21, color);
    set_pix(x + 20, y - 22, color);
    set_pix(x + 20, y - 23, color);
    set_pix(x + 20, y - 24, color);
    set_pix(x + 21, y -  6, color);
    set_pix(x + 21, y -  7, color);
    set_pix(x + 21, y -  8, color);
    set_pix(x + 21, y - 12, color);
    set_pix(x + 21, y - 13, color);
    set_pix(x + 21, y - 14, color);
    set_pix(x + 21, y - 19, color);
    set_pix(x + 21, y - 20, color);
    set_pix(x + 21, y - 21, color);
    set_pix(x + 21, y - 23, color);
    set_pix(x + 21, y - 24, color);
    set_pix(x + 21, y - 25, color);
    set_pix(x + 21, y - 28, color);
    set_pix(x + 22, y -  6, color);
    set_pix(x + 22, y -  8, color);
    set_pix(x + 22, y -  9, color);
    set_pix(x + 22, y - 14, color);
    set_pix(x + 22, y - 15, color);
    set_pix(x + 22, y - 16, color);
    set_pix(x + 22, y - 17, color);
    set_pix(x + 22, y - 19, color);
    set_pix(x + 22, y - 20, color);
    set_pix(x + 22, y - 21, color);
    set_pix(x + 22, y - 24, color);
    set_pix(x + 22, y - 25, color);
    set_pix(x + 22, y - 27, color);
    set_pix(x + 22, y - 28, color);
    set_pix(x + 22, y - 29, color);
    set_pix(x + 23, y -  5, color);
    set_pix(x + 23, y -  6, color);
    set_pix(x + 23, y -  9, color);
    set_pix(x + 23, y - 10, color);
    set_pix(x + 23, y - 16, color);
    set_pix(x + 23, y - 17, color);
    set_pix(x + 23, y - 19, color);
    set_pix(x + 23, y - 20, color);
    set_pix(x + 23, y - 23, color);
    set_pix(x + 23, y - 24, color);
    set_pix(x + 23, y - 25, color);
    set_pix(x + 23, y - 26, color);
    set_pix(x + 23, y - 27, color);
    set_pix(x + 23, y - 29, color);
    set_pix(x + 23, y - 30, color);
    set_pix(x + 24, y -  3, color);
    set_pix(x + 24, y -  4, color);
    set_pix(x + 24, y -  5, color);
    set_pix(x + 24, y - 10, color);
    set_pix(x + 24, y - 11, color);
    set_pix(x + 24, y - 12, color);
    set_pix(x + 24, y - 16, color);
    set_pix(x + 24, y - 17, color);
    set_pix(x + 24, y - 19, color);
    set_pix(x + 24, y - 20, color);
    set_pix(x + 24, y - 22, color);
    set_pix(x + 24, y - 25, color);
    set_pix(x + 24, y - 26, color);
    set_pix(x + 24, y - 28, color);
    set_pix(x + 24, y - 29, color);
    set_pix(x + 25, y - 12, color);
    set_pix(x + 25, y - 13, color);
    set_pix(x + 25, y - 15, color);
    set_pix(x + 25, y - 16, color);
    set_pix(x + 25, y - 17, color);
    set_pix(x + 25, y - 19, color);
    set_pix(x + 25, y - 23, color);
    set_pix(x + 25, y - 24, color);
    set_pix(x + 25, y - 25, color);
    set_pix(x + 25, y - 26, color);
    set_pix(x + 25, y - 27, color);
    set_pix(x + 25, y - 28, color);
    set_pix(x + 26, y -  4, color);
    set_pix(x + 26, y -  5, color);
    set_pix(x + 26, y -  6, color);
    set_pix(x + 26, y - 12, color);
    set_pix(x + 26, y - 13, color);
    set_pix(x + 26, y - 16, color);
    set_pix(x + 26, y - 17, color);
    set_pix(x + 26, y - 22, color);
    set_pix(x + 26, y - 25, color);
    set_pix(x + 26, y - 26, color);
    set_pix(x + 26, y - 28, color);
    set_pix(x + 26, y - 29, color);
    set_pix(x + 27, y -  2, color);
    set_pix(x + 27, y -  3, color);
    set_pix(x + 27, y -  4, color);
    set_pix(x + 27, y -  6, color);
    set_pix(x + 27, y -  9, color);
    set_pix(x + 27, y - 10, color);
    set_pix(x + 27, y - 11, color);
    set_pix(x + 27, y - 12, color);
    set_pix(x + 27, y - 17, color);
    set_pix(x + 27, y - 18, color);
    set_pix(x + 27, y - 23, color);
    set_pix(x + 27, y - 24, color);
    set_pix(x + 27, y - 25, color);
    set_pix(x + 27, y - 26, color);
    set_pix(x + 27, y - 27, color);
    set_pix(x + 27, y - 29, color);
    set_pix(x + 27, y - 30, color);
    set_pix(x + 28, y -  2, color);
    set_pix(x + 28, y -  3, color);
    set_pix(x + 28, y -  4, color);
    set_pix(x + 28, y -  5, color);
    set_pix(x + 28, y -  6, color);
    set_pix(x + 28, y -  7, color);
    set_pix(x + 28, y -  8, color);
    set_pix(x + 28, y -  9, color);
    set_pix(x + 28, y - 18, color);
    set_pix(x + 28, y - 27, color);
    set_pix(x + 28, y - 28, color);
    set_pix(x + 28, y - 29, color);
    set_pix(x + 29, y -  2, color);
    set_pix(x + 29, y -  3, color);
    set_pix(x + 29, y -  4, color);
    set_pix(x + 29, y -  6, color);
    set_pix(x + 29, y - 28, color);
    set_pix(x + 30, y -  4, color);
    set_pix(x + 30, y -  5, color);
    set_pix(x + 30, y -  6, color);
}

void vis_clear()
{
    for (u_int32_t pos = 0; pos < WIDTH * HEIGHT; ++pos)
    {
        VIDEO_MEMORY[pos] = 0;
    }
}

//====================
// MAIN
//====================

int main()
{
    u_int32_t dir = 1;
    for (u_int32_t x = 0; 1; x += dir)
    {
        vis_clear();    

        if (x == 50) dir = -1;
        if (x ==  0) dir = +1;

        vis_player_ship(30 + 2*x, 110);

        vis_enemy_corvette(140 - x, 10);
        vis_enemy_corvette(120 - x, 10);
        vis_enemy_corvette(100 - x, 10);
        vis_enemy_corvette(80  - x, 10);

        vis_enemy_corvette(130 - x, 20);
        vis_enemy_corvette(110 - x, 20);
        vis_enemy_corvette(90  - x, 20);
        vis_enemy_corvette(70  - x, 20);

        for (u_int32_t time = 0; time < SEC/8; ++time); 
    }

    return 0;
}
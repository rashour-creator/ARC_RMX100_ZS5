#include "callbacks.h"
#include <fstream>
#include <iostream>
#include <cstring>

/******************************************* Global Variables ************************************************************/
#if AXI_XTOR_TCP_IP == 1
// This starts a socket (in the constructor)
TcpServer server;

/* This thread runs in parallel with the ARC (master) and the AXI memory (slave) codes
   It communicate with the slave using flags, and the slave communicates with the master using the Xtor
*/
std::thread g_socketThread;
// A global Buffer to save the received image data inside
char g_dataBuffer[MAX_INPUT_SZ];
// const size_t IMAGE_SIZE = 3072;
// uint32_t a=3;
// uint32_t b=4;
const unsigned char img_bytes30[3072] = {0, 0, 0, 3, 3, 3, 2, 0, 3, 5, 1, 2, 5, 5, 5, 1, 1, 1, 0, 0, 0, 2, 2, 0, 6, 9, 2, 0, 5, 1, 10, 18, 7, 46, 51, 44, 46, 48, 43, 11, 13, 12, 1, 7, 7, 1, 2, 4, 0, 1, 6, 0, 0, 2, 0, 0, 2, 2, 1, 0, 7, 1, 1, 15, 5, 4, 0, 2, 0, 1, 6, 2, 0, 0, 0, 3, 1, 2, 0, 0, 0, 2, 3, 5, 1, 1, 1, 1, 3, 0, 1, 3, 0, 0, 4, 0, 15, 11, 10, 10, 9, 7, 5, 1, 2, 6, 4, 5, 6, 8, 7, 0, 2, 0, 0, 0, 0, 4, 5, 0, 6, 9, 2, 2, 7, 0, 9, 15, 5, 67, 70, 63, 44, 45, 40, 13, 15, 12, 0, 4, 3, 2, 3, 5, 1, 2, 4, 0, 0, 0, 3, 3, 3, 2, 1, 0, 2, 1, 0, 2, 1, 0, 0, 2, 0, 0, 5, 1, 1, 1, 1, 0, 0, 0, 1, 1, 1, 0, 0, 0, 1, 1, 1, 1, 3, 0, 0, 2, 0, 0, 2, 0, 26, 15, 13, 26, 18, 15, 16, 15, 11, 17, 19, 16, 11, 16, 12, 9, 14, 10, 9, 5, 4, 2, 1, 0, 1, 1, 0, 8, 9, 3, 15, 15, 7, 73, 70, 63, 43, 43, 35, 7, 6, 1, 4, 3, 0, 0, 0, 0, 0, 0, 0, 5, 4, 2, 5, 0, 0, 3, 2, 0, 0, 2, 0, 0, 7, 0, 3, 8, 1, 0, 4, 0, 3, 9, 5, 4, 6, 5, 3, 5, 4, 6, 6, 6, 0, 0, 0, 5, 6, 8, 1, 1, 1, 1, 1, 0, 14, 5, 0, 14, 9, 3, 13, 14, 8, 13, 18, 12, 9, 14, 10, 13, 15, 12, 13, 12, 10, 2, 1, 0, 1, 1, 0, 2, 2, 0, 12, 9, 2, 78, 74, 65, 46, 43, 34, 15, 10, 4, 6, 0, 0, 14, 3, 1, 8, 0, 0, 6, 0, 0, 9, 4, 0, 4, 5, 0, 6, 14, 1, 1, 8, 0, 0, 10, 1, 2, 9, 1, 0, 5, 0, 0, 3, 0, 0, 2, 1, 2, 4, 3, 7, 9, 8, 2, 4, 3, 3, 3, 1, 5, 4, 2, 13, 13, 1, 10, 13, 2, 13, 19, 9, 13, 20, 12, 15, 16, 11, 12, 11, 7, 14, 15, 10, 8, 10, 5, 0, 2, 0, 1, 1, 1, 17, 14, 7, 75, 71, 62, 61, 54, 44, 27, 14, 6, 23, 2, 0, 22, 1, 0, 24, 3, 0, 16, 2, 1, 16, 12, 3, 0, 2, 0, 1, 6, 0, 1, 11, 0, 0, 7, 0, 3, 13, 2, 1, 11, 2, 7, 12, 6, 1, 1, 1, 7, 9, 4, 1, 1, 1, 0, 3, 2, 0, 0, 2, 2, 0, 3, 14, 18, 3, 13, 17, 3, 14, 20, 8, 14, 17, 8, 16, 13, 8, 9, 8, 4, 12, 11, 7, 4, 4, 2, 1, 1, 0, 9, 4, 0, 21, 6, 1, 48, 27, 24, 87, 63, 59, 59, 29, 27, 55, 19, 19, 85, 45, 46, 76, 40, 42, 53, 23, 23, 41, 17, 13, 30, 9, 4, 21, 1, 0, 12, 0, 0, 19, 16, 7, 1, 6, 0, 4, 10, 0, 8, 13, 6, 1, 3, 0, 1, 1, 1, 0, 2, 0, 1, 1, 1, 9, 9, 9, 0, 0, 0, 12, 12, 0, 15, 15, 3, 15, 15, 5, 15, 13, 1, 16, 11, 5, 16, 11, 5, 16, 13, 8, 11, 6, 2, 8, 0, 2, 24, 4, 3, 41, 0, 6, 115, 59, 68, 137, 80, 89, 116, 59, 68, 139, 86, 94, 140, 87, 95, 154, 98, 107, 146, 86, 96, 125, 55, 66, 105, 33, 45, 113, 43, 54, 49, 1, 1, 30, 2, 0, 14, 5, 0, 6, 9, 0, 7, 14, 6, 0, 2, 0, 0, 4, 0, 0, 2, 0, 0, 2, 0, 0, 2, 1, 2, 1, 0, 22, 19, 10, 19, 16, 7, 13, 9, 0, 16, 12, 3, 14, 9, 3, 17, 10, 2, 16, 9, 1, 22, 8, 5, 35, 9, 10, 56, 17, 22, 111, 60, 67, 151, 94, 103, 188, 131, 140, 215, 162, 172, 226, 179, 187, 226, 181, 184, 227, 180, 186, 230, 174, 185, 228, 160, 173, 208, 134, 149, 158, 84, 101, 126, 60, 72, 76, 23, 31, 42, 6, 8, 14, 0, 0, 2, 0, 1, 0, 2, 0, 0, 4, 0, 1, 3, 0, 1, 1, 1, 0, 2, 0, 4, 6, 5, 24, 19, 13, 18, 15, 10, 13, 13, 5, 14, 14, 4, 15, 17, 6, 21, 17, 6, 21, 11, 2, 34, 9, 5, 68, 15, 21, 130, 67, 76, 177, 132, 137, 216, 181, 185, 220, 194, 197, 220, 202, 202, 217, 201, 201, 214, 200, 199, 214, 198, 198, 218, 198, 199, 222, 196, 197, 218, 187, 192, 217, 185, 188, 187, 140, 148, 142, 68, 85, 108, 35, 52, 46, 3, 10, 12, 0, 0, 6, 2, 1, 0, 4, 0, 1, 1, 0, 2, 1, 0, 4, 0, 0, 2, 1, 0, 18, 13, 10, 13, 14, 8, 18, 19, 13, 12, 15, 6, 16, 17, 3, 31, 23, 12, 32, 12, 5, 71, 33, 32, 136, 76, 84, 194, 137, 144, 223, 188, 192, 218, 200, 198, 215, 207, 205, 207, 206, 202, 206, 208, 205, 206, 208, 205, 206, 205, 203, 207, 206, 204, 200, 199, 197, 206, 202, 199, 208, 200, 198, 213, 184, 188, 206, 139, 156, 149, 70, 91, 96, 34, 47, 36, 0, 2, 14, 3, 1, 4, 7, 0, 8, 9, 3, 2, 0, 1, 2, 1, 0, 10, 4, 4, 25, 21, 18, 14, 13, 9, 19, 20, 14, 24, 24, 14, 23, 23, 11, 32, 15, 7, 54, 12, 13, 126, 77, 80, 178, 138, 139, 220, 190, 190, 216, 196, 195, 207, 196, 192, 197, 191, 191, 203, 202, 200, 206, 206, 206, 206, 208, 207, 207, 207, 205, 203, 203, 203, 197, 203, 203, 190, 196, 194, 184, 186, 185, 200, 190, 191, 219, 186, 193, 190, 136, 149, 143, 70, 89, 69, 7, 20, 25, 4, 1, 1, 1, 0, 1, 3, 0, 2, 4, 1, 1, 1, 1, 11, 12, 7, 19, 18, 14, 23, 22, 18, 21, 21, 13, 25, 25, 15, 33, 27, 15, 48, 23, 16, 109, 54, 57, 180, 121, 127, 204, 176, 172, 207, 194, 188, 165, 155, 153, 141, 133, 131, 138, 134, 133, 150, 148, 149, 190, 190, 190, 206, 206, 206, 207, 205, 208, 200, 204, 205, 171, 177, 177, 133, 139, 139, 129, 133, 132, 144, 143, 141, 185, 173, 173, 214, 179, 185, 195, 127, 142, 114, 48, 62, 26, 0, 0, 13, 8, 2, 8, 9, 1, 1, 3, 0, 0, 5, 0, 3, 5, 0, 28, 20, 17, 28, 23, 17, 25, 21, 12, 28, 21, 11, 38, 24, 15, 60, 29, 24, 152, 89, 97, 210, 151, 157, 214, 190, 188, 174, 169, 163, 142, 137, 134, 161, 157, 156, 162, 161, 159, 126, 126, 126, 148, 146, 147, 198, 198, 198, 200, 204, 205, 183, 187, 188, 135, 135, 135, 134, 132, 135, 146, 144, 145, 130, 126, 125, 144, 139, 136, 197, 177, 178, 207, 160, 168, 150, 97, 105, 80, 39, 43, 30, 6, 6, 2, 1, 0, 0, 5, 0, 1, 3, 0, 5, 7, 2, 19, 12, 4, 24, 17, 11, 29, 25, 14, 24, 14, 4, 41, 21, 12, 87, 49, 46, 189, 128, 135, 230, 177, 183, 233, 215, 211, 201, 200, 195, 188, 187, 183, 215, 214, 212, 200, 202, 201, 148, 150, 149, 130, 129, 127, 184, 186, 185, 198, 199, 201, 152, 153, 155, 126, 124, 125, 186, 181, 185, 203, 199, 200, 160, 159, 157, 113, 112, 107, 176, 162, 161, 213, 181, 182, 172, 130, 134, 104, 62, 64, 35, 3, 4, 15, 8, 0, 0, 2, 0, 1, 3, 0, 7, 8, 3, 25, 27, 14, 22, 20, 7, 32, 26, 14, 35, 23, 11, 54, 27, 20, 95, 57, 56, 196, 143, 149, 246, 201, 208, 237, 223, 222, 220, 219, 215, 222, 222, 220, 217, 219, 218, 182, 186, 185, 136, 141, 137, 155, 154, 152, 207, 206, 204, 197, 197, 197, 134, 134, 134, 134, 132, 133, 194, 192, 193, 203, 205, 204, 176, 178, 175, 109, 108, 104, 164, 154, 152, 207, 188, 184, 192, 162, 162, 134, 94, 95, 33, 1, 2, 15, 6, 0, 5, 6, 0, 2, 1, 0, 13, 4, 7, 19, 21, 7, 24, 25, 11, 28, 25, 10, 32, 20, 8, 50, 21, 15, 99, 59, 59, 201, 156, 161, 243, 208, 212, 235, 225, 224, 230, 232, 229, 216, 220, 219, 195, 196, 200, 135, 139, 140, 131, 133, 132, 186, 185, 181, 218, 214, 213, 195, 194, 192, 129, 127, 128, 139, 135, 136, 195, 193, 194, 205, 207, 206, 172, 177, 173, 111, 112, 107, 151, 148, 141, 203, 188, 183, 207, 179, 176, 134, 92, 94, 40, 4, 4, 20, 9, 5, 3, 3, 1, 2, 1, 0, 10, 4, 4, 19, 23, 9, 12, 14, 0, 28, 26, 13, 26, 16, 6, 45, 16, 12, 96, 57, 58, 205, 164, 168, 241, 212, 216, 233, 224, 225, 228, 229, 231, 225, 226, 230, 211, 215, 218, 187, 187, 189, 155, 153, 154, 163, 159, 160, 209, 205, 202, 190, 188, 189, 131, 127, 128, 142, 133, 136, 202, 196, 198, 205, 207, 204, 173, 178, 172, 108, 113, 106, 150, 150, 140, 204, 191, 183, 202, 173, 169, 143, 91, 95, 76, 30, 33, 15, 1, 0, 2, 2, 0, 2, 1, 0, 10, 9, 7, 13, 15, 2, 18, 18, 6, 23, 24, 10, 22, 14, 1, 39, 14, 7, 97, 62, 60, 196, 156, 157, 238, 206, 211, 236, 226, 225, 217, 217, 217, 217, 218, 220, 223, 224, 228, 217, 215, 218, 171, 169, 170, 131, 130, 128, 172, 171, 169, 186, 186, 186, 141, 139, 140, 144, 138, 140, 204, 198, 198, 213, 213, 211, 172, 177, 171, 110, 115, 108, 161, 161, 151, 206, 191, 184, 195, 164, 161, 138, 86, 90, 50, 1, 5, 12, 0, 0, 1, 1, 0, 4, 5, 0, 5, 5, 3, 22, 18, 7, 27, 23, 11, 18, 21, 4, 18, 16, 1, 35, 19, 4, 93, 63, 53, 201, 153, 153, 242, 200, 202, 222, 207, 202, 183, 182, 177, 189, 191, 186, 222, 222, 220, 219, 221, 218, 171, 173, 170, 126, 128, 123, 169, 171, 168, 188, 189, 191, 152, 153, 155, 137, 137, 139, 194, 194, 194, 214, 216, 213, 170, 172, 167, 120, 120, 112, 176, 169, 161, 215, 196, 190, 198, 164, 162, 126, 77, 80, 44, 4, 5, 25, 7, 3, 9, 6, 1, 0, 0, 0, 5, 4, 0, 26, 17, 8, 22, 20, 8, 17, 21, 6, 20, 21, 3, 33, 24, 7, 70, 43, 32, 175, 121, 119, 218, 166, 168, 218, 194, 190, 172, 168, 159, 138, 137, 132, 159, 161, 156, 172, 174, 171, 142, 144, 141, 140, 142, 139, 201, 203, 202, 215, 216, 218, 175, 176, 180, 134, 138, 139, 159, 161, 160, 173, 173, 171, 142, 141, 137, 138, 135, 128, 201, 188, 182, 221, 187, 186, 170, 128, 129, 110, 68, 69, 27, 1, 0, 10, 0, 0, 5, 6, 0, 4, 5, 0, 4, 6, 1, 27, 26, 21, 23, 23, 15, 25, 29, 15, 26, 29, 12, 36, 31, 12, 58, 31, 20, 136, 80, 79, 205, 146, 148, 233, 199, 197, 220, 205, 198, 175, 170, 166, 140, 139, 137, 128, 128, 128, 150, 148, 151, 196, 194, 197, 221, 219, 222, 222, 223, 227, 209, 213, 216, 165, 169, 170, 127, 127, 127, 123, 117, 119, 143, 135, 133, 180, 175, 169, 211, 190, 187, 207, 154, 160, 147, 86, 91, 67, 29, 28, 28, 11, 3, 17, 15, 3, 1, 3, 2, 1, 3, 0, 1, 8, 0, 26, 26, 24, 24, 26, 21, 24, 30, 18, 24, 26, 13, 30, 27, 10, 49, 30, 15, 90, 42, 38, 178, 122, 123, 221, 175, 175, 244, 213, 211, 229, 215, 214, 205, 201, 198, 204, 204, 204, 215, 213, 216, 229, 224, 228, 228, 226, 227, 225, 226, 228, 223, 227, 228, 216, 218, 217, 195, 194, 192, 194, 186, 184, 207, 191, 191, 226, 208, 204, 216, 182, 181, 189, 126, 134, 128, 69, 75, 34, 11, 3, 22, 16, 2, 14, 15, 1, 11, 15, 1, 4, 14, 3, 3, 15, 3, 21, 21, 21, 29, 31, 30, 26, 31, 24, 26, 32, 22, 34, 32, 19, 41, 31, 19, 53, 26, 17, 110, 69, 65, 189, 128, 135, 234, 179, 185, 240, 214, 213, 236, 226, 224, 227, 227, 225, 226, 228, 227, 228, 228, 228, 223, 223, 223, 226, 228, 225, 223, 225, 222, 220, 225, 219, 222, 221, 216, 225, 220, 214, 231, 212, 208, 230, 185, 188, 194, 137, 144, 138, 86, 90, 55, 20, 16, 33, 27, 13, 20, 27, 9, 19, 20, 6, 23, 25, 11, 17, 25, 12, 9, 20, 6, 20, 22, 21, 27, 32, 28, 22, 25, 18, 29, 32, 23, 36, 36, 24, 37, 31, 17, 45, 33, 19, 56, 29, 18, 121, 69, 71, 192, 133, 139, 212, 172, 173, 233, 207, 206, 243, 223, 225, 236, 224, 224, 234, 224, 223, 236, 228, 225, 231, 223, 221, 232, 222, 220, 233, 222, 218, 236, 221, 216, 231, 212, 206, 221, 187, 186, 191, 136, 141, 144, 88, 91, 73, 33, 31, 39, 19, 8, 21, 24, 7, 15, 24, 5, 18, 22, 7, 20, 22, 8, 18, 24, 10, 15, 23, 10, 18, 23, 16, 22, 23, 17, 25, 25, 15, 27, 27, 15, 25, 26, 10, 30, 27, 12, 35, 32, 15, 41, 29, 15, 60, 36, 26, 105, 67, 64, 167, 117, 120, 206, 149, 155, 223, 172, 177, 241, 199, 200, 239, 208, 206, 239, 211, 210, 240, 208, 209, 241, 209, 210, 238, 199, 200, 226, 180, 180, 208, 156, 160, 178, 124, 124, 137, 89, 87, 67, 32, 26, 41, 19, 8, 31, 22, 7, 29, 26, 9, 20, 23, 6, 24, 26, 12, 16, 20, 5, 20, 26, 12, 17, 25, 14, 17, 19, 8, 18, 21, 10, 27, 27, 15, 29, 29, 17, 27, 25, 12, 29, 27, 12, 32, 33, 17, 37, 35, 20, 40, 32, 19, 53, 33, 24, 91, 45, 45, 149, 90, 94, 183, 128, 131, 192, 143, 146, 190, 152, 151, 194, 160, 158, 196, 162, 161, 192, 152, 153, 187, 141, 143, 178, 128, 127, 156, 100, 101, 116, 65, 62, 69, 35, 26, 40, 22, 8, 31, 22, 5, 29, 26, 9, 30, 24, 10, 25, 22, 7, 26, 27, 13, 20, 24, 9, 20, 26, 12, 17, 25, 10, 12, 15, 4, 13, 17, 3, 23, 26, 15, 26, 28, 15, 28, 24, 13, 32, 28, 17, 30, 31, 17, 33, 34, 20, 38, 35, 20, 45, 35, 25, 63, 40, 34, 115, 87, 84, 111, 88, 82, 114, 89, 84, 175, 150, 145, 226, 201, 197, 221, 196, 189, 195, 166, 160, 126, 93, 88, 98, 65, 58, 70, 40, 32, 49, 27, 14, 48, 35, 19, 37, 30, 12, 36, 33, 16, 38, 35, 18, 31, 28, 13, 25, 23, 10, 28, 26, 13, 24, 25, 11, 22, 26, 11, 20, 27, 11, 21, 21, 9, 17, 19, 8, 27, 31, 17, 28, 30, 17, 31, 27, 16, 36, 32, 21, 31, 31, 19, 33, 33, 21, 38, 36, 24, 35, 31, 20, 50, 43, 33, 99, 90, 81, 78, 68, 59, 71, 61, 52, 199, 184, 177, 251, 236, 229, 255, 242, 234, 216, 199, 191, 67, 44, 36, 61, 41, 32, 48, 34, 21, 43, 36, 18, 36, 33, 14, 32, 31, 11, 37, 31, 15, 41, 38, 21, 30, 28, 15, 26, 24, 11, 27, 25, 12, 28, 29, 13, 23, 30, 14, 28, 32, 17, 29, 23, 11, 26, 22, 10, 31, 33, 19, 28, 30, 16, 24, 24, 12, 29, 27, 15, 26, 26, 14, 29, 29, 19, 36, 34, 22, 36, 33, 24, 41, 41, 31, 97, 97, 87, 61, 58, 51, 61, 56, 52, 210, 205, 201, 250, 249, 244, 247, 247, 239, 215, 212, 203, 67, 57, 48, 50, 37, 28, 36, 30, 14, 36, 33, 16, 38, 35, 18, 33, 30, 13, 33, 30, 13, 41, 38, 23, 32, 30, 17, 29, 27, 14, 29, 27, 14, 32, 28, 16, 28, 29, 15, 32, 35, 18, 57, 48, 33, 51, 45, 29, 53, 51, 36, 49, 50, 34, 48, 42, 28, 49, 45, 33, 47, 43, 31, 46, 42, 31, 46, 42, 31, 48, 48, 38, 48, 51, 40, 97, 100, 91, 66, 65, 63, 65, 64, 62, 210, 210, 208, 245, 247, 244, 243, 248, 242, 203, 204, 196, 70, 63, 55, 61, 54, 44, 56, 54, 39, 47, 46, 28, 52, 49, 32, 50, 44, 30, 47, 41, 27, 50, 47, 32, 40, 38, 25, 38, 36, 23, 37, 35, 23, 41, 37, 25, 40, 38, 25, 41, 42, 24, 87, 81, 59, 82, 75, 56, 81, 76, 57, 82, 77, 58, 84, 75, 58, 84, 75, 58, 81, 75, 59, 75, 68, 52, 70, 61, 46, 72, 66, 52, 84, 88, 74, 94, 100, 88, 83, 82, 78, 72, 68, 65, 214, 214, 214, 245, 246, 248, 248, 247, 245, 201, 200, 196, 83, 78, 72, 78, 71, 63, 65, 66, 52, 67, 68, 52, 63, 57, 43, 67, 60, 44, 63, 57, 43, 63, 57, 45, 56, 50, 38, 58, 52, 40, 61, 55, 43, 63, 57, 43, 61, 58, 41, 59, 56, 39, 101, 95, 71, 99, 93, 71, 100, 93, 75, 105, 97, 78, 103, 95, 76, 102, 94, 75, 102, 95, 77, 97, 90, 72, 102, 93, 78, 96, 88, 75, 91, 95, 80, 93, 99, 89, 76, 72, 69, 92, 86, 90, 217, 217, 219, 248, 248, 250, 247, 245, 248, 137, 132, 129, 96, 92, 83, 102, 98, 89, 90, 92, 79, 88, 90, 76, 93, 87, 73, 83, 73, 61, 74, 68, 54, 73, 67, 55, 70, 64, 52, 76, 70, 56, 81, 75, 61, 78, 72, 56, 71, 65, 49, 62, 56, 40};
// A global flag for synchronization between ARC and the running thre
SynchronizationFlags g_flags;
#endif
extern xtor_amba_slave_svs * g_objAmbaSlave;

#if AXI_XTOR_TCP_IP == 1
// A function for accepting a client and receiving data from it
void startServer()
{
	int expectedDataSize = 0, actualDataSizeReceived = 0, receivedDataSizeAcc;
	client_Server_State_t state;
	send_recv_state_t receiveState;

	//Keep trying to start the Tcp/Ip server
	//do 
	//{
		//state = server.startServer(5050);
	//}while(state != SERVER_STARTED_SUCCESSFULLY);

	// Keep trying to accept a client
	//do
	//{
		//std::cout << "Waiting for a Client" << std::endl;
		//state = server.acceptClient();
	//} while (state != ACCPETED_CLIENT_SUCCESSFULLY);

	// A client is accepted
	g_flags.clientAccepted = true;

	std::cout << "Got a client" << std::endl;
	// storing the input data in the g_dataBuffer
	std::cout << "Storing the inputs in input section" << std::endl;
	// std::ifstream file("image_pixels.txt", std::ios::binary);
// if (!file) {
    // std::cerr << "Failed to open file: image_pixels.txt" << std::endl;
   //  return;
// }

// file.read(reinterpret_cast<char*>(g_dataBuffer), IMAGE_SIZE);
// if (!file) {
    // std::cerr << "Failed to read the expected number of bytes." << std::endl;
   //  return;
// }

// std::cout << "Image data loaded into g_dataBuffer." << std::endl;
memcpy(g_dataBuffer, img_bytes30, sizeof(img_bytes30));

	// storing the first integer a to the buffer
	//std::cout << "Storing the first input to add" << std::endl;
	//memcpy(g_dataBuffer, &a, 4);
	// storing the second integer a to the buffer
	//std::cout << "Storing the second input to add" << std::endl;
	//memcpy(g_dataBuffer + 4, &b, 4);
	// setting the input ready flag to 1 
	std::cout << "Setting the input ready falg" << std::endl;
	g_flags.dataReceived = true;


	//while(1)
	//{
		//receiveState = server.recvData(g_dataBuffer, MAX_INPUT_SZ, actualDataSizeReceived);

		//if(receiveState == SEND_OR_RECV_SUCCESSFULLY)
		//{
			//if(g_dataBuffer[0] == 1)
			//{
				// client just sends a beat for continuing the connection.
				//continue;
			//}

			//check_client_state();
			//if(g_flags.terminateARCApp == true)
			//{
				// shutdown the transactor and zRci runtime tool.
				//std::cout << "Received a termination signal from the client side" << std::endl;
				//break;
			//}

			// Getting the data size to be received (which is sent in the first four bytes)
			//memcpy(&expectedDataSize, g_dataBuffer+1, sizeof(int));

			// In case the data to be received was divided
			//receivedDataSizeAcc = actualDataSizeReceived;

			/* If expectedDataSize != RxDataSz then the data is fragmented 
			* so we iterate on the recv function to get the expected size */
			//while(receivedDataSizeAcc < (expectedDataSize + FIRST_PACKET_OVERHEAD))
			//{
				//receiveState = server.recvData(g_dataBuffer + receivedDataSizeAcc, MAX_INPUT_SZ, actualDataSizeReceived);

				// receive the start of the data from the emulator.
				//if(receiveState == SEND_OR_RECV_SUCCESSFULLY)
				//{
					//receivedDataSizeAcc += actualDataSizeReceived;
				//}

				//else if (receiveState == CLIENT_DISCONNECTED)
				//{
					/* Client is disconnected, so block again until we receive a new client */
					//g_flags.dataReceived = false;
					//break;
				//}
			//}

			//if (receiveState != CLIENT_DISCONNECTED)
			//{
				//g_flags.dataReceived = true;
			//}
		//}

		//if (receiveState == CLIENT_DISCONNECTED)
		//{
			//g_flags.clientAccepted = false;

			// Keep trying to accept a client
			//do
			//{
				//state = server.acceptClient();
			//} while (state != ACCPETED_CLIENT_SUCCESSFULLY);

			//g_flags.clientAccepted = true;
		//}	
	//}

}
/**
 * @brief: test the first five bytes of the received buufer from the client 
 * 			and check if the first 5 five bytes are zeros then set the termination flag with 1.
*/
//void check_client_state(void)
//{
	//if (g_dataBuffer[0] == 0)
	//{
		//uint8_t cnt = 1;
		//uint8_t i=0;
		//for (i=1; i<5; ++i)
		//{
			//if (g_dataBuffer[i] == 0)
			//{
				//cnt++;
			//}
		//}
		//if(cnt == 5)
		//{
			//g_flags.terminateARCApp = true;
		//} 
	//}
//}
#endif

// Slave related callbacks
void cb_raddr(void* xtor, ZEBU_IP::XTOR_AMBA_DEFINES_SVS::AXIChanInfo addr)
{       printf("[xtor]: inside cb_raddr\n") ; 

	AddressHandler* handler = AddressHandler::getHandlerInstance();
	ZEBU_IP::XTOR_AMBA_DEFINES_SVS::AXIResp* currentResponse = new ZEBU_IP::XTOR_AMBA_DEFINES_SVS::AXIResp();
	ZEBU_IP::XTOR_AMBA_DEFINES_SVS::AXIData* currentAxiRdata = new ZEBU_IP::XTOR_AMBA_DEFINES_SVS::AXIData();
	if (!handler || !currentResponse ||!currentAxiRdata) {
	printf("NULL pointer detected \n");
	return;
}

	/* This part isn't important, but I left it for the rest of the team */
	// currentAxiRdata->SetId(addr.id);
	// currentResponse->SetId(addr.id);
	// addr.printChanInfoAXI3();
	// Preparing some member variables to be used by the read handler
	handler->setResponse(currentResponse);
	handler->setReadData(currentAxiRdata);
	handler->setReadAddress(addr.addr);
	handler->setSize(addr.size);
	handler->setBurstLength(addr.len);
	#if AXI_XTOR_TCP_IP == 1
	//for (int i=0; i<8; ++i)
	//{   std::cout << "Printing the g_dataBuffer" << std::endl;
		//printf("Byte %d: 0x%02X\n", i, static_cast<uint8_t>(g_dataBuffer[i]));
	//}
	handler->setPtrToImageBuffer(g_dataBuffer);
	#endif
	handler->setTotalBytes(addr.size, addr.len);
	if(addr.addr >= AXI_INPUT_BASE_ADDR && addr.addr <= AXI_INPUT_BASE_ADDR+MAX_INPUT_SZ)
	{// debug the read request for the input data
		// addr.printChanInfoAXI3();
	}
	// Calling the correct handler for that specific address
	handler->handleReadCallback();
}

void cb_wrtxn(void* xtor,ZEBU_IP::XTOR_AMBA_DEFINES_SVS::AXIChanInfo addr, ZEBU_IP::XTOR_AMBA_DEFINES_SVS::AXIData* data)
{       printf("[xtor]: inside cb_wrtxn\n");
	AddressHandler* handler = AddressHandler::getHandlerInstance();
	ZEBU_IP::XTOR_AMBA_DEFINES_SVS::AXIResp* currentResponse = new ZEBU_IP::XTOR_AMBA_DEFINES_SVS::AXIResp();

	/* Getting a pointer on the correct data */ 
	ZEBU_IP::XTOR_AMBA_DEFINES_SVS::axi_addr_t dataIdx = addr.addr % 8;
	uint8_t* dataPtr = data->GetDataPt(dataIdx);

	handler->setResponse(currentResponse);
	handler->setWriteAddress(addr.addr);
	handler->setWriteData(dataPtr);
	handler->setSize(addr.size);
	handler->setBurstLength(addr.len);
	handler->setTotalBytes(addr.size, addr.len);

	/* This part isn't important, but I left it for the rest of the team */
	currentResponse->SetId(addr.id);
	
	ZEBU_IP::XTOR_AMBA_DEFINES_SVS::enAXIResp bresp = ZEBU_IP::XTOR_AMBA_DEFINES_SVS::AXI_RESP_OKAY;
	currentResponse->AddResp(bresp);

	// Calling the correct handler for that specific address
	handler->handleWriteCallback();
}



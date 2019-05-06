/* Lua uses this file to generate constants for itself
 * the format should always be #define<space>variable<space><value>
 * Note that the value is on a single line and has no spaces
 * Also only a single underscore should be used between two alphabets
 */

#ifndef __Q_CONSTANTS
#define __Q_CONSTANTS
#define TRUE 1
#define FALSE 0
#define Q_ERR_MSG_LEN 1023
#define Q_MAX_LEN_API_NAME 31
#define Q_MAX_LEN_PATH      255
#define Q_MAX_LEN_FILE_NAME 127
#define Q_MAX_LEN_ARGS     4095
#define Q_MAX_HEADERS_SIZE 8191
#define Q_MAX_LEN_BODY    32767
#define Q_MAX_LEN_RESULT  32767
#define Q_MAX_LEN_FLAGS  255
#endif


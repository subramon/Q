/* START HDR FILES  */
#include <stdio.h>
#include <stdbool.h>
#include <stdlib.h>
#include <unistd.h>
#include <sys/types.h>
#include <sys/stat.h>
#include <sys/mman.h>
#include <unistd.h>
#include <sys/mman.h>
#include <string.h>
#include <assert.h>
#include <fcntl.h>
#include <errno.h>
#define MAX_LEN_DIR_NAME 1000
int write_ints(
    const char* file_name,
    int val, size_t count
)
{
    int status = 0;
    FILE* fd;
    struct stat filestat;
    size_t len;

    fd = fopen(file_name, "wb");
    if (fd < 0)
    {
        char cwd[MAX_LEN_DIR_NAME + 1];
        if (getcwd(cwd, MAX_LEN_DIR_NAME) == NULL)
        {
            return -1;
        }
        fprintf(stderr, "Could not open file [%s] \n", file_name);
        fprintf(stderr, "Currently in dir    [%s] \n", cwd);
        return -1;
    }
    for (int iter = 0; iter < count; iter++)
        fwrite(&iter, sizeof(iter), 1, fd);
    fclose(fd);
    return 0;
}

int print_ints(
    const char* file_name
)
{
    int status = 0;
    FILE* fd;
    struct stat filestat;
    size_t len;
    int num;
    fd = fopen(file_name, "r");
    if (fd < 0)
    {
        char cwd[MAX_LEN_DIR_NAME + 1];
        if (getcwd(cwd, MAX_LEN_DIR_NAME) == NULL)
        {
            return -1;
        }
        fprintf(stderr, "Could not open file [%s] \n", file_name);
        fprintf(stderr, "Currently in dir    [%s] \n", cwd);
        return -1;
    }
    fseek(fd, 0L, SEEK_END);
    size_t pos = ftell(fd);    // Current position
    fseek(fd, 0, SEEK_END);    // Go to end
    len = ftell(fd) / sizeof(int); // read the position which is the size
    rewind(fd);
    for (int iter = 0; iter < len; iter++)
    {
        int val = fread(&num, sizeof(int), 1, fd);
        if (val == 1)
            printf("%d\t%d\n", iter, num);
    }
    fclose(fd);
    return 0;
}


int main()
{
    const char* f_name = "test.txt";
    write_ints(f_name, 111, 10000);
    print_ints(f_name);
}

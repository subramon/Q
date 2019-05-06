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
//#include "../../AxEqualsBSolver/macros.h"
#define SET_BIT(x,i)  (x)[(i) / 8] |= (1 << ((i) % 8))
#define CLEAR_BIT(x,i) (x)[(i) / 8] &= ~(1 << ((i) % 8))
#define GET_BIT(x,i) (((x)[(i) / 8] & (1 << ((i) % 8))) > 0)
#define cBYE(status) \
    do {if ( (status) != 0 ){fprintf(stderr, "info: %s:%d:\n ", __FILE__, __LINE__); \
    return(status);}}while(0)
//#define cBYE(x) do { if ( (x) !=0) return (x);  } while(0)
#define PRINT_TEST 0
#define debug_print(...) \
    do { if (PRINT_TEST)  fprintf(stderr, __VA_ARGS__);} while (0)
//#define cBYE(i) (i) < 1 && return -1
#define assertc(A, ...) if((A) != true ){fprintf(stderr, "info: %s:%d:\t", __FILE__, __LINE__); fprintf(stderr, __VA_ARGS__ );  assert(A);}
//TODO The better option in general is use GOTO as then you can perform cleanup
//too

int
get_bit(
    unsigned char *x,
    int i
)
{
    return x[i / 8] & ( 1 << ( i % 8 ) );
}

int
set_bit(
    unsigned char *x,
    int i
)
{
    return x[i / 8] |= 1 << ( i % 8 );
}

inline int
clear_bit(
    int *x,
    int i
)
{
    return x[i / 8] &= ~( 1 << ( i % 8 ) );
}

int
copy_bits(
    unsigned char *dest,
    unsigned char *src,
    int dest_start_index,
    int src_start_index,
    int length
)
{

    for ( int i = 0; i < length; i++ )
    {
        int src_bit = GET_BIT( src, src_start_index + i );
        if ( src_bit )
        {
            SET_BIT( dest, dest_start_index + i );
        }
        else
        {
            CLEAR_BIT( dest, dest_start_index + i );
        }
    }
    return 0;
}


int
write_bits_to_file(
    FILE * fp,
    unsigned char *src,
    int length,
    int file_size
)
{
    // bring file to the position of the last valid byte and then read off each bit
    // since only the last byte is ever in question we can start from there
    unsigned char val = 0;
    int offset = 0;
    int copied_count = 0;
    int status;
    debug_print( "file size=%d, length=%d\n", file_size, length );
    status = fseek( fp, file_size / 8, SEEK_SET );
    assertc( status == 0,
             "Failed to seek file pointer to position to write to\n" );
    // cBYE(status);
    debug_print( "Starting position =%ld\n", ftell( fp ) );
    if ( file_size % 8 != 0 )
    {
        debug_print( "Position before getting an element=%ld\n", ftell( fp ) );
        val = fgetc( fp );
        debug_print( " Position after getting bit =%ld\n", ftell( fp ) );

        if ( !feof( fp )  && ftell(fp) != 0 )
        {
            int prev_locn = ftell(fp);
            status = fseek( fp, -1, SEEK_CUR );
            int new_locn = ftell(fp);
            assertc( prev_locn - new_locn == 1,
                     "Failed to seek pointer back to original position\n" );
            // cBYE(status);
        }
        debug_print( " Positionafter getting bit and stepping back =%ld\n",
                     ftell( fp ) );
        offset = file_size % 8;
        for ( int i = 0; i + offset < 8 && i < length; i++ )
        {
            copied_count++;
            int src_bit = GET_BIT( src, i );
            debug_print( "Setting src bit %d at bit position %d\n", src_bit,
                         file_size + i );
            if ( src_bit )
            {
                SET_BIT( &val, offset + i );
            }
            else
            {
                CLEAR_BIT( &val, offset + i );
            }
        }
        debug_print( "Position before putting the char back=%ld\n", ftell( fp ) );
        status = fputc( val, fp );
        assertc( status == val, "Value returned by fputc must match\n" );
        // cBYE(status);
        debug_print( "Position after putting the char back=%ld\n", ftell( fp ) );
        val = 0;
    }
    val = 0;
    debug_print( "My copied count is %d and length is %d\n", copied_count,
                 length );
    for ( int i = 0; i + copied_count < length; i++ )
    {
        int src_index = i + copied_count;
        if ( i % 8 == 0 && i != 0 )
        {
            status = fputc( val, fp );
            assertc( status == val, "Value returned by fputc must match\n" );
            //cBYE(status);
            val = 0;
        }
        int src_bit = GET_BIT( src, src_index );
        debug_print( "Setting src bit %d at bit position %ld\n", src_bit,
                     ftell( fp ) * 8 + i % 8 );
        if ( src_bit != 0 )
        {
            SET_BIT( &val, i % 8 );
        }
        else
        {
            CLEAR_BIT( &val, i % 8 );
        }
    }

    if ( copied_count < length )
    {
        status = fputc( val, fp );
        assertc( status == val, "Value returned by fputc must match\n" );
        //cBYE(status);
        val = 0;
    }
    return 0;
}

int
print_bits(
    char *file_name,
    int length
)
{
    int file_length = length;
    if ( file_name == NULL )
    {
        return -1;
    }
    FILE *fp = fopen( file_name, "rb" );
    if ( fp == NULL )
    {
        return -1;
    }
    if ( file_length == -1 )
    {
        int fd = open( file_name, O_RDONLY );
        struct stat filestat;
        int status = fstat( fd, &filestat );
        cBYE( status );
        file_length = filestat.st_size;
    }
    unsigned char byte;
    for ( int i = 0; i < file_length; i++ )
    {
        byte = fgetc( fp );
        for ( int j = 0; j < 8; j++ )
        {
            debug_print( "%d\n", GET_BIT( &byte, j ) );
        }
    }
    return 0;
}

//For internal use only . not tested properly
int
get_bits_from_array(
    unsigned char *input_arr,
    int *arr,
    int length
)
{
    unsigned char byte;
    for ( int i = 0; i < length; i++ )
    {
        arr[i] = GET_BIT( input_arr, i );
    }
    return 0;
}


//For internal use only do not use
int
get_bits_from_file(
    FILE * fp,
    int *arr,
    int length
)
{
    unsigned char byte;
    for ( int i = 0; i < length; i++ )
    {
        if ( i % 8 == 0 )
        {
            if ( feof( fp ) )
            {
                return -1;
            }
            byte = fgetc( fp );
        }
        arr[i] = GET_BIT( &byte, i % 8 );
    }
    return 0;
}

int
create_bit_file(
    char *path,
    int *arr,
    int length
)
{
    int arr_length = length / 8, status = 0;
    if ( length % 8 != 0 )
    {
        arr_length += 1;
    }
    FILE *fp = fopen( path, "wb+" );
    if ( fp == NULL )
    {
        return -1;
    }
    unsigned char vec[arr_length];
    for ( int i = 0; i < length; i++ )
    {
        if ( arr[i] == 0 )
        {
            CLEAR_BIT( vec, i );
        }
        else
        {
            SET_BIT( vec, i );
        }
    }
    status = write_bits_to_file( fp, vec, length, 0 );
    if ( status == -1 )
    {
        fclose( fp );
        return -1;
    }
    fclose( fp );
    return 0;
}


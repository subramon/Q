// INDRAJEET TODO FIX 
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
#ifdef TEST
#define PRINT_TEST 1
#else
#define PRINT_TEST 0
#endif
#define cBYE(status) \
    do {if ( (status) != 0 ){fprintf(stderr, "info: %s:%d:\n ", __FILE__, __LINE__); \
    return(status);}}while(0)
//#define cBYE(x) do { if ( (x) !=0) return (x);  } while(0)
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

#ifdef TEST


int
create_test_file(
    char *path
)
{
    // checked manually to be working
    FILE *fp = fopen( path, "wb+" );
    // if ( fp == NULL )
    // {
    //     debug_print( "Error in opening file for test read bits from file" );
    // }
    assertc(fp != NULL, "Error in opening file for test read bits from file" );
    unsigned char a = 255;    // all 1
    fputc( a, fp );
    a = 85;
    fputc( a, fp );
    fclose( fp );
    return 0;

}

void
test_read_bits_from_file(
)
{
    char *path = "./test_read.txt";
    if ( create_test_file( path ) )
    {
        debug_print( "Error creating test file" );
        return;
    }
    int arr[16];

    FILE *fp = fopen( path, "rb" );
    //debug_print( "Opening file for reading failed" );
    assertc(fp != NULL, "Opening file for reading failed");

    get_bits_from_file( fp, arr, 16 );
    for ( int i = 0; i < 16; i++ )
    {
        if ( i < 8 )
        {
            // debug_print( "READ for index %d should return %d, returned %d\n", i,
            //              1, arr[i] );
            assertc(arr[i] == 1, "READ for index %d should return %d, returned %d\n", i,
                         1, arr[i] );
        }
        else
        {
            // debug_print( "READ for index %d should return %d, returned %d\n", i,
            //              arr[i], ( i - 1 ) % 2 );
            assertc(arr[i] == (i - 1) % 2, "READ for index %d should return %d, returned %d\n", i,
                         arr[i], ( i - 1 ) % 2 );
        }
    }
}

void
test_long_write(
)
{
    unsigned int i = 0;
    const char *f_name = "test_long_write.txt";
    FILE *fp = fopen( f_name, "wb+" );
    int status = write_bits_to_file( fp, (unsigned char*)&i, 16, 0 );
    // if ( status != 0 )
    // {
    //     debug_print( "Error in writing more than one byte of zeros" );
    // }
    // else
    // {
    //     debug_print( "Succeeded in writing more than one byte of zeros" );
    // }
    assertc(status == 0, "Error in writing more than one byte of zeros" );
    fclose( fp );

}

void
test_write_bits_to_file(
)
{
    const char *f_name = "test_write.txt";
    unsigned char vec = 0;
    for ( int i = 0; i < 8 * sizeof( vec ); i++ )
    {
        if ( i % 3 == 0 )
        {
            SET_BIT( &vec, i );
        }
        else
        {
            CLEAR_BIT( &vec, i );
        }
    }
    FILE *fp = fopen( f_name, "wb+" );
    write_bits_to_file( fp, &vec, 1, 0 );
    write_bits_to_file( fp, &vec, 1, 1 );
    write_bits_to_file( fp, &vec, 4, 2 );
    write_bits_to_file( fp, &vec, 4, 3 );


    write_bits_to_file( fp, &vec, 4, 8 );
    write_bits_to_file( fp, &vec, 3, 4 );
    fseek( fp, 0, SEEK_SET );
    int ret_val = fgetc( fp );
    //debug_print( "WRITE to file should return %d, returned %d\n", 79, ret_val );
    assertc(ret_val = 79, "WRITE to file should return %d, returned %d\n", 79, ret_val);
    fflush(fp);
    fclose(fp);
    remove(f_name);
    fp = fopen(f_name, "wb+");
    fseek( fp, 0, SEEK_SET );
    vec = 1;
    write_bits_to_file( fp, &vec, 2, 0 );
    vec = 0;
    write_bits_to_file( fp, &vec, 1, 1 );
    vec = 1;
    write_bits_to_file( fp, &vec, 1, 2 );
    vec = 0;
    write_bits_to_file( fp, &vec, 1, 3 );
    vec = 1;
    write_bits_to_file( fp, &vec, 1, 4 );
    vec = 0;
    write_bits_to_file( fp, &vec, 1, 5 );
    vec = 1;
    write_bits_to_file( fp, &vec, 1, 6 );
    vec = 0;
    write_bits_to_file( fp, &vec, 1, 7 );
    vec = 0;
    write_bits_to_file( fp, &vec, 1, 8 );
    vec = 1;
    write_bits_to_file( fp, &vec, 1, 10 );
    fseek( fp, 0, SEEK_SET );
    int val = 0;
    
    val = fgetc(fp);
    // debug_print( "WRITE to file should return %d, returned %d\n", 85, val);
    assertc(val == 85, "WRITE to file should return %d, returned %d\n", 85, val);
    
    val = fgetc(fp);
    // debug_print( "WRITE to file should return %d, returned %d\n", 4, val);
    assertc(val == 4, "WRITE to file should return %d, returned %d\n", 4, val);
    fclose( fp );

}

//int get_bits_from_array(unsigned char* input_arr, int* arr, int length)
void
test_get_bits_from_array(
)
{
    int arr[32] = { 0 };
    unsigned char a = 31;
    get_bits_from_array( &a, arr, 8 );
    for ( int i = 0; i < 8; i++ )
    {
        if ( i <= 4 )
        {
            // debug_print( "ARRAY for index %d should return %d , returned %d\n", i, 1,
            //             arr[i] );
            assertc(arr[i] == 1, "ARRAY for index %d should return %d , returned %d\n", i, 1, arr[i]);
        }
        else
        {
            // debug_print( "ARRAY for index %d should return %d , returned %d\n", i, 0,
            //             arr[i] );
            assertc(arr[i] == 0, "ARRAY for index %d should return %d , returned %d\n", i, 0, arr[i]);
        }
    }
    a = 8;
    get_bits_from_array( &a, arr, 8 );
    for ( int i = 0; i < 8; i++ )
    {
        if ( i == 3 )
        {
            // debug_print( "ARRAY for index %d should return %d , returned %d\n", i, 1,
            //             arr[i] );
            assertc(arr[i] == 1, "ARRAY for index %d should return %d , returned %d\n", i, 1, arr[i]);
        }
        else
        {
            // debug_print( "ARRAY for index %d should return %d , returned %d\n", i, 0,
            //             arr[i] );
            assertc(arr[i] == 0, "ARRAY for index %d should return %d , returned %d\n", i, 0, arr[i]);
        }
    }


}

void
test_get_bit(
)
{
    unsigned char a = 7;
    int val;
    val = GET_BIT(&a, 3);
    // debug_print( "GETBIT should return %d , returned %d\n", 0, val);
    assertc(val == 0, "GETBIT should return %d , returned %d\n", 0, val);

    val = GET_BIT(&a, 2);
    // debug_print( "GETBIT should return %d , returned %d\n", 1, val);
    assertc(val == 1, "GETBIT should return %d , returned %d\n", 1, val);

    val = GET_BIT(&a, 1);
    // debug_print( "GETBIT should return %d , returned %d\n", 1, val);
    assertc(val == 1, "GETBIT should return %d , returned %d\n", 1, val);

    val = GET_BIT(&a, 0);
    // debug_print( "GETBIT should return %d , returned %d\n", 1, val);
    assertc(val == 1, "GETBIT should return %d , returned %d\n", 1, val);

    a = 8;
    val = GET_BIT(&a, 0);
    // debug_print( "GETBIT should return %d , returned %d\n", 0, val);
    assertc(val == 0, "GETBIT should return %d , returned %d\n", 0, val);

}

void
test_set_bit(
)
{
    unsigned char a = 0;
    int ret_val = 0;

    ret_val = SET_BIT(&a, 0);
    // debug_print( "SETBIT should return %d , returned %d\n", 1, ret_val);
    assertc(ret_val == 1, "SETBIT should return %d , returned %d\n", 1, ret_val);

    ret_val = SET_BIT(&a, 1);
    // debug_print( "SETBIT should return %d , returned %d\n", 3, ret_val);
    assertc(ret_val == 3, "SETBIT should return %d , returned %d\n", 3, ret_val);

    ret_val = SET_BIT(&a, 2);
    // debug_print( "SETBIT should return %d , returned %d\n", 7, ret_val);
    assertc(ret_val == 7, "SETBIT should return %d , returned %d\n", 7, ret_val);

    ret_val = SET_BIT(&a, 3);
    // debug_print( "SETBIT should return %d , returned %d\n", 15, ret_val);
    assertc(ret_val == 15, "SETBIT should return %d , returned %d\n", 15, ret_val);

    ret_val = SET_BIT(&a, 4);
    // debug_print( "SETBIT should return %d , returned %d\n", 31, ret_val);
    assertc(ret_val == 31, "SETBIT should return %d , returned %d\n", 31, ret_val);

    ret_val = SET_BIT(&a, 5);
    // debug_print( "SETBIT should return %d , returned %d\n", 63, ret_val);
    assertc(ret_val == 63, "SETBIT should return %d , returned %d\n", 63, ret_val);

    ret_val = SET_BIT(&a, 6);
    // debug_print( "SETBIT should return %d , returned %d\n", 127, ret_val);
    assertc(ret_val == 127, "SETBIT should return %d , returned %d\n", 127, ret_val);

    ret_val = SET_BIT(&a, 7);
    // debug_print( "SETBIT should return %d , returned %d\n", 255, ret_val);
    assertc(ret_val == 255, "SETBIT should return %d , returned %d\n", 255, ret_val);
}

void
test_clear_bit(
)
{
    unsigned char a = 255;
    int ret_val;

    ret_val = CLEAR_BIT( &a, 0 ) ;
    // debug_print( "CLEARBIT should return %d , returned %d\n", 254, ret_val);
    assertc(ret_val == 254, "CLEARBIT should return %d , returned %d\n", 254, ret_val);

    ret_val = CLEAR_BIT( &a, 1 );
    // debug_print( "CLEARBIT should return %d , returned %d\n", 252, ret_val);
    assertc(ret_val == 252, "CLEARBIT should return %d , returned %d\n", 252, ret_val);

    ret_val = CLEAR_BIT( &a, 2 );
    // debug_print( "CLEARBIT should return %d , returned %d\n", 248, ret_val );
    assertc(ret_val == 248, "CLEARBIT should return %d , returned %d\n", 248, ret_val );

    ret_val = CLEAR_BIT( &a, 3 );
    // debug_print( "CLEARBIT should return %d , returned %d\n", 240, ret_val);
    assertc(ret_val == 240, "CLEARBIT should return %d , returned %d\n", 240, ret_val);

    ret_val = CLEAR_BIT( &a, 4);
    // debug_print( "CLEARBIT should return %d , returned %d\n", 224, ret_val);
    assertc(ret_val == 224, "CLEARBIT should return %d , returned %d\n", 224, ret_val);

    ret_val = CLEAR_BIT( &a, 5);
    // debug_print( "CLEARBIT should return %d , returned %d\n", 192, ret_val);
    assertc(ret_val == 192, "CLEARBIT should return %d , returned %d\n", 192, ret_val);

    ret_val = CLEAR_BIT( &a, 6 );
    // debug_print( "CLEARBIT should return %d , returned %d\n", 128, ret_val);
    assertc(ret_val == 128, "CLEARBIT should return %d , returned %d\n", 128, ret_val);

    ret_val = CLEAR_BIT( &a, 7 );
    // debug_print( "CLEARBIT should return %d , returned %d\n", 0, ret_val );
    assertc(ret_val == 0, "CLEARBIT should return %d , returned %d\n", 0, ret_val );
}

int
main(
)
{
    const char *f_name = "test_bits.txt";
    unsigned char vec[10] = { 0 };
    for ( int i = 0; i < 8 * sizeof( vec ); i++ )
    {
        if ( i % 3 == 0 )
        {
            SET_BIT( vec, i );
        }
        else
        {
            CLEAR_BIT( vec, i );
        }
    }
    FILE *fp = fopen( f_name, "wb+" );
    write_bits_to_file( fp, vec, 8 * sizeof( vec ), 0 );
    //fflush(fp);
    write_bits_to_file( fp, vec, 10, 0 );
    write_bits_to_file( fp, vec, 5, 0 );
    write_bits_to_file( fp, vec, 1, 10 );
    write_bits_to_file( fp, vec, 1, 11 );
    fclose( fp );
    fp = fopen( f_name, "rb" );
    struct stat filestat;
    int fd = open( f_name, O_RDONLY );
    int status = fstat( fd, &filestat );
    cBYE( status );
    int len = filestat.st_size;
    unsigned char byte;
    for ( int i = 0; i < len; i++ )
    {
        byte = fgetc( fp );
        for ( int j = 0; j < 8; j++ )
        {
            debug_print( "%d\n", GET_BIT( &byte, j ) );
        }
    }

    test_get_bit(  );
    test_set_bit(  );
    test_clear_bit(  );
    test_get_bits_from_array(  );
    test_read_bits_from_file(  );
    test_write_bits_to_file(  );
    test_long_write(  );
}

#endif

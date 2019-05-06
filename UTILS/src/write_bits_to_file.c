#include "q_incs.h"
#include "_write_bits_to_file.h"

#define PRINT_TEST 0
#define debug_print(...) \
    do { if (PRINT_TEST)  fprintf(stderr, __VA_ARGS__);} while (0)
//#define cBYE(i) (i) < 1 && return -1
#define assertc(A, ...) if((A) != true ){fprintf(stderr, "info: %s:%d:\t", __FILE__, __LINE__); fprintf(stderr, __VA_ARGS__ );  assert(A);}
//START_FUNC_DECL
int
write_bits_to_file(
    FILE * fp,
    unsigned char *src,
    int length,
    int file_size
)
//STOP_FUNC_DECL
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
  // Now lets pad to the remaining 64 bits boundary
  int seek_pos = file_size + length;

  if (seek_pos % 64 != 0) {
      seek_pos = seek_pos + ( 64 - (seek_pos % 64) );
     // now convert the seek pos from bits to bytes
     seek_pos = seek_pos / 8;
     status = fseek( fp, seek_pos - 1, SEEK_SET);
     fputc('\0', fp);
  }  
    return 0;
}

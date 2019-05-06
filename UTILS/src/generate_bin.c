#include <stdio.h>
#include <stdint.h>
#include <string.h>
#include <stdlib.h>
//START_INCLUDES
#include <limits.h>
#include <float.h>
//STOP_INCLUDES
#include "q_macros.h"
#include "_set_bit_u64.h"
#include "_generate_bin.h"
#include "_get_time_usec.h"

/*

Convention:-

If gen_type = "linear" then generated_values = 10, 20, 30 ... num_values * 10

if gen_type = "seq" then generated_values = ( i * 10 ) % max_value_of_qtype

Currently not supported:
if gen_type = "const" then generated_values = const value

*/

//START_FUNC_DECL
int
generate_bin(
    int num_values,
    const char* fldtype,
    const char* outfile,
    const char* gen_type
    )
//STOP_FUNC_DECL
{
    int status = 0;
    FILE *ofp = NULL;

    if ( *outfile == '\0' ) { go_BYE(-1); }
    if ( *fldtype == '\0' ) { go_BYE(-1); }
    if ( num_values < 1 ) { go_BYE(-1); }
    if ( strcmp( fldtype, "B1" ) != 0){ 
        if ( ( strcmp( gen_type, "linear" ) == 0 ) || 
        ( strcmp( gen_type, "seq" ) == 0 ) || 
        ( strcmp( gen_type, "const" ) == 0 )) {
	    // Everything is ok
        }
        else {
	     printf("Please provide proper gen_type, available values : { 'seq', 'linear', 'const' }\n");
	     go_BYE(-1);
        }
    }
    else {
    // currently for B1 gen_type is not supported
    }

    qtype_type qtype = undef_qtype;
    ofp = fopen(outfile, "wb");
    return_if_fopen_failed(ofp, outfile, "wb");

    if ( strcmp( fldtype, "B1" ) == 0 ) {
        qtype = B1;
    }
    else if ( strcmp( fldtype, "I1" ) == 0 ) {
        qtype = I1;
    }
    else if ( strcmp( fldtype, "I2" ) == 0 ) {
        qtype = I2;
    }
    else if ( strcmp( fldtype, "I4" ) == 0 ) {
        qtype = I4;
    }
    else if ( strcmp( fldtype, "I8" ) == 0 ) {
        qtype = I8;
    }
    else if ( strcmp( fldtype, "F4" ) == 0 ) {
        qtype = F4;
    }
    else if ( strcmp( fldtype, "F8" ) == 0 ) {
        qtype = F8;
    }
    else {
        go_BYE(-1);
    }
    if ( qtype == undef_qtype ) { go_BYE(-1); }
    int8_t tempI1;
    int16_t tempI2;
    int32_t tempI4;
    int64_t tempI8;
    float tempF4;
    double tempF8;
    uint64_t temp_B1 = 0;
    int8_t bit_idx;
    uint8_t bit_val = 0;
    for ( int64_t i = 1; i <= num_values; i++ ) {
        uint64_t val = i * 10;
        switch ( qtype ) {
            case B1 :
		bit_idx = i % 64;
		if ((i % 2) == 0) {
		    bit_val = 0;
		} 
		else {
		    bit_val = 1;
		}
		//temp_B1 |= ((uint64_t)bit_val << bit_idx);
		set_bit_u64(&temp_B1, bit_idx, bit_val);
          	
          	if ( bit_idx == 0 ) {
         	    fwrite(&temp_B1, 1, sizeof(uint64_t), ofp);
        	    temp_B1 = 0;		
		}	
                break;
            case I1 :
                if ( strcmp( gen_type, "seq" ) == 0 ) {
                    val %= CHAR_MAX;
                }
                tempI1 = (int8_t) val;
                fwrite(&tempI1, 1, sizeof(int8_t), ofp);
                break;
            case I2 :
                if ( strcmp( gen_type, "seq" ) == 0 ) {
                    val %= SHRT_MAX;
                }
                tempI2 = (int16_t) val;
                fwrite(&tempI2, 1, sizeof(int16_t), ofp);
                break;
            case I4 :
                if ( strcmp( gen_type, "seq" ) == 0 ) {
                    val %= INT_MAX;
                }
                tempI4 = (int32_t) val;
                fwrite(&tempI4, 1, sizeof(int32_t), ofp);
                break;
            case I8 :
                if ( strcmp( gen_type, "seq" ) == 0 ) {
                    val %= LONG_MAX;
                }
                tempI8 = (int64_t) val;
                fwrite(&tempI8, 1, sizeof(int64_t), ofp);
                break;
            case F4 :
                if ( strcmp( gen_type, "seq" ) == 0 ) {
                    //val %= FLT_MAX;
                }
                tempF4 = (float) val;
                fwrite(&tempF4, 1, sizeof(float), ofp);
                break;
            case F8 :
                if ( strcmp( gen_type, "seq" ) == 0 ) {
                    //val %= DBL_MAX;
                }
                tempF8 = (double) val;
                fwrite(&tempF8, 1, sizeof(double), ofp);
                break;
            default :
                go_BYE(-1);
                break;
        }
    }
//flushing remaining values if any of B1 qtype into the bin file
if ( qtype == B1 ) {
   if ((num_values % 64) != 0) {
       fwrite(&temp_B1, 1, sizeof(uint64_t), ofp);
   } 
}
BYE:
  if ( *outfile != '\0' ) {
    fclose_if_non_null(ofp);
  }
  return status ;
}

int main(
    int argc,
    char **argv
    )
{
    int status = 0;
    if ( argc < 4 ) {
        printf("Please provide proper argument\nUsage: <executable> num_values fldtype outfile gen_type");
        cBYE(-1);
    }
    int num_values = atoi(argv[1]);
    char *fldtype = argv[2];
    char *outfile = argv[3];
    char *gen_type = argv[4];

    status = generate_bin(num_values, fldtype, outfile, gen_type); cBYE(status);
    printf("Generate bin status is %d\n", status);
BYE:
    return status;
}

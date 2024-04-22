#ifndef __QTYPE_ENUMS_H
#define __QTYPE_ENUMS_H
typedef enum {
  Q0, // mixed  must be first one 

  B1, // boolean as a bit
  BL, // boolean as a bool

  I1,
  I2,
  I4,
  I8,
  I16,

  F2,
  F4,
  F8,

  UI1,
  UI2,
  UI4,
  UI8,
  UI16,

  SC,  // constant length strings
  SV,  // variable length strings
  TM,  // time struct  tm_t
  TM1, // time struct  tm_t

  HL, // TODO: This is relic of holiday bitmask from RBC. to be deleted
  NUM_QTYPES // must be last one 
} qtype_t;
#endif // __QTYPE_ENUMS_H

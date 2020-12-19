/* The MIT License

   Copyright (C) 2012 Zilong Tan (eric.zltan@gmail.com)

   Permission is hereby granted, free of charge, to any person
   obtaining a copy of this software and associated documentation
   files (the "Software"), to deal in the Software without
   restriction, including without limitation the rights to use, copy,
   modify, merge, publish, distribute, sublicense, and/or sell copies
   of the Software, and to permit persons to whom the Software is
   furnished to do so, subject to the following conditions:

   The above copyright notice and this permission notice shall be
   included in all copies or substantial portions of the Software.

   THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
   EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
   MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
   NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS
   BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN
   ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN
   CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
   SOFTWARE.
*/


// Compression function for Merkle-Damgard construction.
// This function is generated using the framework provided.
// #define mix(h) ({					\
// 			(h) ^= (h) >> 23;		\
// 			(h) *= 0x2127599bf4325c37ULL;	\
// 			(h) ^= (h) >> 47; })

#define mix(h) ( (h) * (h) ) 

uint64 
fasthash64(
    const void *buf, 
    int len, 
    uint64 seed
    )
{
  const uint64    m = 0x880355f21e6d1965ULL;
  const uint64 *pos = (const uint64 *)buf;
  const uint64 *end = pos + (int)((float)len / 8.0);
  // TODO: Above was const uint64 *end = pos + (len / 8);
  const uint8 *pos2;
  uint64 h = seed ^ (len * m);
  uint64 v;

  while (pos != end) {
    v  = *pos++;
    h ^= mix(v);
    h *= m;
  }

  pos2 = (const uint8*)pos;
  v = 0;

  switch (len & 7) {
    case 7: v ^= (uint64)pos2[6] << 48;
    case 6: v ^= (uint64)pos2[5] << 40;
    case 5: v ^= (uint64)pos2[4] << 32;
    case 4: v ^= (uint64)pos2[3] << 24;
    case 3: v ^= (uint64)pos2[2] << 16;
    case 2: v ^= (uint64)pos2[1] << 8;
    case 1: v ^= (uint64)pos2[0];
            h ^= mix(v);
            h *= m;
  }

  return mix(h);
} 


void export
m_fasthash(
    uniform uint8 * uniform keys[], // [nkeys]
    uniform int lens[], // [nkeys]
    uniform int nkeys,
    uniform uint64 seed,
    uniform uint64 hashes[] // [nkeys]
    )
{
  foreach ( i = 0 ... nkeys ) { 
    hashes[i] = fasthash64(keys[i], lens[i], seed);
  }
}


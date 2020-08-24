#define N 1 
export void str_in_set_ispc(
    uniform uint64 xsin,  // scalar input 
    uniform uint64 vin[], // vector or known values 
    uniform bool rslt[] // whether sin exists in vin[]
    )
{
  varying bool lisin = false;
  foreach ( index = 0 ... N ) {
    lisin = or(lisin, (vin[index] == xsin));
  }
  rslt[0] = any(lisin);
}

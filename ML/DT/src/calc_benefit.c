
int
calc_benefit(
    int32_t n_P_L,
    int32_t n_N_L,
    int32_t n_P,
    int32_t n_N,
    float *ptr_benefit
    )
{
  int status = 0;
  int32_t n_P_R = n_P - n_P_L;
  int32_t n_N_R = n_P - n_N_L;
  int32_t n_L = n_P_L + n_N_L;
  int32_t n_R = n_P_R + n_N_R;

  int32_t n_P = n_P_R + n_P_L;
  int32_t n_N = n_N_R + n_N_L;




  

BYE:
  return status;
}

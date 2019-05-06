    switch ( fldtype ) { 
      case I1 : 
        f_to_s_sum_I1((int8_t  *)X, nR, &valI8); 
        sprintf(str_rslt, "%" PRId64, valI8); 
        break;
      case I2 : 
        f_to_s_sum_I2((int16_t *)X, nR, &valI8); 
        sprintf(str_rslt, "%" PRId64, valI8); 
        break;
      case I4 : 
        f_to_s_sum_I4((int32_t *)X, nR, &valI8); 
        sprintf(str_rslt, "%" PRId64, valI8); 
        break;
      case I8 : 
        f_to_s_sum_I8((int64_t *)X, nR, &valI8); 
        sprintf(str_rslt, "%" PRId64, valI8); 
        break;
      case F4 : 
        f_to_s_sum_F4((float   *)X, nR, &valF8); 
        sprintf(str_rslt, "%lf", valF8); 
        break;
      case F8 : 
        f_to_s_sum_F8((double  *)X, nR, &valF8); 
        sprintf(str_rslt, "%lf", valF8); 
        break;
      default : go_BYE(-1); break;
    }

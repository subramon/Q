  if ( (x->bmask & ((uint64_t)1 << 0)) != 0 ) {
    float ftmp = F2_to_F4(x->intercept);  \
    sprintf(tmp, "'intercept' : %f ", ftmp);  \
    status = cat_to_buf(&buf, &bufsz, &buflen, tmp, 0);  \
    mcr_pr_comma();
  }

  /*-------------------------------------------------*/
  if ( (x->bmask & ((uint64_t)1 << 1)) != 0 ) {
    float ftmp = F2_to_F4(x->goodfriday);  \
    sprintf(tmp, "'goodfriday' : %f ", ftmp);  \
    status = cat_to_buf(&buf, &bufsz, &buflen, tmp, 0);  \
    mcr_pr_comma();
  }

  /*-------------------------------------------------*/
  if ( (x->bmask & ((uint64_t)1 << 2)) != 0 ) {
    float ftmp = F2_to_F4(x->easter);  \
    sprintf(tmp, "'easter' : %f ", ftmp);  \
    status = cat_to_buf(&buf, &bufsz, &buflen, tmp, 0);  \
    mcr_pr_comma();
  }

  /*-------------------------------------------------*/
  if ( (x->bmask & ((uint64_t)1 << 3)) != 0 ) {
    float ftmp = F2_to_F4(x->mardigras);  \
    sprintf(tmp, "'mardigras' : %f ", ftmp);  \
    status = cat_to_buf(&buf, &bufsz, &buflen, tmp, 0);  \
    mcr_pr_comma();
  }

  /*-------------------------------------------------*/
  if ( (x->bmask & ((uint64_t)1 << 4)) != 0 ) {
    float ftmp = F2_to_F4(x->memorialday);  \
    sprintf(tmp, "'memorialday' : %f ", ftmp);  \
    status = cat_to_buf(&buf, &bufsz, &buflen, tmp, 0);  \
    mcr_pr_comma();
  }

  /*-------------------------------------------------*/
  if ( (x->bmask & ((uint64_t)1 << 5)) != 0 ) {
    float ftmp = F2_to_F4(x->mothersday_minus);  \
    sprintf(tmp, "'mothersday_minus' : %f ", ftmp);  \
    status = cat_to_buf(&buf, &bufsz, &buflen, tmp, 0);  \
    mcr_pr_comma();
  }

  /*-------------------------------------------------*/
  if ( (x->bmask & ((uint64_t)1 << 6)) != 0 ) {
    float ftmp = F2_to_F4(x->mothersday);  \
    sprintf(tmp, "'mothersday' : %f ", ftmp);  \
    status = cat_to_buf(&buf, &bufsz, &buflen, tmp, 0);  \
    mcr_pr_comma();
  }

  /*-------------------------------------------------*/
  if ( (x->bmask & ((uint64_t)1 << 7)) != 0 ) {
    float ftmp = F2_to_F4(x->presidentsday);  \
    sprintf(tmp, "'presidentsday' : %f ", ftmp);  \
    status = cat_to_buf(&buf, &bufsz, &buflen, tmp, 0);  \
    mcr_pr_comma();
  }

  /*-------------------------------------------------*/
  if ( (x->bmask & ((uint64_t)1 << 8)) != 0 ) {
    float ftmp = F2_to_F4(x->superbowl_minus);  \
    sprintf(tmp, "'superbowl_minus' : %f ", ftmp);  \
    status = cat_to_buf(&buf, &bufsz, &buflen, tmp, 0);  \
    mcr_pr_comma();
  }

  /*-------------------------------------------------*/
  if ( (x->bmask & ((uint64_t)1 << 9)) != 0 ) {
    float ftmp = F2_to_F4(x->superbowl);  \
    sprintf(tmp, "'superbowl' : %f ", ftmp);  \
    status = cat_to_buf(&buf, &bufsz, &buflen, tmp, 0);  \
    mcr_pr_comma();
  }

  /*-------------------------------------------------*/
  if ( (x->bmask & ((uint64_t)1 << 10)) != 0 ) {
    float ftmp = F2_to_F4(x->thanksgiving);  \
    sprintf(tmp, "'thanksgiving' : %f ", ftmp);  \
    status = cat_to_buf(&buf, &bufsz, &buflen, tmp, 0);  \
    mcr_pr_comma();
  }

  /*-------------------------------------------------*/
  if ( (x->bmask & ((uint64_t)1 << 11)) != 0 ) {
    float ftmp = F2_to_F4(x->valentines);  \
    sprintf(tmp, "'valentines' : %f ", ftmp);  \
    status = cat_to_buf(&buf, &bufsz, &buflen, tmp, 0);  \
    mcr_pr_comma();
  }

  /*-------------------------------------------------*/
  if ( (x->bmask & ((uint64_t)1 << 12)) != 0 ) {
    float ftmp = F2_to_F4(x->stpatricks);  \
    sprintf(tmp, "'stpatricks' : %f ", ftmp);  \
    status = cat_to_buf(&buf, &bufsz, &buflen, tmp, 0);  \
    mcr_pr_comma();
  }

  /*-------------------------------------------------*/
  if ( (x->bmask & ((uint64_t)1 << 13)) != 0 ) {
    float ftmp = F2_to_F4(x->cincodemayo);  \
    sprintf(tmp, "'cincodemayo' : %f ", ftmp);  \
    status = cat_to_buf(&buf, &bufsz, &buflen, tmp, 0);  \
    mcr_pr_comma();
  }

  /*-------------------------------------------------*/
  if ( (x->bmask & ((uint64_t)1 << 14)) != 0 ) {
    float ftmp = F2_to_F4(x->julyfourth);  \
    sprintf(tmp, "'julyfourth' : %f ", ftmp);  \
    status = cat_to_buf(&buf, &bufsz, &buflen, tmp, 0);  \
    mcr_pr_comma();
  }

  /*-------------------------------------------------*/
  if ( (x->bmask & ((uint64_t)1 << 15)) != 0 ) {
    float ftmp = F2_to_F4(x->halloween);  \
    sprintf(tmp, "'halloween' : %f ", ftmp);  \
    status = cat_to_buf(&buf, &bufsz, &buflen, tmp, 0);  \
    mcr_pr_comma();
  }

  /*-------------------------------------------------*/
  if ( (x->bmask & ((uint64_t)1 << 16)) != 0 ) {
    float ftmp = F2_to_F4(x->christmas_minus);  \
    sprintf(tmp, "'christmas_minus' : %f ", ftmp);  \
    status = cat_to_buf(&buf, &bufsz, &buflen, tmp, 0);  \
    mcr_pr_comma();
  }

  /*-------------------------------------------------*/
  if ( (x->bmask & ((uint64_t)1 << 17)) != 0 ) {
    float ftmp = F2_to_F4(x->christmas);  \
    sprintf(tmp, "'christmas' : %f ", ftmp);  \
    status = cat_to_buf(&buf, &bufsz, &buflen, tmp, 0);  \
    mcr_pr_comma();
  }

  /*-------------------------------------------------*/
  if ( (x->bmask & ((uint64_t)1 << 18)) != 0 ) {
    float ftmp = F2_to_F4(x->newyearsday);  \
    sprintf(tmp, "'newyearsday' : %f ", ftmp);  \
    status = cat_to_buf(&buf, &bufsz, &buflen, tmp, 0);  \
    mcr_pr_comma();
  }

  /*-------------------------------------------------*/
  if ( (x->bmask & ((uint64_t)1 << 19)) != 0 ) {
    float ftmp = F2_to_F4(x->t_o_y);  \
    sprintf(tmp, "'t_o_y' : %f ", ftmp);  \
    status = cat_to_buf(&buf, &bufsz, &buflen, tmp, 0);  \
    mcr_pr_comma();
  }

  /*-------------------------------------------------*/
  if ( (x->bmask & ((uint64_t)1 << 20)) != 0 ) {
    float ftmp = F2_to_F4(x->n_week);  \
    sprintf(tmp, "'n_week' : %f ", ftmp);  \
    status = cat_to_buf(&buf, &bufsz, &buflen, tmp, 0);  \
    mcr_pr_comma();
  }

  /*-------------------------------------------------*/
  if ( (x->bmask & ((uint64_t)1 << 21)) != 0 ) {
    float ftmp = F2_to_F4(x->time_band);  \
    sprintf(tmp, "'time_band' : %f ", ftmp);  \
    status = cat_to_buf(&buf, &bufsz, &buflen, tmp, 0);  \
    mcr_pr_comma();
  }

  /*-------------------------------------------------*/
  if ( (x->bmask & ((uint64_t)1 << 22)) != 0 ) {
    float ftmp = F2_to_F4(x->btcs_value);  \
    sprintf(tmp, "'btcs_value' : %f ", ftmp);  \
    status = cat_to_buf(&buf, &bufsz, &buflen, tmp, 0);  \
    mcr_pr_comma();
  }

  /*-------------------------------------------------*/
  if ( (x->bmask & ((uint64_t)1 << 23)) != 0 ) {
    float ftmp = F2_to_F4(x->sls_unit_q_L1);  \
    sprintf(tmp, "'sls_unit_q_L1' : %f ", ftmp);  \
    status = cat_to_buf(&buf, &bufsz, &buflen, tmp, 0);  \
    mcr_pr_comma();
  }

  /*-------------------------------------------------*/
  if ( (x->bmask & ((uint64_t)1 << 24)) != 0 ) {
    float ftmp = F2_to_F4(x->sls_unit_q_L2);  \
    sprintf(tmp, "'sls_unit_q_L2' : %f ", ftmp);  \
    status = cat_to_buf(&buf, &bufsz, &buflen, tmp, 0);  \
    mcr_pr_comma();
  }

  /*-------------------------------------------------*/
  if ( (x->bmask & ((uint64_t)1 << 25)) != 0 ) {
    float ftmp = F2_to_F4(x->sls_unit_q_L3);  \
    sprintf(tmp, "'sls_unit_q_L3' : %f ", ftmp);  \
    status = cat_to_buf(&buf, &bufsz, &buflen, tmp, 0);  \
    mcr_pr_comma();
  }

  /*-------------------------------------------------*/
  if ( (x->bmask & ((uint64_t)1 << 26)) != 0 ) {
    float ftmp = F2_to_F4(x->sls_unit_q_L4);  \
    sprintf(tmp, "'sls_unit_q_L4' : %f ", ftmp);  \
    status = cat_to_buf(&buf, &bufsz, &buflen, tmp, 0);  \
    mcr_pr_comma();
  }

  /*-------------------------------------------------*/
  if ( (x->bmask & ((uint64_t)1 << 27)) != 0 ) {
    float ftmp = F2_to_F4(x->sls_unit_q_L5);  \
    sprintf(tmp, "'sls_unit_q_L5' : %f ", ftmp);  \
    status = cat_to_buf(&buf, &bufsz, &buflen, tmp, 0);  \
    mcr_pr_comma();
  }

  /*-------------------------------------------------*/
  if ( (x->bmask & ((uint64_t)1 << 28)) != 0 ) {
    float ftmp = F2_to_F4(x->baseprice);  \
    sprintf(tmp, "'baseprice' : %f ", ftmp);  \
    status = cat_to_buf(&buf, &bufsz, &buflen, tmp, 0);  \
    mcr_pr_comma();
  }

  /*-------------------------------------------------*/
  if ( (x->bmask & ((uint64_t)1 << 29)) != 0 ) {
    float ftmp = F2_to_F4(x->offerprice);  \
    sprintf(tmp, "'offerprice' : %f ", ftmp);  \
    status = cat_to_buf(&buf, &bufsz, &buflen, tmp, 0);  \
    mcr_pr_comma();
  }

  /*-------------------------------------------------*/
  if ( (x->bmask & ((uint64_t)1 << 30)) != 0 ) {
    float ftmp = F2_to_F4(x->baseprice_lift);  \
    sprintf(tmp, "'baseprice_lift' : %f ", ftmp);  \
    status = cat_to_buf(&buf, &bufsz, &buflen, tmp, 0);  \
    mcr_pr_comma();
  }

  /*-------------------------------------------------*/
  if ( (x->bmask & ((uint64_t)1 << 31)) != 0 ) {
    float ftmp = F2_to_F4(x->promo_lift);  \
    sprintf(tmp, "'promo_lift' : %f ", ftmp);  \
    status = cat_to_buf(&buf, &bufsz, &buflen, tmp, 0);  \
    mcr_pr_comma();
  }

  /*-------------------------------------------------*/

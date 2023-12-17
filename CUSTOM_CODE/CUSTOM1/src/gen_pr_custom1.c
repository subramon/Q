  if ( (x->bmask & ((uint64_t)1 << 0)) != 0 ) {
    sprintf(tmp, "\"intercept\" : %f ", x->intercept);
    status = cat_to_buf(&buf, &bufsz, &buflen, tmp, 0);  \
    mcr_pr_comma();
  }

  /*-------------------------------------------------*/
  if ( (x->bmask & ((uint64_t)1 << 1)) != 0 ) {
    sprintf(tmp, "\"goodfriday\" : %f ", x->goodfriday);
    status = cat_to_buf(&buf, &bufsz, &buflen, tmp, 0);  \
    mcr_pr_comma();
  }

  /*-------------------------------------------------*/
  if ( (x->bmask & ((uint64_t)1 << 2)) != 0 ) {
    sprintf(tmp, "\"easter\" : %f ", x->easter);
    status = cat_to_buf(&buf, &bufsz, &buflen, tmp, 0);  \
    mcr_pr_comma();
  }

  /*-------------------------------------------------*/
  if ( (x->bmask & ((uint64_t)1 << 3)) != 0 ) {
    sprintf(tmp, "\"mardigras\" : %f ", x->mardigras);
    status = cat_to_buf(&buf, &bufsz, &buflen, tmp, 0);  \
    mcr_pr_comma();
  }

  /*-------------------------------------------------*/
  if ( (x->bmask & ((uint64_t)1 << 4)) != 0 ) {
    sprintf(tmp, "\"memorialday\" : %f ", x->memorialday);
    status = cat_to_buf(&buf, &bufsz, &buflen, tmp, 0);  \
    mcr_pr_comma();
  }

  /*-------------------------------------------------*/
  if ( (x->bmask & ((uint64_t)1 << 5)) != 0 ) {
    sprintf(tmp, "\"mothersday_minus\" : %f ", x->mothersday_minus);
    status = cat_to_buf(&buf, &bufsz, &buflen, tmp, 0);  \
    mcr_pr_comma();
  }

  /*-------------------------------------------------*/
  if ( (x->bmask & ((uint64_t)1 << 6)) != 0 ) {
    sprintf(tmp, "\"mothersday\" : %f ", x->mothersday);
    status = cat_to_buf(&buf, &bufsz, &buflen, tmp, 0);  \
    mcr_pr_comma();
  }

  /*-------------------------------------------------*/
  if ( (x->bmask & ((uint64_t)1 << 7)) != 0 ) {
    sprintf(tmp, "\"presidentsday\" : %f ", x->presidentsday);
    status = cat_to_buf(&buf, &bufsz, &buflen, tmp, 0);  \
    mcr_pr_comma();
  }

  /*-------------------------------------------------*/
  if ( (x->bmask & ((uint64_t)1 << 8)) != 0 ) {
    sprintf(tmp, "\"superbowl_minus\" : %f ", x->superbowl_minus);
    status = cat_to_buf(&buf, &bufsz, &buflen, tmp, 0);  \
    mcr_pr_comma();
  }

  /*-------------------------------------------------*/
  if ( (x->bmask & ((uint64_t)1 << 9)) != 0 ) {
    sprintf(tmp, "\"superbowl\" : %f ", x->superbowl);
    status = cat_to_buf(&buf, &bufsz, &buflen, tmp, 0);  \
    mcr_pr_comma();
  }

  /*-------------------------------------------------*/
  if ( (x->bmask & ((uint64_t)1 << 10)) != 0 ) {
    sprintf(tmp, "\"thanksgiving\" : %f ", x->thanksgiving);
    status = cat_to_buf(&buf, &bufsz, &buflen, tmp, 0);  \
    mcr_pr_comma();
  }

  /*-------------------------------------------------*/
  if ( (x->bmask & ((uint64_t)1 << 11)) != 0 ) {
    sprintf(tmp, "\"valentines\" : %f ", x->valentines);
    status = cat_to_buf(&buf, &bufsz, &buflen, tmp, 0);  \
    mcr_pr_comma();
  }

  /*-------------------------------------------------*/
  if ( (x->bmask & ((uint64_t)1 << 12)) != 0 ) {
    sprintf(tmp, "\"stpatricks\" : %f ", x->stpatricks);
    status = cat_to_buf(&buf, &bufsz, &buflen, tmp, 0);  \
    mcr_pr_comma();
  }

  /*-------------------------------------------------*/
  if ( (x->bmask & ((uint64_t)1 << 13)) != 0 ) {
    sprintf(tmp, "\"cincodemayo\" : %f ", x->cincodemayo);
    status = cat_to_buf(&buf, &bufsz, &buflen, tmp, 0);  \
    mcr_pr_comma();
  }

  /*-------------------------------------------------*/
  if ( (x->bmask & ((uint64_t)1 << 14)) != 0 ) {
    sprintf(tmp, "\"julyfourth\" : %f ", x->julyfourth);
    status = cat_to_buf(&buf, &bufsz, &buflen, tmp, 0);  \
    mcr_pr_comma();
  }

  /*-------------------------------------------------*/
  if ( (x->bmask & ((uint64_t)1 << 15)) != 0 ) {
    sprintf(tmp, "\"halloween\" : %f ", x->halloween);
    status = cat_to_buf(&buf, &bufsz, &buflen, tmp, 0);  \
    mcr_pr_comma();
  }

  /*-------------------------------------------------*/
  if ( (x->bmask & ((uint64_t)1 << 16)) != 0 ) {
    sprintf(tmp, "\"christmas_minus\" : %f ", x->christmas_minus);
    status = cat_to_buf(&buf, &bufsz, &buflen, tmp, 0);  \
    mcr_pr_comma();
  }

  /*-------------------------------------------------*/
  if ( (x->bmask & ((uint64_t)1 << 17)) != 0 ) {
    sprintf(tmp, "\"christmas\" : %f ", x->christmas);
    status = cat_to_buf(&buf, &bufsz, &buflen, tmp, 0);  \
    mcr_pr_comma();
  }

  /*-------------------------------------------------*/
  if ( (x->bmask & ((uint64_t)1 << 18)) != 0 ) {
    sprintf(tmp, "\"newyearsday\" : %f ", x->newyearsday);
    status = cat_to_buf(&buf, &bufsz, &buflen, tmp, 0);  \
    mcr_pr_comma();
  }

  /*-------------------------------------------------*/
  if ( (x->bmask & ((uint64_t)1 << 19)) != 0 ) {
    sprintf(tmp, "\"t_o_y\" : %f ", x->t_o_y);
    status = cat_to_buf(&buf, &bufsz, &buflen, tmp, 0);  \
    mcr_pr_comma();
  }

  /*-------------------------------------------------*/
  if ( (x->bmask & ((uint64_t)1 << 20)) != 0 ) {
    sprintf(tmp, "\"n_week\" : %f ", x->n_week);
    status = cat_to_buf(&buf, &bufsz, &buflen, tmp, 0);  \
    mcr_pr_comma();
  }

  /*-------------------------------------------------*/
  if ( (x->bmask & ((uint64_t)1 << 21)) != 0 ) {
    sprintf(tmp, "\"time_band\" : %f ", x->time_band);
    status = cat_to_buf(&buf, &bufsz, &buflen, tmp, 0);  \
    mcr_pr_comma();
  }

  /*-------------------------------------------------*/
  if ( (x->bmask & ((uint64_t)1 << 22)) != 0 ) {
    sprintf(tmp, "\"btcs_value\" : %f ", x->btcs_value);
    status = cat_to_buf(&buf, &bufsz, &buflen, tmp, 0);  \
    mcr_pr_comma();
  }

  /*-------------------------------------------------*/
  if ( (x->bmask & ((uint64_t)1 << 23)) != 0 ) {
    sprintf(tmp, "\"sls_unit_q_L1\" : %f ", x->sls_unit_q_L1);
    status = cat_to_buf(&buf, &bufsz, &buflen, tmp, 0);  \
    mcr_pr_comma();
  }

  /*-------------------------------------------------*/
  if ( (x->bmask & ((uint64_t)1 << 24)) != 0 ) {
    sprintf(tmp, "\"sls_unit_q_L2\" : %f ", x->sls_unit_q_L2);
    status = cat_to_buf(&buf, &bufsz, &buflen, tmp, 0);  \
    mcr_pr_comma();
  }

  /*-------------------------------------------------*/
  if ( (x->bmask & ((uint64_t)1 << 25)) != 0 ) {
    sprintf(tmp, "\"sls_unit_q_L3\" : %f ", x->sls_unit_q_L3);
    status = cat_to_buf(&buf, &bufsz, &buflen, tmp, 0);  \
    mcr_pr_comma();
  }

  /*-------------------------------------------------*/
  if ( (x->bmask & ((uint64_t)1 << 26)) != 0 ) {
    sprintf(tmp, "\"sls_unit_q_L4\" : %f ", x->sls_unit_q_L4);
    status = cat_to_buf(&buf, &bufsz, &buflen, tmp, 0);  \
    mcr_pr_comma();
  }

  /*-------------------------------------------------*/
  if ( (x->bmask & ((uint64_t)1 << 27)) != 0 ) {
    sprintf(tmp, "\"sls_unit_q_L5\" : %f ", x->sls_unit_q_L5);
    status = cat_to_buf(&buf, &bufsz, &buflen, tmp, 0);  \
    mcr_pr_comma();
  }

  /*-------------------------------------------------*/
  if ( (x->bmask & ((uint64_t)1 << 28)) != 0 ) {
    sprintf(tmp, "\"baseprice\" : %f ", x->baseprice);
    status = cat_to_buf(&buf, &bufsz, &buflen, tmp, 0);  \
    mcr_pr_comma();
  }

  /*-------------------------------------------------*/
  if ( (x->bmask & ((uint64_t)1 << 29)) != 0 ) {
    sprintf(tmp, "\"offerprice\" : %f ", x->offerprice);
    status = cat_to_buf(&buf, &bufsz, &buflen, tmp, 0);  \
    mcr_pr_comma();
  }

  /*-------------------------------------------------*/
  if ( (x->bmask & ((uint64_t)1 << 30)) != 0 ) {
    sprintf(tmp, "\"baseprice_lift\" : %f ", x->baseprice_lift);
    status = cat_to_buf(&buf, &bufsz, &buflen, tmp, 0);  \
    mcr_pr_comma();
  }

  /*-------------------------------------------------*/
  if ( (x->bmask & ((uint64_t)1 << 31)) != 0 ) {
    sprintf(tmp, "\"promo_lift\" : %f ", x->promo_lift);
    status = cat_to_buf(&buf, &bufsz, &buflen, tmp, 0);  \
    mcr_pr_comma();
  }

  /*-------------------------------------------------*/

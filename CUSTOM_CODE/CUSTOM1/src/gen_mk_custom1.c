    x = json_object_get(root, "intercept");
    if ( x != NULL ) { 
      bmask |= ((uint64_t)1 << 0);
      if ( json_is_real(x) ) { 
        ftmp = (float)json_real_value(x); 
      }
      else if ( json_is_integer(x) ) { 
        ftmp = (float)json_integer_value(x); 
      }
      else {
        go_BYE(-1);
      }
      Y[i].intercept = F4_to_F2(ftmp);
    }

    /*-------------------------------------------------*/
    x = json_object_get(root, "goodfriday");
    if ( x != NULL ) { 
      bmask |= ((uint64_t)1 << 1);
      if ( json_is_real(x) ) { 
        ftmp = (float)json_real_value(x); 
      }
      else if ( json_is_integer(x) ) { 
        ftmp = (float)json_integer_value(x); 
      }
      else {
        go_BYE(-1);
      }
      Y[i].goodfriday = F4_to_F2(ftmp);
    }

    /*-------------------------------------------------*/
    x = json_object_get(root, "easter");
    if ( x != NULL ) { 
      bmask |= ((uint64_t)1 << 2);
      if ( json_is_real(x) ) { 
        ftmp = (float)json_real_value(x); 
      }
      else if ( json_is_integer(x) ) { 
        ftmp = (float)json_integer_value(x); 
      }
      else {
        go_BYE(-1);
      }
      Y[i].easter = F4_to_F2(ftmp);
    }

    /*-------------------------------------------------*/
    x = json_object_get(root, "mardigras");
    if ( x != NULL ) { 
      bmask |= ((uint64_t)1 << 3);
      if ( json_is_real(x) ) { 
        ftmp = (float)json_real_value(x); 
      }
      else if ( json_is_integer(x) ) { 
        ftmp = (float)json_integer_value(x); 
      }
      else {
        go_BYE(-1);
      }
      Y[i].mardigras = F4_to_F2(ftmp);
    }

    /*-------------------------------------------------*/
    x = json_object_get(root, "memorialday");
    if ( x != NULL ) { 
      bmask |= ((uint64_t)1 << 4);
      if ( json_is_real(x) ) { 
        ftmp = (float)json_real_value(x); 
      }
      else if ( json_is_integer(x) ) { 
        ftmp = (float)json_integer_value(x); 
      }
      else {
        go_BYE(-1);
      }
      Y[i].memorialday = F4_to_F2(ftmp);
    }

    /*-------------------------------------------------*/
    x = json_object_get(root, "mothersday_minus");
    if ( x != NULL ) { 
      bmask |= ((uint64_t)1 << 5);
      if ( json_is_real(x) ) { 
        ftmp = (float)json_real_value(x); 
      }
      else if ( json_is_integer(x) ) { 
        ftmp = (float)json_integer_value(x); 
      }
      else {
        go_BYE(-1);
      }
      Y[i].mothersday_minus = F4_to_F2(ftmp);
    }

    /*-------------------------------------------------*/
    x = json_object_get(root, "mothersday");
    if ( x != NULL ) { 
      bmask |= ((uint64_t)1 << 6);
      if ( json_is_real(x) ) { 
        ftmp = (float)json_real_value(x); 
      }
      else if ( json_is_integer(x) ) { 
        ftmp = (float)json_integer_value(x); 
      }
      else {
        go_BYE(-1);
      }
      Y[i].mothersday = F4_to_F2(ftmp);
    }

    /*-------------------------------------------------*/
    x = json_object_get(root, "presidentsday");
    if ( x != NULL ) { 
      bmask |= ((uint64_t)1 << 7);
      if ( json_is_real(x) ) { 
        ftmp = (float)json_real_value(x); 
      }
      else if ( json_is_integer(x) ) { 
        ftmp = (float)json_integer_value(x); 
      }
      else {
        go_BYE(-1);
      }
      Y[i].presidentsday = F4_to_F2(ftmp);
    }

    /*-------------------------------------------------*/
    x = json_object_get(root, "superbowl_minus");
    if ( x != NULL ) { 
      bmask |= ((uint64_t)1 << 8);
      if ( json_is_real(x) ) { 
        ftmp = (float)json_real_value(x); 
      }
      else if ( json_is_integer(x) ) { 
        ftmp = (float)json_integer_value(x); 
      }
      else {
        go_BYE(-1);
      }
      Y[i].superbowl_minus = F4_to_F2(ftmp);
    }

    /*-------------------------------------------------*/
    x = json_object_get(root, "superbowl");
    if ( x != NULL ) { 
      bmask |= ((uint64_t)1 << 9);
      if ( json_is_real(x) ) { 
        ftmp = (float)json_real_value(x); 
      }
      else if ( json_is_integer(x) ) { 
        ftmp = (float)json_integer_value(x); 
      }
      else {
        go_BYE(-1);
      }
      Y[i].superbowl = F4_to_F2(ftmp);
    }

    /*-------------------------------------------------*/
    x = json_object_get(root, "thanksgiving");
    if ( x != NULL ) { 
      bmask |= ((uint64_t)1 << 10);
      if ( json_is_real(x) ) { 
        ftmp = (float)json_real_value(x); 
      }
      else if ( json_is_integer(x) ) { 
        ftmp = (float)json_integer_value(x); 
      }
      else {
        go_BYE(-1);
      }
      Y[i].thanksgiving = F4_to_F2(ftmp);
    }

    /*-------------------------------------------------*/
    x = json_object_get(root, "valentines");
    if ( x != NULL ) { 
      bmask |= ((uint64_t)1 << 11);
      if ( json_is_real(x) ) { 
        ftmp = (float)json_real_value(x); 
      }
      else if ( json_is_integer(x) ) { 
        ftmp = (float)json_integer_value(x); 
      }
      else {
        go_BYE(-1);
      }
      Y[i].valentines = F4_to_F2(ftmp);
    }

    /*-------------------------------------------------*/
    x = json_object_get(root, "stpatricks");
    if ( x != NULL ) { 
      bmask |= ((uint64_t)1 << 12);
      if ( json_is_real(x) ) { 
        ftmp = (float)json_real_value(x); 
      }
      else if ( json_is_integer(x) ) { 
        ftmp = (float)json_integer_value(x); 
      }
      else {
        go_BYE(-1);
      }
      Y[i].stpatricks = F4_to_F2(ftmp);
    }

    /*-------------------------------------------------*/
    x = json_object_get(root, "cincodemayo");
    if ( x != NULL ) { 
      bmask |= ((uint64_t)1 << 13);
      if ( json_is_real(x) ) { 
        ftmp = (float)json_real_value(x); 
      }
      else if ( json_is_integer(x) ) { 
        ftmp = (float)json_integer_value(x); 
      }
      else {
        go_BYE(-1);
      }
      Y[i].cincodemayo = F4_to_F2(ftmp);
    }

    /*-------------------------------------------------*/
    x = json_object_get(root, "julyfourth");
    if ( x != NULL ) { 
      bmask |= ((uint64_t)1 << 14);
      if ( json_is_real(x) ) { 
        ftmp = (float)json_real_value(x); 
      }
      else if ( json_is_integer(x) ) { 
        ftmp = (float)json_integer_value(x); 
      }
      else {
        go_BYE(-1);
      }
      Y[i].julyfourth = F4_to_F2(ftmp);
    }

    /*-------------------------------------------------*/
    x = json_object_get(root, "halloween");
    if ( x != NULL ) { 
      bmask |= ((uint64_t)1 << 15);
      if ( json_is_real(x) ) { 
        ftmp = (float)json_real_value(x); 
      }
      else if ( json_is_integer(x) ) { 
        ftmp = (float)json_integer_value(x); 
      }
      else {
        go_BYE(-1);
      }
      Y[i].halloween = F4_to_F2(ftmp);
    }

    /*-------------------------------------------------*/
    x = json_object_get(root, "christmas_minus");
    if ( x != NULL ) { 
      bmask |= ((uint64_t)1 << 16);
      if ( json_is_real(x) ) { 
        ftmp = (float)json_real_value(x); 
      }
      else if ( json_is_integer(x) ) { 
        ftmp = (float)json_integer_value(x); 
      }
      else {
        go_BYE(-1);
      }
      Y[i].christmas_minus = F4_to_F2(ftmp);
    }

    /*-------------------------------------------------*/
    x = json_object_get(root, "christmas");
    if ( x != NULL ) { 
      bmask |= ((uint64_t)1 << 17);
      if ( json_is_real(x) ) { 
        ftmp = (float)json_real_value(x); 
      }
      else if ( json_is_integer(x) ) { 
        ftmp = (float)json_integer_value(x); 
      }
      else {
        go_BYE(-1);
      }
      Y[i].christmas = F4_to_F2(ftmp);
    }

    /*-------------------------------------------------*/
    x = json_object_get(root, "newyearsday");
    if ( x != NULL ) { 
      bmask |= ((uint64_t)1 << 18);
      if ( json_is_real(x) ) { 
        ftmp = (float)json_real_value(x); 
      }
      else if ( json_is_integer(x) ) { 
        ftmp = (float)json_integer_value(x); 
      }
      else {
        go_BYE(-1);
      }
      Y[i].newyearsday = F4_to_F2(ftmp);
    }

    /*-------------------------------------------------*/
    x = json_object_get(root, "t_o_y");
    if ( x != NULL ) { 
      bmask |= ((uint64_t)1 << 19);
      if ( json_is_real(x) ) { 
        ftmp = (float)json_real_value(x); 
      }
      else if ( json_is_integer(x) ) { 
        ftmp = (float)json_integer_value(x); 
      }
      else {
        go_BYE(-1);
      }
      Y[i].t_o_y = F4_to_F2(ftmp);
    }

    /*-------------------------------------------------*/
    x = json_object_get(root, "n_week");
    if ( x != NULL ) { 
      bmask |= ((uint64_t)1 << 20);
      if ( json_is_real(x) ) { 
        ftmp = (float)json_real_value(x); 
      }
      else if ( json_is_integer(x) ) { 
        ftmp = (float)json_integer_value(x); 
      }
      else {
        go_BYE(-1);
      }
      Y[i].n_week = F4_to_F2(ftmp);
    }

    /*-------------------------------------------------*/
    x = json_object_get(root, "time_band");
    if ( x != NULL ) { 
      bmask |= ((uint64_t)1 << 21);
      if ( json_is_real(x) ) { 
        ftmp = (float)json_real_value(x); 
      }
      else if ( json_is_integer(x) ) { 
        ftmp = (float)json_integer_value(x); 
      }
      else {
        go_BYE(-1);
      }
      Y[i].time_band = F4_to_F2(ftmp);
    }

    /*-------------------------------------------------*/
    x = json_object_get(root, "btcs_value");
    if ( x != NULL ) { 
      bmask |= ((uint64_t)1 << 22);
      if ( json_is_real(x) ) { 
        ftmp = (float)json_real_value(x); 
      }
      else if ( json_is_integer(x) ) { 
        ftmp = (float)json_integer_value(x); 
      }
      else {
        go_BYE(-1);
      }
      Y[i].btcs_value = F4_to_F2(ftmp);
    }

    /*-------------------------------------------------*/
    x = json_object_get(root, "sls_unit_q_L1");
    if ( x != NULL ) { 
      bmask |= ((uint64_t)1 << 23);
      if ( json_is_real(x) ) { 
        ftmp = (float)json_real_value(x); 
      }
      else if ( json_is_integer(x) ) { 
        ftmp = (float)json_integer_value(x); 
      }
      else {
        go_BYE(-1);
      }
      Y[i].sls_unit_q_L1 = F4_to_F2(ftmp);
    }

    /*-------------------------------------------------*/
    x = json_object_get(root, "sls_unit_q_L2");
    if ( x != NULL ) { 
      bmask |= ((uint64_t)1 << 24);
      if ( json_is_real(x) ) { 
        ftmp = (float)json_real_value(x); 
      }
      else if ( json_is_integer(x) ) { 
        ftmp = (float)json_integer_value(x); 
      }
      else {
        go_BYE(-1);
      }
      Y[i].sls_unit_q_L2 = F4_to_F2(ftmp);
    }

    /*-------------------------------------------------*/
    x = json_object_get(root, "sls_unit_q_L3");
    if ( x != NULL ) { 
      bmask |= ((uint64_t)1 << 25);
      if ( json_is_real(x) ) { 
        ftmp = (float)json_real_value(x); 
      }
      else if ( json_is_integer(x) ) { 
        ftmp = (float)json_integer_value(x); 
      }
      else {
        go_BYE(-1);
      }
      Y[i].sls_unit_q_L3 = F4_to_F2(ftmp);
    }

    /*-------------------------------------------------*/
    x = json_object_get(root, "sls_unit_q_L4");
    if ( x != NULL ) { 
      bmask |= ((uint64_t)1 << 26);
      if ( json_is_real(x) ) { 
        ftmp = (float)json_real_value(x); 
      }
      else if ( json_is_integer(x) ) { 
        ftmp = (float)json_integer_value(x); 
      }
      else {
        go_BYE(-1);
      }
      Y[i].sls_unit_q_L4 = F4_to_F2(ftmp);
    }

    /*-------------------------------------------------*/
    x = json_object_get(root, "sls_unit_q_L5");
    if ( x != NULL ) { 
      bmask |= ((uint64_t)1 << 27);
      if ( json_is_real(x) ) { 
        ftmp = (float)json_real_value(x); 
      }
      else if ( json_is_integer(x) ) { 
        ftmp = (float)json_integer_value(x); 
      }
      else {
        go_BYE(-1);
      }
      Y[i].sls_unit_q_L5 = F4_to_F2(ftmp);
    }

    /*-------------------------------------------------*/
    x = json_object_get(root, "baseprice");
    if ( x != NULL ) { 
      bmask |= ((uint64_t)1 << 28);
      if ( json_is_real(x) ) { 
        ftmp = (float)json_real_value(x); 
      }
      else if ( json_is_integer(x) ) { 
        ftmp = (float)json_integer_value(x); 
      }
      else {
        go_BYE(-1);
      }
      Y[i].baseprice = F4_to_F2(ftmp);
    }

    /*-------------------------------------------------*/
    x = json_object_get(root, "offerprice");
    if ( x != NULL ) { 
      bmask |= ((uint64_t)1 << 29);
      if ( json_is_real(x) ) { 
        ftmp = (float)json_real_value(x); 
      }
      else if ( json_is_integer(x) ) { 
        ftmp = (float)json_integer_value(x); 
      }
      else {
        go_BYE(-1);
      }
      Y[i].offerprice = F4_to_F2(ftmp);
    }

    /*-------------------------------------------------*/
    x = json_object_get(root, "baseprice_lift");
    if ( x != NULL ) { 
      bmask |= ((uint64_t)1 << 30);
      if ( json_is_real(x) ) { 
        ftmp = (float)json_real_value(x); 
      }
      else if ( json_is_integer(x) ) { 
        ftmp = (float)json_integer_value(x); 
      }
      else {
        go_BYE(-1);
      }
      Y[i].baseprice_lift = F4_to_F2(ftmp);
    }

    /*-------------------------------------------------*/
    x = json_object_get(root, "promo_lift");
    if ( x != NULL ) { 
      bmask |= ((uint64_t)1 << 31);
      if ( json_is_real(x) ) { 
        ftmp = (float)json_real_value(x); 
      }
      else if ( json_is_integer(x) ) { 
        ftmp = (float)json_integer_value(x); 
      }
      else {
        go_BYE(-1);
      }
      Y[i].promo_lift = F4_to_F2(ftmp);
    }

    /*-------------------------------------------------*/

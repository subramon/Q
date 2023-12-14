    x = json_object_get(root, "intercept");
    if ( x != NULL ) { 
      bmask |= ((uint64_t)1 << 0);
      if ( json_is_real(x) ) { 
        Y[i].intercept = json_real_value(x); 
      }
      else if ( json_is_integer(x) ) { 
        Y[i].intercept = json_integer_value(x); 
      }
      else {
        go_BYE(-1);
      }
    }

    /*-------------------------------------------------*/
    x = json_object_get(root, "baseprice_lift");
    if ( x != NULL ) { 
      bmask |= ((uint64_t)1 << 1);
      if ( json_is_real(x) ) { 
        Y[i].baseprice_lift = json_real_value(x); 
      }
      else if ( json_is_integer(x) ) { 
        Y[i].baseprice_lift = json_integer_value(x); 
      }
      else {
        go_BYE(-1);
      }
    }

    /*-------------------------------------------------*/
    x = json_object_get(root, "promo_lift");
    if ( x != NULL ) { 
      bmask |= ((uint64_t)1 << 2);
      if ( json_is_real(x) ) { 
        Y[i].promo_lift = json_real_value(x); 
      }
      else if ( json_is_integer(x) ) { 
        Y[i].promo_lift = json_integer_value(x); 
      }
      else {
        go_BYE(-1);
      }
    }

    /*-------------------------------------------------*/
    x = json_object_get(root, "goodfriday");
    if ( x != NULL ) { 
      bmask |= ((uint64_t)1 << 3);
      if ( json_is_real(x) ) { 
        Y[i].goodfriday = json_real_value(x); 
      }
      else if ( json_is_integer(x) ) { 
        Y[i].goodfriday = json_integer_value(x); 
      }
      else {
        go_BYE(-1);
      }
    }

    /*-------------------------------------------------*/
    x = json_object_get(root, "easter");
    if ( x != NULL ) { 
      bmask |= ((uint64_t)1 << 4);
      if ( json_is_real(x) ) { 
        Y[i].easter = json_real_value(x); 
      }
      else if ( json_is_integer(x) ) { 
        Y[i].easter = json_integer_value(x); 
      }
      else {
        go_BYE(-1);
      }
    }

    /*-------------------------------------------------*/
    x = json_object_get(root, "mardigras");
    if ( x != NULL ) { 
      bmask |= ((uint64_t)1 << 5);
      if ( json_is_real(x) ) { 
        Y[i].mardigras = json_real_value(x); 
      }
      else if ( json_is_integer(x) ) { 
        Y[i].mardigras = json_integer_value(x); 
      }
      else {
        go_BYE(-1);
      }
    }

    /*-------------------------------------------------*/
    x = json_object_get(root, "memorialday");
    if ( x != NULL ) { 
      bmask |= ((uint64_t)1 << 6);
      if ( json_is_real(x) ) { 
        Y[i].memorialday = json_real_value(x); 
      }
      else if ( json_is_integer(x) ) { 
        Y[i].memorialday = json_integer_value(x); 
      }
      else {
        go_BYE(-1);
      }
    }

    /*-------------------------------------------------*/
    x = json_object_get(root, "mothersday_minus");
    if ( x != NULL ) { 
      bmask |= ((uint64_t)1 << 7);
      if ( json_is_real(x) ) { 
        Y[i].mothersday_minus = json_real_value(x); 
      }
      else if ( json_is_integer(x) ) { 
        Y[i].mothersday_minus = json_integer_value(x); 
      }
      else {
        go_BYE(-1);
      }
    }

    /*-------------------------------------------------*/
    x = json_object_get(root, "mothersday");
    if ( x != NULL ) { 
      bmask |= ((uint64_t)1 << 8);
      if ( json_is_real(x) ) { 
        Y[i].mothersday = json_real_value(x); 
      }
      else if ( json_is_integer(x) ) { 
        Y[i].mothersday = json_integer_value(x); 
      }
      else {
        go_BYE(-1);
      }
    }

    /*-------------------------------------------------*/
    x = json_object_get(root, "presidentsday");
    if ( x != NULL ) { 
      bmask |= ((uint64_t)1 << 9);
      if ( json_is_real(x) ) { 
        Y[i].presidentsday = json_real_value(x); 
      }
      else if ( json_is_integer(x) ) { 
        Y[i].presidentsday = json_integer_value(x); 
      }
      else {
        go_BYE(-1);
      }
    }

    /*-------------------------------------------------*/
    x = json_object_get(root, "superbowl_minus");
    if ( x != NULL ) { 
      bmask |= ((uint64_t)1 << 10);
      if ( json_is_real(x) ) { 
        Y[i].superbowl_minus = json_real_value(x); 
      }
      else if ( json_is_integer(x) ) { 
        Y[i].superbowl_minus = json_integer_value(x); 
      }
      else {
        go_BYE(-1);
      }
    }

    /*-------------------------------------------------*/
    x = json_object_get(root, "superbowl");
    if ( x != NULL ) { 
      bmask |= ((uint64_t)1 << 11);
      if ( json_is_real(x) ) { 
        Y[i].superbowl = json_real_value(x); 
      }
      else if ( json_is_integer(x) ) { 
        Y[i].superbowl = json_integer_value(x); 
      }
      else {
        go_BYE(-1);
      }
    }

    /*-------------------------------------------------*/
    x = json_object_get(root, "thanksgiving");
    if ( x != NULL ) { 
      bmask |= ((uint64_t)1 << 12);
      if ( json_is_real(x) ) { 
        Y[i].thanksgiving = json_real_value(x); 
      }
      else if ( json_is_integer(x) ) { 
        Y[i].thanksgiving = json_integer_value(x); 
      }
      else {
        go_BYE(-1);
      }
    }

    /*-------------------------------------------------*/
    x = json_object_get(root, "valentines");
    if ( x != NULL ) { 
      bmask |= ((uint64_t)1 << 13);
      if ( json_is_real(x) ) { 
        Y[i].valentines = json_real_value(x); 
      }
      else if ( json_is_integer(x) ) { 
        Y[i].valentines = json_integer_value(x); 
      }
      else {
        go_BYE(-1);
      }
    }

    /*-------------------------------------------------*/
    x = json_object_get(root, "stpatricks");
    if ( x != NULL ) { 
      bmask |= ((uint64_t)1 << 14);
      if ( json_is_real(x) ) { 
        Y[i].stpatricks = json_real_value(x); 
      }
      else if ( json_is_integer(x) ) { 
        Y[i].stpatricks = json_integer_value(x); 
      }
      else {
        go_BYE(-1);
      }
    }

    /*-------------------------------------------------*/
    x = json_object_get(root, "cincodemayo");
    if ( x != NULL ) { 
      bmask |= ((uint64_t)1 << 15);
      if ( json_is_real(x) ) { 
        Y[i].cincodemayo = json_real_value(x); 
      }
      else if ( json_is_integer(x) ) { 
        Y[i].cincodemayo = json_integer_value(x); 
      }
      else {
        go_BYE(-1);
      }
    }

    /*-------------------------------------------------*/
    x = json_object_get(root, "julyfourth");
    if ( x != NULL ) { 
      bmask |= ((uint64_t)1 << 16);
      if ( json_is_real(x) ) { 
        Y[i].julyfourth = json_real_value(x); 
      }
      else if ( json_is_integer(x) ) { 
        Y[i].julyfourth = json_integer_value(x); 
      }
      else {
        go_BYE(-1);
      }
    }

    /*-------------------------------------------------*/
    x = json_object_get(root, "halloween");
    if ( x != NULL ) { 
      bmask |= ((uint64_t)1 << 17);
      if ( json_is_real(x) ) { 
        Y[i].halloween = json_real_value(x); 
      }
      else if ( json_is_integer(x) ) { 
        Y[i].halloween = json_integer_value(x); 
      }
      else {
        go_BYE(-1);
      }
    }

    /*-------------------------------------------------*/
    x = json_object_get(root, "christmas_minus");
    if ( x != NULL ) { 
      bmask |= ((uint64_t)1 << 18);
      if ( json_is_real(x) ) { 
        Y[i].christmas_minus = json_real_value(x); 
      }
      else if ( json_is_integer(x) ) { 
        Y[i].christmas_minus = json_integer_value(x); 
      }
      else {
        go_BYE(-1);
      }
    }

    /*-------------------------------------------------*/
    x = json_object_get(root, "christmas");
    if ( x != NULL ) { 
      bmask |= ((uint64_t)1 << 19);
      if ( json_is_real(x) ) { 
        Y[i].christmas = json_real_value(x); 
      }
      else if ( json_is_integer(x) ) { 
        Y[i].christmas = json_integer_value(x); 
      }
      else {
        go_BYE(-1);
      }
    }

    /*-------------------------------------------------*/
    x = json_object_get(root, "newyearsday");
    if ( x != NULL ) { 
      bmask |= ((uint64_t)1 << 20);
      if ( json_is_real(x) ) { 
        Y[i].newyearsday = json_real_value(x); 
      }
      else if ( json_is_integer(x) ) { 
        Y[i].newyearsday = json_integer_value(x); 
      }
      else {
        go_BYE(-1);
      }
    }

    /*-------------------------------------------------*/
    x = json_object_get(root, "t_o_y");
    if ( x != NULL ) { 
      bmask |= ((uint64_t)1 << 21);
      if ( json_is_real(x) ) { 
        Y[i].t_o_y = json_real_value(x); 
      }
      else if ( json_is_integer(x) ) { 
        Y[i].t_o_y = json_integer_value(x); 
      }
      else {
        go_BYE(-1);
      }
    }

    /*-------------------------------------------------*/
    x = json_object_get(root, "sls_unit_q_L1");
    if ( x != NULL ) { 
      bmask |= ((uint64_t)1 << 22);
      if ( json_is_real(x) ) { 
        Y[i].sls_unit_q_L1 = json_real_value(x); 
      }
      else if ( json_is_integer(x) ) { 
        Y[i].sls_unit_q_L1 = json_integer_value(x); 
      }
      else {
        go_BYE(-1);
      }
    }

    /*-------------------------------------------------*/
    x = json_object_get(root, "sls_unit_q_L2");
    if ( x != NULL ) { 
      bmask |= ((uint64_t)1 << 23);
      if ( json_is_real(x) ) { 
        Y[i].sls_unit_q_L2 = json_real_value(x); 
      }
      else if ( json_is_integer(x) ) { 
        Y[i].sls_unit_q_L2 = json_integer_value(x); 
      }
      else {
        go_BYE(-1);
      }
    }

    /*-------------------------------------------------*/
    x = json_object_get(root, "n_week");
    if ( x != NULL ) { 
      bmask |= ((uint64_t)1 << 24);
      if ( json_is_real(x) ) { 
        Y[i].n_week = json_real_value(x); 
      }
      else if ( json_is_integer(x) ) { 
        Y[i].n_week = json_integer_value(x); 
      }
      else {
        go_BYE(-1);
      }
    }

    /*-------------------------------------------------*/
    x = json_object_get(root, "time_band");
    if ( x != NULL ) { 
      bmask |= ((uint64_t)1 << 25);
      if ( json_is_real(x) ) { 
        Y[i].time_band = json_real_value(x); 
      }
      else if ( json_is_integer(x) ) { 
        Y[i].time_band = json_integer_value(x); 
      }
      else {
        go_BYE(-1);
      }
    }

    /*-------------------------------------------------*/
    x = json_object_get(root, "btcs_value");
    if ( x != NULL ) { 
      bmask |= ((uint64_t)1 << 26);
      if ( json_is_real(x) ) { 
        Y[i].btcs_value = json_real_value(x); 
      }
      else if ( json_is_integer(x) ) { 
        Y[i].btcs_value = json_integer_value(x); 
      }
      else {
        go_BYE(-1);
      }
    }

    /*-------------------------------------------------*/
    x = json_object_get(root, "sls_unit_q_L3");
    if ( x != NULL ) { 
      bmask |= ((uint64_t)1 << 27);
      if ( json_is_real(x) ) { 
        Y[i].sls_unit_q_L3 = json_real_value(x); 
      }
      else if ( json_is_integer(x) ) { 
        Y[i].sls_unit_q_L3 = json_integer_value(x); 
      }
      else {
        go_BYE(-1);
      }
    }

    /*-------------------------------------------------*/
    x = json_object_get(root, "sls_unit_q_L4");
    if ( x != NULL ) { 
      bmask |= ((uint64_t)1 << 28);
      if ( json_is_real(x) ) { 
        Y[i].sls_unit_q_L4 = json_real_value(x); 
      }
      else if ( json_is_integer(x) ) { 
        Y[i].sls_unit_q_L4 = json_integer_value(x); 
      }
      else {
        go_BYE(-1);
      }
    }

    /*-------------------------------------------------*/
    x = json_object_get(root, "sls_unit_q_L5");
    if ( x != NULL ) { 
      bmask |= ((uint64_t)1 << 29);
      if ( json_is_real(x) ) { 
        Y[i].sls_unit_q_L5 = json_real_value(x); 
      }
      else if ( json_is_integer(x) ) { 
        Y[i].sls_unit_q_L5 = json_integer_value(x); 
      }
      else {
        go_BYE(-1);
      }
    }

    /*-------------------------------------------------*/

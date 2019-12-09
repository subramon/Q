// shift key_idx to accommodate val

// START: Input vectors
int nP;  // number of perturbations
uint8_t *boh_idx; /* [nP] */
uint8_t *dmd_idx; /* [nP] */
uint8_t *tdf_idx; /* [nP] */
uint8_t * ss_idx; /* [nP] */
uint8_t * ls_idx; /* [nP] */

float *ouptut_v_1; /* [nP] */ // avg_markdowns[0] 
float *ouptut_v_2; /* [nP] */ // avg_markdowns[1] 
float *ouptut_v_3; /* [nP] */ // avg_markdowns[2] 
float *ouptut_v_4; /* [nP] */ // avg_markdowns[3] 
float *ouptut_v_5; /* [nP] */ // num_price_changes

int nIL; // number of Item Location pairs with same optimization
int nSD; // number of slicing dimensions
uint8_t **slice_v; // [nSD][nIL];
int sd_lb; // for resumption of work 

// STOP: Input vectors

// START: For Lua to produce
#define nPD     5 // number of perturbation dimensions
#define BOH_KEY 1
#define DMD_KEY 2
#define TDF_KEY 3
#define  SS_KEY 4
#define  LS_KEY 5

#define nDD        4    // number of data dimensions
#define DATA_1_KEY 6 
#define DATA_2_KEY 7 
#define DATA_3_KEY 8 
#define DATA_4_KEY 9 

#define SHIFT_KEY 
uint32_t perturb_v[nPD];
uint32_t perturb_k[nPD];

perturb_k[0] = BOH_KEY << SHIFT_KEY; 
perturb_k[1] = DMD_KEY << SHIFT_KEY; 
perturb_k[2] = TDF_KEY << SHIFT_KEY; 
perturb_k[3] =  SS_KEY << SHIFT_KEY; 
perturb_k[4] =  LS_KEY << SHIFT_KEY; 

  slice_k[0] = DATA_1_KEY << SHIFT_KEY; 
  slice_k[1] = DATA_2_KEY << SHIFT_KEY; 
  slice_k[2] = DATA_3_KEY << SHIFT_KEY; 
  slice_k[3] = DATA_4_KEY << SHIFT_KEY; 
// STOP : For Lua to produce

uint32_t *comp_keys; 
int comp_key_idx = 0;
int zval_idx = 0;
val_t *zval; // [XX] 
#define SHIFT1 16

// for resumption of work
int plb = 0;
for ( int pidx = plb; pidx < nP; pidx++ ) { 
  //-------------------------------
  perturb_v[0] = boh_idx[pidx]; // autogen
  perturb_v[1] = dmd_idx[pidx]; // autogen
  perturb_v[2] = tdf_idx[pidx]; // autogen
  perturb_v[3] =  ss_idx[pidx]; // autogen
  perturb_v[4] =  ls_idx[pidx]; // autogen
  //-------------------------------
  // from col format to row format (in a struct)
  zval[zval_idx].val_1 = output_v_1[pidx]; // autogen
  zval[zval_idx].val_2 = output_v_2[pidx]; // autogen
  zval[zval_idx].val_3 = output_v_3[pidx]; // autogen
  zval[zval_idx].val_4 = output_v_4[pidx]; // autogen
  zval[zval_idx].val_5 = output_v_5[pidx]; // autogen
  zval_idx++; 
  //-------------------------------
  for ( int i = 0; i < nPD; i++ ) {
    kv1 = (perturb_k[i] | perturb_v[i] ) << SHIFT1;
    for ( int j = i+1; j < nPD; j++ ) {
      kv2 = perturb_k[j] | perturb_v[j];
      comp_keys[comp_keyidx++] = kv1 | kv2;
    }
  }
  // now let's get all combinations of slices
  for ( int k = il_lb; k < nIL; k++ ) { 
    for ( int i = 0; i < nDD; i++ ) {
      kv1 = (perturb_k[i] | perturb_v[i] ) << SHIFT1;
      for ( int j = i+1; j < nPD; j++ ) {
        kv2 = perturb_k[j] | perturb_v[j];
        comp_keys[comp_keyidx++] = kv1 | kv2;
      }
    }
  }
}

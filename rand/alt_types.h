#ifndef _ALT_TYPES_H
#define _ALT_TYPES_H
typedef struct _perturb_rec_type { 
  uint8_t boh_idx; // inventory attenuation 
  uint8_t dmd_idx;  // base demand adjustment
  uint8_t tdf_idx;  // time decay factor
  uint8_t ss_idx;  // small slope 
  uint8_t ls_idx;  // large slope
} PERTURB_REC_TYPE;

typedef struct
{
  int base_value;
  float *shocks; // [n_s] 
  int n_s;
} IntInput;
 
typedef struct
{ 
  float base_value; // used only by base_demand as of now
  float *shocks; // [n_s] 
  int n_s;
} FloatInput;
 
typedef struct
{ 
  FloatInput base_demand;
  IntInput   initial_inventory;
  FloatInput small_slope;
  FloatInput large_slope;
  FloatInput time_decay_factor;
} Perturbations;
 
typedef struct
{
  float discount;
  float *elasticities; // [n_e] 
  int n_e;           
} Markdowns;
 
typedef struct
{
  float from_price;
  float to_price;
  int inventory_level;
  int week_num;
} Policy;
 
typedef struct
{
  Perturbations perturbations; 
  Policy *policy; // [n_pol] 
  int n_pol; 
  Markdowns *markdowns; // [n_md]  
  int n_md; 
  int n_traces; 
  int elasticity_type; 
  float *l_markdowns; // [n_md] Created, not true input
  int n_steps; // Created, not true input
} SimulationInput;

typedef struct { 
  float elapsed_time;
} RunTimeMetrics;

typedef struct {

  int boh_s;
  float boh_d;
  float dmd_s;
  float dmd_d;
  float slope_sm_s;
  float slope_sm_d;
  float slope_lg_s;
  float slope_lg_d;
  float decay_s;
  float decay_d;
  float rev;
  float sell_thru;
  float num_price_changes;
  float *markdowns; /* [n_markdowns] */ 
} CSimulationOutputResult;

typedef struct
{
  RunTimeMetrics *metrics;
  CSimulationOutputResult *xxx; // TODO P4 need better name 
  int n_outputs;
  int n_md; // from CSimulationInput
} CSimulationOutput;

#endif

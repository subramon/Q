local convert_sklearn_to_q = require 'Q/ML/DT/lua/convert_sklearn_to_q_dt'['convert_sklearn_to_q']
local print_dt = require 'Q/ML/DT/lua/dt'['print_dt']
local plpath = require 'pl.path'
local path_to_here = os.getenv("Q_SRC_ROOT") .. "/ML/DT/test/"
assert(plpath.isdir(path_to_here))
local preprocess_dt = require 'Q/ML/DT/lua/dt'['preprocess_dt']
local load_csv_col_seq   = require 'Q/ML/UTILS/lua/utility'['load_csv_col_seq']
local export_to_graphviz = require 'Q/ML/DT/lua/export_to_graphviz'

local tests = {}

tests.t1 = function()
  
  local feature_list = { "id", "diagnosis", "radius_mean", "texture_mean", "perimeter_mean", "area_mean", "smoothness_mean","compactness_mean", "concavity_mean", "concave points_mean", "symmetry_mean", "fractal_dimension_mean", "radius_se", "texture_se", "perimeter_se", "area_se", "smoothness_se", "compactness_se", "concavity_se", "concave points_se", "symmetry_se", "fractal_dimension_se", "radius_worst","texture_worst", "perimeter_worst", "area_worst", "smoothness_worst","compactness_worst", "concavity_worst", "concave points_worst", "symmetry_worst", "fractal_dimension_worst" }
  
  local goal_feature = "diagnosis"
  -- converting sklearn gini graphviz to q dt
  local tree = convert_sklearn_to_q(path_to_here .. "sklearn_gini_graphviz.txt", feature_list, goal_feature)
  assert(type(tree) == "table", "q dt not created")
  
  -- perform the preprocess activity
  -- initializes n_H1 and n_T1 to zero
  preprocess_dt(tree)
  
  feature_list = load_csv_col_seq(feature_list, goal_feature)

  -- printing the decision tree in gini graphviz format
  local file_name = path_to_here .. "/output_q_format_graphviz.txt"
  export_to_graphviz(file_name, tree, feature_list)

  print("Q graphviz written to :" .. path_to_here .. "/output_q_format_graphviz.txt")
  print("Successfully completed test t1")
end

return tests
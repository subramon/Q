local Q = require 'Q'
local Vector = require 'libvec'
local Scalar = require 'libsclr'
local Q_SRC_ROOT = os.getenv("Q_SRC_ROOT")
local eval_mdl = require 'Q/ML/DT/lua/eval_mdl'['eval_mdl']
local tests = {}

-- Dataset: b_cancer/cancer_data_test.csv
tests.t1 = function()
  local write_to_csv = require 'Q/ML/DT/lua/write_to_csv_sklearn'
  local convert_sklearn_to_q = require 'Q/ML/DT/lua/convert_sklearn_to_q_dt'['convert_sklearn_to_q']
  local export_to_graphviz = require 'Q/ML/DT/lua/export_to_graphviz'

  local features_list = { "f1","f2","f3","f4","f5","f6","f7","f8","f9","f10","f11","f12","f13","f14","f15","f16","f17","class" }
  local goal_feature = "class"
  local test_csv = Q_SRC_ROOT .. "/ML/KNN/data/from_ramesh/ds1_11709_13248_test.csv"
  local meta_data_file = Q_SRC_ROOT .. "/ML/KNN/data/from_ramesh/ds1_updated_meta.lua"
  local is_hdr = true

  -- converting sklearn gini graphviz to q dt
  local tree = convert_sklearn_to_q(Q_SRC_ROOT.."/ML/DT/python/best_fit_graphviz_ramesh_f1.txt", features_list, goal_feature)
  local Test  = Q.load_csv(test_csv, dofile(meta_data_file), {is_hdr = is_hdr})
  local result = eval_mdl(tree, Test, goal_feature)

  write_to_csv(result, "t1_results.csv", ",", true)
end

-- Dataset: titanic/titanic_train_test.csv
tests.t2 = function()
  local write_to_csv = require 'Q/ML/DT/lua/write_to_csv_sklearn'
  local convert_sklearn_to_q = require 'Q/ML/DT/lua/convert_sklearn_to_q_dt'['convert_sklearn_to_q']
  local export_to_graphviz = require 'Q/ML/DT/lua/export_to_graphviz'

  local features_list = { "PassengerId","Survived","Pclass","Sex","Age","SibSp","Parch","Fare","Embarked" }
  local goal_feature = "Survived"
  local test_csv  = Q_SRC_ROOT .. "/ML/KNN/data/titanic/titanic_train_test.csv"
  local meta_data_file = Q_SRC_ROOT .. "/ML/KNN/data/titanic/titanic_train_meta.lua"
  local is_hdr = true

  -- converting sklearn gini graphviz to q dt
  local tree = convert_sklearn_to_q(Q_SRC_ROOT.."/ML/DT/python/best_fit_graphviz_titanic_accuracy.txt", features_list, goal_feature)
  local Test  = Q.load_csv(test_csv, dofile(meta_data_file), {is_hdr = is_hdr})
  local result = eval_mdl(tree, Test, goal_feature)

  write_to_csv(result, "t2_results.csv", ",", true) 
 end

-- Dataset: from_ramesh/ds1_11709_13248_test.csv
tests.t3 = function()
  local write_to_csv = require 'Q/ML/DT/lua/write_to_csv_sklearn'
  local convert_sklearn_to_q = require 'Q/ML/DT/lua/convert_sklearn_to_q_dt'['convert_sklearn_to_q']
  local export_to_graphviz = require 'Q/ML/DT/lua/export_to_graphviz'

  local features_list = { "f1","f2","f3","f4","f5","f6","f7","f8","f9","f10","f11","f12","f13","f14","f15","f16","f17","class" }
  local goal_feature = "class"
  local test_csv = Q_SRC_ROOT .. "/ML/KNN/data/from_ramesh/ds1_11709_13248_test.csv"
  local meta_data_file = Q_SRC_ROOT .. "/ML/KNN/data/from_ramesh/ds1_updated_meta.lua"
  local is_hdr = true

  -- converting sklearn gini graphviz to q dt
  local tree = convert_sklearn_to_q(Q_SRC_ROOT.."/ML/DT/python/best_fit_graphviz_ramesh_accuracy.txt", features_list, goal_feature)
  local Test  = Q.load_csv(test_csv, dofile(meta_data_file), {is_hdr = is_hdr})
  local result = eval_mdl(tree, Test, goal_feature)
  
  write_to_csv(result, "t3_results.csv", ",", true)
end

-- Dataset: from_ramesh/ds2_11720_7137_test.csv
tests.t4 = function()
  local write_to_csv = require 'Q/ML/DT/lua/write_to_csv_sklearn'
  local convert_sklearn_to_q = require 'Q/ML/DT/lua/convert_sklearn_to_q_dt'['convert_sklearn_to_q']
  local export_to_graphviz = require 'Q/ML/DT/lua/export_to_graphviz'

  local features_list = { "f1","f2","f3","f4","f5","f6","f7","f8","f9","f10","f11","f12","f13","f14","f15","f16","f17","class" }
  local goal_feature = "class"
  local test_csv = Q_SRC_ROOT .. "/ML/KNN/data/from_ramesh/ds2_11720_7137_train.csv"
  local meta_data_file = Q_SRC_ROOT .. "/ML/KNN/data/from_ramesh/ds1_updated_meta.lua"
  local is_hdr = true
  -- converting sklearn gini graphviz to q dt
  local tree = convert_sklearn_to_q(Q_SRC_ROOT.."/ML/DT/python/best_fit_graphviz_ramesh_category2_accuracy.txt", features_list, goal_feature)
  local Test  = Q.load_csv(test_csv, dofile(meta_data_file), {is_hdr = is_hdr})
  local result = eval_mdl(tree, Test, goal_feature)
  
  write_to_csv(result, "t4_results.csv", ",", true)
end

return tests

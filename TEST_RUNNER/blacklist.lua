-- This file contains list of tests which you want to exclude
-- Provide relative path from q_src_root along with the test-case file name

--[[
local blacklist_files = {
  "TEST_RUNNER/test_test1.lua",
  "TEST_RUNNER/test_test2.lua",
  "TEST_RUNNER/test_run_func.lua",
  "TESTS/test_log_reg_1.lua",
  "TESTS/test_log_reg_2.lua",
  "ML/LOGISTIC_REGRESSION/test/test_simple.lua",
  -- below is not a test
  "UTILS/lua/test_init.lua",
  -- below is not a test
  "UTILS/lua/test_utils.lua",
  -- Mail subject : List of failure tests in dev branch
  -- Let’s move the others into the black list
  "OPERATORS/APPROX/FREQUENT/test/test_approx_frequent.lua",
  "ML/LOGISTIC_REGRESSION/test/test_mnist.lua",
  "ML/LOGISTIC_REGRESSION/test/test_logistic_regression.lua",
  "OPERATORS/PCA/test/test_pca.lua",
  "ML/LOGISTIC_REGRESSION/test/test_really_simple.lua",
  "OPERATORS/MM/test/test_mv_mul.lua",
  "OPERATORS/PCA/test/test_eigen.lua",
  "OPERATORS/APPROX/QUANTILE/test/test_aq.lua",
  -- below test file requires python tests(Q/ML/DT/python/Dtree_sklearn*.py) to be executed first
  "ML/DT/test/test_accuracy_results/test_import_sklearn_in_q.lua"

}

return blacklist_files
--]]
return {}

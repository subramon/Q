To run test-case t1, t2, t3 of "test_import_sklearn_in_q.lua" script you need to first run 
"Q/ML/DT/python/DTree_sklearn_(breast_cancer_train_test|titanic_train_test|ramesh_dataset_train_test).py sklearn python files.

Following are the three scoring method covered:
1. accuracy
2. f1_weighted
3. f1

Note:
To enter scoring method in files:
1. Edit the "scoring method" and the "output graphviz file names"(so that results do not get overridden)in DTree_sklearn_(breast_cancer_train_test|titanic_train_test|ramesh_dataset_train_test).py files.
2. Replace the "Graphviz file name" as changed in above .py files in test_import_sklearn_in_q.lua

Example:
Steps to run test_import_sklearn_in_q for test-case t1(breast_cancer dataset):
For scoring method : "accuracy"

1. cd Q/ML/DT/python/
2. python -Wignore DTree_sklearn_breast_cancer_train_test.py
This generates graphviz file at Q/ML/DT/python/best_fit_graphviz_b_cancer_accuracy.txt location
3. cd ../test/test_accuracy_results/
4. luajit -e "require 'test_import_sklearn_in_q'['t1']()"
This generates result csv file at Q/ML/DT/test/test_accuracy_results/b_cancer_accuracy_results.csv location



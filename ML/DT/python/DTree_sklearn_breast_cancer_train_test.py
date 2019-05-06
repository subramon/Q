
# coding: utf-8

# In[1]:


import sklearn_dt_utils as utils
from sklearn.tree import export_graphviz
import pandas as pd
import os


# In[2]:


q_src_dir = os.getenv('Q_SRC_ROOT')
if not q_src_dir:
    print("'Q_SRC_ROOT' is not set")
    exit(-1)
train_csv_file_path = "%s/ML/KNN/data/cancer/b_cancer/cancer_data_train.csv"  % q_src_dir
test_csv_file_path = "%s/ML/KNN/data/cancer/b_cancer/cancer_data_test.csv"  % q_src_dir
graphviz_gini = "graphviz_gini.txt"
graphviz_entropy = "graphviz_entropy.txt"
goal_col_name = "diagnosis"


# In[12]:


print("Train dataset shape")
train_data = utils.import_data(train_csv_file_path)
print("Test dataset shape")
test_data = utils.import_data(test_csv_file_path)


# In[4]:


X, Y, X_train, temp_X_train, y_train, temp_y_train = utils.split_dataset(train_data, goal_col_name, 1)
X, Y, X_test, temp_X_test, y_test, temp_y_test = utils.split_dataset(test_data, goal_col_name, 1)

# In[13]:


#print(len(X_train))
#print(len(X_test))


# In[6]:


# cross validation
# cross_validate_dt_new(X, Y)


# In[7]:


# cross validation
# cross_validate_dt(X, Y)


# In[8]:

#calling gridsearchcv
grid = utils.grid_search_cv(X_train, y_train, scoring_method="accuracy")
"""
print(grid.cv_results_)
print("============================")
print(grid.best_estimator_)
print("============================")
print(grid.best_score_)
print("============================")
print(grid.best_params_)
print("============================")
"""
# Prediction using gini
y_pred_gini = utils.prediction(X_test, grid.best_estimator_)
print("Results for gini algo")
utils.cal_accuracy(y_test, y_pred_gini)

output_filename = "%s/ML/DT/python/best_fit_graphviz_b_cancer_accuracy.txt"  % q_src_dir
export_graphviz(grid.best_estimator_, out_file = output_filename, filled=True, rounded=True, special_characters=True, feature_names=X_train.columns)

# Train using gini
clf_gini = utils.train_using_gini(X_train, y_train)
#pickle_path = "dt_gini.pkl"
#utils.save(clf_gini, pickle_path)
# print(X_train[1])
export_graphviz(clf_gini, out_file=graphviz_gini, filled=True, rounded=True, special_characters=True, feature_names=X_train.columns)


# In[9]:


# Prediction using gini
y_pred_gini = utils.prediction(X_test, clf_gini)
print("Results for gini algo")
utils.cal_accuracy(y_test, y_pred_gini)


# In[10]:


# Train using entropy
clf_entropy = utils.tarin_using_entropy(X_train, y_train)
# print(clf_entropy)
export_graphviz(clf_entropy, out_file=graphviz_entropy, filled=True, rounded=True, special_characters=True, feature_names=X_train.columns)


# In[14]:


# Prediction using entropy
y_pred_entropy = utils.prediction(X_test, clf_entropy)
print("Results for entropy algo")
utils.cal_accuracy(y_test, y_pred_entropy)



# coding: utf-8

# In[13]:


import sklearn_dt_utils as utils
from sklearn.tree import export_graphviz
import os


# In[14]:


q_src_dir = os.getenv('Q_SRC_ROOT')
if not q_src_dir:
    print("'Q_SRC_ROOT' is not set")
    exit(-1)
csv_file_path = "%s/ML/KNN/data/titanic/titanic_train.csv" % q_src_dir

csv_file_path = "/root/WORK/Q/ML/KNN/data/titanic/titanic_train.csv"
graphviz_gini = "graphviz_gini.txt"
graphviz_entropy = "graphviz_entropy.txt"
goal_col_name = "Survived"
split_ratio = 0.5


# In[15]:


print("Dataset shape")
data = utils.import_data(csv_file_path)


# In[16]:


X, Y, X_train, X_test, y_train, y_test = utils.split_dataset(data, goal_col_name, split_ratio)


# In[17]:


#print(len(X.columns))


# In[18]:


#print(len(data.columns))


# In[19]:


# cross validation
utils.cross_validate_dt_new(X, Y)


# In[20]:


# cross validation
# utils.cross_validate_dt(X, Y)


# In[21]:


# Train using gini
clf_gini = utils.train_using_gini(X_train, y_train)
# print(X_train[1])
export_graphviz(clf_gini, out_file=graphviz_gini, filled=True, rounded=True, special_characters=True, feature_names=X_train.columns)


# In[22]:


# Prediction using gini
y_pred_gini = utils.prediction(X_test, clf_gini)
print("Results for gini algo")
utils.cal_accuracy(y_test, y_pred_gini)


# In[23]:


# Train using entropy
clf_entropy = utils.tarin_using_entropy(X_train, y_train)
export_graphviz(clf_entropy, out_file=graphviz_entropy, filled=True, rounded=True, special_characters=True, feature_names=X_train.columns)


# In[24]:


# Prediction using entropy
y_pred_entropy = utils.prediction(X_test, clf_entropy)
print("Results for entropy algo")
utils.cal_accuracy(y_test, y_pred_entropy)


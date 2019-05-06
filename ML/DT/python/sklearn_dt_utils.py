import numpy as np
import pandas as pd
import pickle
# from sklearn.cross_validation import train_test_split, cross_val_score
from sklearn.model_selection import cross_validate, train_test_split
from sklearn.tree import DecisionTreeClassifier
from sklearn.metrics import confusion_matrix
from sklearn.metrics import accuracy_score
from sklearn.metrics import classification_report
from sklearn.tree import export_graphviz
from sklearn.model_selection import GridSearchCV


# Serialize model
def save(clf, pickle_path=None):
    pickle_dump = pickle.dumps(clf)
    if not pickle_path:
        return pickle_dump
    with open(pickle_path, "w") as f:
        f.write(pickle_dump)


# Deserialize model with pickle dump
def restore_dump(pickle_dump):
    return pickle.loads(pickle_dump)


# Deserialize model with pickle file path
def restore(pickle_path):
    pickle_dump = None
    with open(pickle_path, "r") as f:
        pickle_dump = f.read()
    clf = restore_dump(pickle_dump)
    return clf

# Function importing Dataset
def import_data(csv_file):
    data = pd.read_csv(csv_file, sep= ',')

    # Printing the dataswet shape
    print("=================================================")
    print ("Dataset Lenght: ", len(data))
    print ("Dataset Shape: ", data.shape)
    print("=================================================")

    # Printing the dataset obseravtions
    # print ("Dataset: ", data.head())
    return data


# Function to split the dataset
def split_dataset(data, goal_index, split_ratio, random_state=None):

    # Seperating the target variable
    Y = data[goal_index]
    data = data.drop([goal_index], axis=1)
    X = data

    if split_ratio >= 1:
        return X, Y, X, None, Y, None
    # Spliting the dataset into train and test
    X_train, X_test, y_train, y_test = train_test_split(
    X, Y, test_size = split_ratio, random_state=random_state)
    
    return X, Y, X_train, X_test, y_train, y_test


# Function to perform training with giniIndex.
def train_using_gini(X_train, y_train):

    # Creating the classifier object
    clf_gini = DecisionTreeClassifier(criterion = "gini",
            random_state = 100, max_depth=5, min_samples_leaf=5)
    
    # Performing training
    clf_gini.fit(X_train, y_train)
    return clf_gini


# Function to perform training with entropy.
def tarin_using_entropy(X_train, y_train):

    # Decision tree with entropy
    clf_entropy = DecisionTreeClassifier(
            criterion = "entropy", random_state = 100,
            max_depth = 5, min_samples_leaf = 5)

    # Performing training
    clf_entropy.fit(X_train, y_train)
    return clf_entropy


# Function to make predictions
def prediction(X_test, clf_object):

    # Predicton on test with giniIndex
    y_pred = clf_object.predict(X_test)
    return y_pred


# Function to calculate accuracy
def cal_accuracy(y_test, y_pred):
    """
    y_test = y_test.tolist()
    y_pred = y_pred.tolist()
    mis_match = 0
    for i in range(len(y_test)):
        if i == 14 or i == 93:
            print("mismatch", i, y_test[i], y_pred[i])
        if y_test[i] != y_pred[i]:
            mis_match += 1
            print(mis_match, i, y_test[i], y_pred[i])
    """
    print("=================================================")
    print("\nConfusion Matrix:")
    print(confusion_matrix(y_test, y_pred))

    print ("\nAccuracy : ")
    print(accuracy_score(y_test,y_pred)*100)

    print("\nReport : ")
    print(classification_report(y_test, y_pred))
    print("=================================================")
    

# cross validate dt using cross_val_score
"""
def cross_validate_dt(x, y):
    depth = []
    for i in range(3,20):
        clf = DecisionTreeClassifier(max_depth=i)
        # Perform 7-fold cross validation
        # scores = cross_val_score(estimator=clf, X=x, y=y, cv=7, n_jobs=4)
        scores = cross_val_score(estimator=clf, X=x, y=y, cv=5,scoring='f1')
        depth.append((i, scores.mean()))
    print("=================================================")
    print("cross validation result for different depth value is")
    for val in depth:
        print(val)
    print("=================================================")
"""


# cross validate dt using cross_validate
def cross_validate_dt_new(x, y):
    depth = []
    scoring = ['precision_macro', 'recall_macro']
    for i in range(3, 10):
        clf = DecisionTreeClassifier(max_depth=i)
        # Perform 7-fold cross validation
        # scores = cross_val_score(estimator=clf, X=x, y=y, cv=7, n_jobs=4)
        scores = cross_validate(estimator=clf, X=x, y=y, cv=5, return_train_score=False, scoring=scoring)
        depth.append((i, scores['test_recall_macro']))
    print("=================================================")
    print("cross validation result for different depth value is")
    for val in depth:
        print(val)
    print("=================================================")

# GridSearchCV
def grid_search_cv(X_train, y_train, param_grid=None, clf=None, cv=10, scoring_method="accuracy"):
    if not clf:
        clf = DecisionTreeClassifier(random_state=100)
    if not param_grid:
        param_grid = { "max_depth" : [ 1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20 ],
        "min_samples_split" : [ 5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20 ],
        "min_samples_leaf" : [ 1, 2, 3, 4, 5],
        "criterion" : ['gini','entropy'] }

    # instantiate the grid
    grid = GridSearchCV(clf, param_grid, cv=cv, scoring=scoring_method)

    # fit the grid with data
    grid.fit(X_train, y_train)
    return grid

if __name__ == "__main__":
    data = import_data(csv_file_path)
    X, Y, X_train, X_test, y_train, y_test = split_dataset(data, goal_col_name)
    # print(len(X[1]))
    # print(len(data.columns))

    # cross validation
    # cross_validate_dt_new(X, Y)

    # cross validation
    cross_validate_dt(X, Y)

    # Train using gini
    clf_gini = train_using_gini(X_train, y_train)
    # print(X_train[1])
    export_graphviz(clf_gini, out_file=graphviz_gini, filled=True, rounded=True, special_characters=True)

    # Prediction using gini
    y_pred_gini = prediction(X_test, clf_gini)
    # print(y_pred_gini.shape)
    print("gini algorithm result is")
    cal_accuracy(y_test, y_pred_gini)

    # Train using entropy
    clf_entropy = tarin_using_entropy(X_train, y_train)
    # print(clf_entropy)
    export_graphviz(clf_entropy, out_file=graphviz_entropy)

    # Prediction using entropy
    y_pred_entropy = prediction(X_test, clf_entropy)
    print("entropy algorithm result is")
    cal_accuracy(y_test, y_pred_entropy)


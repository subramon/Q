import numpy as np
from sklearn import tree
import time

num_features = 32
min_leaf_size = 64
num_instances = 65536
min_partition_size = min_leaf_size
max_num_nodes_dt = num_instances / min_leaf_size

np.random.seed(5)
data = np.random.uniform(size = (num_instances, num_features))
print(data.shape)

goal = np.random.choice(np.array([0,1]), size=(num_instances, 1))

def run_experiment():
   start = time.time()
   clf = tree.DecisionTreeClassifier(random_state = 0, min_samples_split = min_leaf_size)
   model = clf.fit(data, goal)
   end = time.time()
   return end - start, model.tree_.node_count

nodes = 0.0
total_time = 0.0
num_trials = 1
for i in range(num_trials):
   t, nn = run_experiment()
   total_time += t
   nodes += nn
print("average time to train: ", total_time/num_trials)
print("average number of nodes in trained tree: ", nn/(1.0*num_trials))
print()

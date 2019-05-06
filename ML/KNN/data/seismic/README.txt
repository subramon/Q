run run_knn_sklearn.sh, which will give you a new csv with predictions out. It
will be smaller than the original (only predicting on test data), and will have
3 columns (pred_5_nn, pred_15_nn, pred_100_nn). The dataset comes from
https://archive.ics.uci.edu/ml/datasets/seismic-bumps and has been
one-hot-encoded and scaled to have mean 0 and variance 1 (edited)

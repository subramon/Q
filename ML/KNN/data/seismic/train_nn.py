import numpy as np
import pandas as pd
from sklearn.preprocessing import scale
from sklearn.model_selection import train_test_split
from sklearn.neighbors import KNeighborsClassifier

DS_FN = 'seismic_bumps_ds_postprocessed.csv'
RESULT = 'seismic_bumps_ds_test.csv'


if __name__ == '__main__':
	np.random.seed(123)
	trnx = pd.read_csv(DS_FN)
	train, test = train_test_split(trnx, test_size=0.5, random_state=123)
	trnx['train_test'] = 0
	trnx.loc[train.index, 'train_test'] = 1
	trnx['y'] = trnx['y'].apply(lambda x: x == 1)
	trnx.to_csv(DS_FN, index=None)
	nn_5 = KNeighborsClassifier(n_neighbors=5)
	nn_5.fit(
		X=trnx.loc[trnx['train_test']==1, trnx.columns[:25]],
		y=trnx.loc[trnx['train_test']==1, trnx.columns[25]])
	nn_15 = KNeighborsClassifier(n_neighbors=15)
	nn_15.fit(
		X=trnx.loc[trnx['train_test']==1, trnx.columns[:25]],
		y=trnx.loc[trnx['train_test']==1, trnx.columns[25]])
	
	nn_100 = KNeighborsClassifier(n_neighbors=100)
	nn_100.fit(
		X=trnx.loc[trnx['train_test']==1, trnx.columns[:25]],
		y=trnx.loc[trnx['train_test']==1, trnx.columns[25]])

	test['preds_5_nn'] = nn_5.predict_proba(test.iloc[:, :25])[:, 1]
	test['preds_15_nn'] = nn_15.predict_proba(test.iloc[:, :25])[:, 1]
	test['preds_100_nn'] = nn_100.predict_proba(test.iloc[:, :25])[:, 1]

	test.to_csv(RESULT, index=None)
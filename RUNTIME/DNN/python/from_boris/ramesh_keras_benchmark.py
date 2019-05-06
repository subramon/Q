import datetime
import numpy as np

from keras.layers import Dense
from keras.models import Sequential

from sklearn.preprocessing import MinMaxScaler


def clock_keras_model():
    np.random.seed(42)

    x = np.random.randn(128 * 1024**2).reshape((1024**2, 128))
    print(x.shape)
    scaler = MinMaxScaler()
    x = scaler.fit_transform(x)
    y = np.random.randint(0, 2, 1024 ** 2)
    y = y.reshape((1024 ** 2, 1))

    for batch_size in [2 ** x for x in range(14, 17)]:
        model = Sequential()
        model.add(Dense(64, input_dim=x.shape[1], activation='relu'))
        model.add(Dense(32, activation='relu'))
        model.add(Dense(16, activation='relu'))
        model.add(Dense(8, activation='relu'))
        model.add(Dense(4, activation='relu'))
        model.add(Dense(2, activation='relu'))
        model.add(Dense(1, activation='sigmoid'))
        model.compile(
            loss='binary_crossentropy', optimizer='sgd')

        start_time = datetime.datetime.now()
        history = model.fit(
            x, y,
            epochs=1,
            batch_size=batch_size)
        t = datetime.datetime.now() - start_time
        print('Train time for batch size %s: %s' % (batch_size, t))

    start_time = datetime.datetime.now()
    y_hat = model.predict(x)
    t = datetime.datetime.now() - start_time
    print('Predict time:', t)


if __name__ == '__main__':
    clock_keras_model()

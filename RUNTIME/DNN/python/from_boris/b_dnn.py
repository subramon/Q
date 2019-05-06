import h5py
import numpy as np
import pandas as pd

from PIL import Image
from sklearn.datasets import make_blobs
from sklearn.metrics import log_loss
from sklearn.preprocessing import MinMaxScaler


# ----------------------------------------------------------------------
# Preprocess data
# ----------------------------------------------------------------------

def get_data(debug=False):
    train_dataset = h5py.File('./data/train_cat_vs_noncat.h5', 'r')
    train_x_orig = np.array(train_dataset['train_set_x'][:])
    train_y_orig = np.array(train_dataset['train_set_y'][:])

    test_dataset = h5py.File('./data/test_cat_vs_noncat.h5', 'r')
    test_x_orig = np.array(test_dataset['test_set_x'][:])
    test_y_orig = np.array(test_dataset['test_set_y'][:])

    if debug:
        Image.fromarray(train_x_orig[2]).show()

    classes = np.array(test_dataset['list_classes'][:])

    # reshape from (209,) to row vectors (1, 209)
    train_y = train_y_orig.reshape((1, train_y_orig.shape[0]))
    test_y = test_y_orig.reshape((1, test_y_orig.shape[0]))

    num_px = train_x_orig.shape[1]

    print('Dataset dimensions:')
    print('Number of training examples:', train_x_orig.shape[0])
    print('Number of testing examples:', test_x_orig.shape[0])
    print('Images height and width:', num_px)
    print('Image size: (%s, %s, 3)' % (num_px, num_px))
    print('train_x shape:', train_x_orig.shape)
    print('train_y shape:', train_y.shape)
    print('test_x shape:', test_x_orig.shape)
    print('test_y shape:', test_y.shape)
    print('classes:', classes)

    # reshape images from (num_px, num_px, 3) to (num_px * num_px * 3, 1)
    train_x_flatten = train_x_orig.reshape(train_x_orig.shape[0], -1).T
    test_x_flatten = test_x_orig.reshape(test_x_orig.shape[0], -1).T

    print('train_x_flatten shape:', train_x_flatten.shape)
    print('train_y shape:', train_y.shape)
    print('test_x_flatten shape:', test_x_flatten.shape)
    print('test_y shape:', test_y.shape)
    print('sanity check after reshaping:', train_x_flatten[0:5, 0])

    # standardize data
    train_x = train_x_flatten / 255.
    test_x = test_x_flatten / 255.

    return train_x, train_y, test_x, test_y


# ----------------------------------------------------------------------
# Define model
# ----------------------------------------------------------------------

def init_params(layers_dims):
    """
    Arguments:
        layers_dims -- list with layers dimensions

    Returns:
        parameters -- dictionary with "w1", "b1", ..., "wn", "bn":
                wi -- weight matrix of shape (l_dims[i], l_dims[i-1])
                bi -- bias vector of shape (layer_dims[i], 1)
    """
    params = {}
    for n in range(1, len(layers_dims)):
        w = 'w%s' % n
        params[w] = np.random.randn(
            layers_dims[n], layers_dims[n-1])
        params[w] /= np.sqrt(layers_dims[n-1])
        b = 'b%s' % n
        params[b] = np.zeros((layers_dims[n], 1))
        assert params[w].shape == (layers_dims[n], layers_dims[n - 1])
        assert params[b].shape == (layers_dims[n], 1)
    return params


# ----------------------------------------------------------------------
# Forward propagation
# ----------------------------------------------------------------------

def sigmoid(z):
    """
    Implements sigmoid activation

    Arguments:
        z -- numpy array, shape (k, 1)

    Returns:
        a -- output of sigmoid(z), same shape as z
        cache -- contains z for efficient backprop
    """
    a = 1 / (1 + np.exp(-z))
    assert a.shape == z.shape
    return a, z


def relu(z):
    """
    Implements ReLU activation.

    Arguments:
        z -- output of a dense layer, shape (k, 1)

    Returns:
        a -- output of relu(z), same shape as z
        cache -- contains z for efficient backprop
    """
    a = np.maximum(0, z)
    assert a.shape == z.shape
    return a, z


def softmax(z):
    """Computes softmax for array of scores.

    Arguments:
        z -- output of a dense layer, shape (k, 1)

    Returns:
        a -- post-activation vector, same shape as z
        cache -- contains z for efficient backprop

    Theory:
        e^y_i / sum(e^y_j), for j = 0..(len(z)-1)
        https://stackoverflow.com/questions/34968722

    Example:
        z = np.array([[5], [2], [-1], [3]])
        a = np.exp(z) / np.exp(z).sum()
        [[0.84203357], [0.04192238], [0.00208719], [0.11395685]]
        assert np.isclose(a.sum(), 1)
    """
    a = np.exp(z) / np.exp(z).sum(axis=0)
    assert z.shape[1] == sum(np.isclose(a.sum(axis=0), 1))
    # to predict use
    # a = (a >= 0.5).astype(np.int)
    return a, z


def dense_layer_propagate(a, w, b):
    """
    Implements dense layer forward propagation.

    Arguments:
        a -- activations from previous layer (or input data):
            (size of previous layer, number of examples)
        w -- weights matrix: (size of current layer, size of previous layer)
        b -- bias vector (size of the current layer, 1)

    Returns:
        z -- the input of the activation function, aka pre-activation parameter
        cache -- dictionary with "a", "w" and "b"
            stored for computing the backward pass efficiently
    """
    z = np.dot(w, a) + b
    assert z.shape == (w.shape[0], a.shape[1])
    return z, (a, w, b)


def dense_activation_propagate(a_prev, w, b, activation):
    """
    Implements forward propagation for a dense-activation layer

    Arguments:
        a_prev -- activations from previous layer:
            (size of previous layer, number of examples)
        w -- weights (size of curr layer, size of prev layer)
        b -- bias vector (size of the current layer, 1)
        activation -- 'sigmoid', 'relu', 'softmax'

    Returns:
        a -- also called the post-activation value
        cache -- for computing the backward pass efficiently
    """

    z, dense_cache = dense_layer_propagate(a_prev, w, b)
    if activation == 'sigmoid':
        a, activation_cache = sigmoid(z)
    elif activation == 'relu':
        a, activation_cache = relu(z)
    elif activation == 'softmax':
        a, activation_cache = softmax(z)
    # a_prev.shape[1] gives the number of examples
    assert (a.shape == (w.shape[0], a_prev.shape[1]))
    return a, (dense_cache, activation_cache)


def foreword_propagate(x, params, activation, y_dim):
    """
    Implements forward propagation for dense-relu * (n-1) -> dense-sigmoid

    Arguments:
        x -- data, array of shape (input size, number of examples)
        parameters -- output of init_parameters()
        activation -- activation function for last layer

    Returns:
        al -- last post-activation value
        caches -- list containing:
            caches of dense-relu with size n-1 indexed from 0 to n-2
            cache of dense-sigmoid indexed n-1
    """
    caches = []
    a = x
    n_layers = len(params) // 2  # number of layers

    print('-' * 40)

    # implements linear-relu * (l-1)
    # adds cache to the caches list
    for i in range(1, n_layers):
        a_prev = a
        wi = params['w' + str(i)]
        bi = params['b' + str(i)]
        a, cache = dense_activation_propagate(a_prev, wi, bi, activation='relu')
        print('layer:', i)
        print('z:', cache)
        print('a:', a)
        print('-' * 40)
        caches.append(cache)

    # implements linear-sigmoid or linear-softmax
    # adds cache to the caches list
    wi = params['w%s' % n_layers]
    bi = params['b%s' % n_layers]
    y_hat, cache = dense_activation_propagate(a, wi, bi, activation=activation)
    print('output layer:')
    print('z:', cache)
    print('a:', y_hat)
    print('-' * 40)
    caches.append(cache)
    assert (y_hat.shape == (y_dim, x.shape[1]))

    return y_hat, caches


# ----------------------------------------------------------------------
# Compute cost -- log_loss
# ----------------------------------------------------------------------

def comp_cost(y_hat, y, activation, epsilon=1e-15):
    """
    Computes x-entropy cost function.

    Arguments:
        y_hat -- probability vector (model predictions), shape: (1, # examples)
        y -- true "label" vector
        activation -- activation function for last layer

    Returns:
        cost -- cross-entropy cost

    Note: experimental, use sklearn.metrics.log_loss instead
    """
    if activation == 'sigmoid':
        m = y.shape[1]
        cost = np.dot(y, np.log(y_hat).T) + np.dot((1 - y), np.log(1 - y_hat).T)
        cost = (-1. / m) * cost
        cost = np.squeeze(cost)  # turns [[17]] into 17).
        assert (cost.shape == ())
    elif activation == 'softmax':
        """
        Computes x-entropy between y (encoded as one-hot vectors) and y_hat.
        
        Arguments:
            y_hat -- predictions, array (n, k), (# of examples, # of categories)
            y -- true 'label' np.array (n, k) (# of examples, # of categories)
    
        Returns:
            cost -- categorical cross entropy cost
    
        Algorithm:
            -1./N * sum_i(sum_j t_ij * log(p_ij)), i=1..len(y), j=1..k
    
            y_hat = np.clip(y_hat, epsilon, 1. - epsilon)
            -np.sum(y * np.log(y_hat + epsilog)) / y_hat.shape[0]        
        """
        cost = log_loss(y, y_hat)
    else:
        raise AttributeError('Unexpected activation function:', activation)
    return cost


# ----------------------------------------------------------------------
# Back propagate
# ----------------------------------------------------------------------

def sigmoid_back_propagate(da, cache):
    """
    Implements back propagation for a single sigmoid unit.

    Arguments:
        da -- post-activation gradient, of any shape
        cache -- (z,) from the forward propagate of curr layer

    Returns:
        dz -- gradient of cost wrt z
    """
    z = cache
    s = 1 / (1 + np.exp(-z))
    dz = da * s * (1 - s)
    assert (dz.shape == z.shape)
    assert (da.shape == z.shape)
    return dz


def softmax_back_propagate(da, cache):
    """
    Implements back propagation for a softmax unit.

    Arguments:
        da -- post-activation gradient, of any shape
        cache -- (z,) from the forward propagate of curr layer

    Returns:
        dz -- gradient of cost wrt z
    """
    z = cache
    y_hat = np.exp(z) / np.exp(z).sum()
    dz = da * (1 - y_hat)
    assert (dz.shape == z.shape)
    return dz


def relu_back_propagate(da, cache):
    """
    Implements back propagate for a single relu unit.

    Arguments:
        da -- post-activation gradient, of any shape
        cache -- (z,) from forward propagattion of curr layer

    Returns:
        dz -- gradient cost wrt z
    """
    z = cache
    dz = np.array(da, copy=True)  # converting dz to correct type
    # when z <= 0, set dz to 0
    dz[z <= 0] = 0.
    assert (dz.shape == z.shape)
    return dz


def dense_back_propagate(dz, cache):
    """
    Implements dense layer back propagation.

    Arguments:
        dz -- gradient of cost wrt output of curr layer
        cache -- (a_prev, w, b) from forward propagate in current layer

    Returns:
        da_prev -- gradient of cost wrt prev layer activation, shape as a_prev
        dw -- gradient of cost wrt curr layer w, shape as w
        db -- gradient of cost wrt b, shape as b
    """
    a_prev, w, b = cache
    m = a_prev.shape[1]
    dw = (1. / m) * np.dot(dz, a_prev.T)
    db = (1. / m) * np.sum(dz, axis=1, keepdims=True)
    da_prev = np.dot(w.T, dz)
    assert (da_prev.shape == a_prev.shape)
    assert (dw.shape == w.shape)
    assert (db.shape == b.shape)
    return da_prev, dw, db


def dense_activation_back_propagate(da, cache, activation):
    """
    Back propagation for a dense-activation layer.

    Arguments:
        da -- post-activation gradient for current layer l
        cache -- tuple of values (linear_cache, activation_cache)
        a -- activation as string: 'sigmoid', 'relu', or 'softmax'

    Returns:
        da_prev -- gradient of cost wrt the activation
            of the previous layer l-1, same shape as a_prev
        dw -- gradient of cost wrt w (current layer l), same shape as w
        db -- Gradient of cost wrt b (current layer l), same shape as b
    """
    dense_cache, a_cache = cache
    if activation == 'relu':
        dz = relu_back_propagate(da, a_cache)
    elif activation == 'sigmoid':
        dz = sigmoid_back_propagate(da, a_cache)
    elif activation == 'softmax':
        dz = da  # softmax_back_propagate(da, a_cache)
    da_prev, dw, db = dense_back_propagate(dz, dense_cache)
    return da_prev, dw, db


def back_propagate(y_hat, y, caches, activation):
    """
    Implements backprop for linear-relu * (n-1) -> linear-sigmoid model.

    Arguments:
        al -- probability prediction vector, output of l_model_forward()
        y -- true "label" vector
        caches -- list of caches containing:
            every cache from foreword_propagate

    Returns:
        grads -- dictionary with the gradients:
                 grads['dai'], grads['dwi'], grads['dbi'] for i in (n-1..0)
    """
    y = y.reshape(y_hat.shape)
    grads = {}

    if activation == 'sigmoid':
        # derivative of cost wrt output activation for binary classifier
        da = - (np.divide(y, y_hat) - np.divide(1 - y, 1 - y_hat))
    elif activation == 'softmax':
        # for multi class classifier, unlike sigmoid,
        # do not compute the derivative of cost
        # wrt output activation
        # but the derivative of cost wrt input of softmax
        da = y_hat - y
    else:
        raise ValueError('Unexpected activation function:', activation)

    # i-th layer sigmoid-dense gradients
    # inputs: ai, y, caches
    # outputs: grads['dai'], grads['dwi'], grads['dbi']

    n = len(caches)
    c = caches[n-1]
    grads['da%s' % n], grads['dw%s' % n], grads['db%s' % n] = (
        dense_activation_back_propagate(da, c, activation=activation))

    for i in reversed(range(n - 1)):
        c = caches[i]
        da_prev_temp, dw_temp, db_temp = dense_activation_back_propagate(
            grads['da%s' % (i+2)], c, activation="relu")
        grads['da%s' % (i+1)] = da_prev_temp
        grads['dw%s' % (i+1)] = dw_temp
        grads['db%s' % (i+1)] = db_temp

    return grads


def update_parameters(params, grads, alpha):
    """
    Updates model parameters using gradient descent.

    Arguments:
        params -- dictionary containing model parameters
        grads -- dictionary with gradients, output of L_model_backward()

    Returns:
        params -- dictionary with updated parameters
            params['w' + str(l)] = ...
            params['b' + str(l)] = ...
    """
    n_layers = len(params) // 2
    for i in range(n_layers):
        params['w%s' % (i+1)] = (
                params['w%s' % (i+1)] - alpha * grads['dw%s' % (i+1)])
        params['b%s' % (i+1)] = (
                params['b%s' % (i+1)] - alpha * grads['db%s' % (i+1)])
    return params


def sequential_model(
        x, y, layers_dims, alpha=0.0075, n_iters=3000, debug=False):
    """
    Implements a multilayer NN: linear-relu*(l-1)->linear-sigmoid.

    Arguments:
        x -- input data, shape (# of examples, num_px * num_px * 3)
        y -- true "label" vector, shape (1, number of examples)
        layers_dims -- list with input and layer sizes of length 
            (# of layers + 1).
        alpha -- learning rate of the gradient descent update rule
        n_iters -- number of iterations of the optimization loop
        debug -- if True, prints cost every 100 steps

    Returns:
        params -- learned parameters used for prediction
    """
    costs = []
    params = init_params(layers_dims)
    activation = 'sigmoid' if y.shape[0] == 1 else 'softmax'

    # gradient descent loop
    for i in range(0, n_iters):
        ai, caches = foreword_propagate(x, params, activation, layers_dims[-1])
        cost = comp_cost(ai, y, activation)
        grads = back_propagate(ai, y, caches, activation)
        params = update_parameters(params, grads, alpha)
        if debug and i % 100 == 0:
            print('Cost after iteration %i: %f' % (i, cost))
        if debug and i % 100 == 0:
            costs.append(cost)

    def plot_cost():
        return True
        # plt.plot(np.squeeze(costs))
        # plt.ylabel('cost')
        # plt.xlabel('iterations (per tens)')
        # plt.title('Learning rate =' + str(learning_rate))
        # plt.show()

    if debug:
        plot_cost()
    return params


def test_dnn():
    layers_dims = [10, 4, 2, 1]

    np.random.seed(42)
    x = np.random.randn(30).reshape((10, 3))
    scaler = MinMaxScaler()
    x = scaler.fit_transform(x)
    print('x shape:', x.shape)
    # (10, 3)

    y = np.random.randint(0, 2, 3)
    y = y.reshape((1, 3))
    print('y shape:', y.shape)
    # (1, 3)

    params = init_params(layers_dims)
    activation = 'sigmoid'
    y_hat, caches = foreword_propagate(x, params, activation, layers_dims[-1])
    print(y_hat)

    '''
    x = array([[ 0.49671415, -0.1382643 ,  0.64768854],
       [ 1.52302986, -0.23415337, -0.23413696],
       [ 1.57921282,  0.76743473, -0.46947439],
       [ 0.54256004, -0.46341769, -0.46572975],
       [ 0.24196227, -1.91328024, -1.72491783],
       [-0.56228753, -1.01283112,  0.31424733],
       [-0.90802408, -1.4123037 ,  1.46564877],
       [-0.2257763 ,  0.0675282 , -1.42474819],
       [-0.54438272,  0.11092259, -1.15099358],
       [ 0.37569802, -0.60063869, -0.29169375]])

    y = array([[1, 0, 1]])
    
    params = {
    'b1': array([[0.],
       [0.],
       [0.],
       [0.]]),
    'b2': array([[0.],
       [0.]]),
    'b3': array([[0.]]),
    'w1': array([[ 0.17511345, -0.47971962, -0.30251271, -0.32758364, -0.15845926,
         0.13971159, -0.25937964,  0.21091907,  0.04563044,  0.23632542],
       [-0.10095298, -0.19570727,  0.34871516, -0.58248266,  0.12900959,
         0.29941416,  0.1690164 , -0.06477899, -0.08915248,  0.00968901],
       [-0.22156274,  0.21357835,  0.02842162, -0.19919548,  0.33684907,
        -0.21418677,  0.44400973, -0.39859007, -0.13523984, -0.05911348],
       [-0.72570658,  0.19094223, -0.05694645,  0.05892507,  0.04916247,
        -0.04978276, -0.14645337,  0.20778173, -0.4079519 , -0.04742307]]),
    'w2': array([[-0.32146246,  0.11706767, -0.18786398,  0.20685326],
       [ 0.61687454, -0.21195547,  0.51735934, -0.35066345]]),
    'w3': array([[ 0.6328142 , -1.27748553]])}

    layer: 1
        z: ((array([[ 0.49671415, -0.1382643 ,  0.64768854],
               [ 1.52302986, -0.23415337, -0.23413696],
               [ 1.57921282,  0.76743473, -0.46947439],
               [ 0.54256004, -0.46341769, -0.46572975],
               [ 0.24196227, -1.91328024, -1.72491783],
               [-0.56228753, -1.01283112,  0.31424733],
               [-0.90802408, -1.4123037 ,  1.46564877],
               [-0.2257763 ,  0.0675282 , -1.42474819],
               [-0.54438272,  0.11092259, -1.15099358],
               [ 0.37569802, -0.60063869, -0.29169375]]), array([[ 0.17511345, -0.47971962, -0.30251271, -0.32758364, -0.15845926,
                 0.13971159, -0.25937964,  0.21091907,  0.04563044,  0.23632542],
               [-0.10095298, -0.19570727,  0.34871516, -0.58248266,  0.12900959,
                 0.29941416,  0.1690164 , -0.06477899, -0.08915248,  0.00968901],
               [-0.22156274,  0.21357835,  0.02842162, -0.19919548,  0.33684907,
                -0.21418677,  0.44400973, -0.39859007, -0.13523984, -0.05911348],
               [-0.72570658,  0.19094223, -0.05694645,  0.05892507,  0.04916247,
                -0.04978276, -0.14645337,  0.20778173, -0.4079519 , -0.04742307]]), array([[0.],
               [0.],
               [0.],
               [0.]])), array([[-1.16416195,  0.41311912,  0.03543866],
               [-0.33736273, -0.2115404 ,  0.39936218],
               [ 0.09221453, -0.96629303,  0.62912924],
               [ 0.20260571,  0.14508069, -0.64319486]]))
        a: [[0.         0.41311912 0.03543866]
         [0.         0.         0.39936218]
         [0.09221453 0.         0.62912924]
         [0.20260571 0.14508069 0.        ]]
    ----------------------------------------

    layer: 2
        z: ((array([[0.        , 0.41311912, 0.03543866],
               [0.        , 0.        , 0.39936218],
               [0.09221453, 0.        , 0.62912924],
               [0.20260571, 0.14508069, 0.        ]]), array([[-0.32146246,  0.11706767, -0.18786398,  0.20685326],
               [ 0.61687454, -0.21195547,  0.51735934, -0.35066345]]), array([[0.],
               [0.]])), array([[ 0.02458586, -0.10279187, -0.08283052],
               [-0.02333837,  0.20396817,  0.26270009]]))
        a: [[0.02458586 0.         0.        ]
         [0.         0.20396817 0.26270009]]
    ----------------------------------------

    output layer:
        z: ((array([[0.02458586, 0.        , 0.        ],
               [0.        , 0.20396817, 0.26270009]]), array([[ 0.6328142 , -1.27748553]]), array([[0.]])), array([[ 0.01555828, -0.26056638, -0.33559556]]))
        a: [[0.50388949 0.43522448 0.41687976]]
    ----------------------------------------    

    y_hat = array([[0.50388949, 0.43522448, 0.41687976]])
        
    '''


if __name__ == '__main__':
    np.random.seed(1)
    train_x, train_y, test_x, test_y = get_data()
    if False:
        layers_dims = [12288, 20, 7, 5, 2]
        df = pd.DataFrame(data=train_y[0], columns=['yt'])
        df['yc'] = 1 - df.yt
        train_y = df.values.T
        print(train_y.shape)
    else:
        layers_dims = [12288, 20, 7, 5, 1]

    fit_params = sequential_model(
        train_x, train_y, layers_dims, n_iters=2500, debug=True)

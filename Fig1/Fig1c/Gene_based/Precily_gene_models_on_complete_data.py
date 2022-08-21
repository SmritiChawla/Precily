##Import libraries
import numpy as np
import pandas as pd
import keras_tuner as kt
import tensorflow as tf
from tensorflow import keras
from sklearn.metrics import r2_score
from sklearn.metrics import mean_squared_error


tf.config.threading.set_inter_op_parallelism_threads(1)
tf.config.threading.set_intra_op_parallelism_threads(1)
np.random.seed(2)

project_name = 'Genes'
layers_range = (2, 6)
units_range = (128, 256, 4)
lr_values = [1e-3,1e-4,1e-5]

train = pd.read_csv("Train_data_genes.csv")
X_train = train.iloc[: , 2:-1]
Y_train = train.iloc[: , -1:]

##Load pre-trained hyper tuned models
for i in range(5):
    h_model = tf.keras.models.load_model('precily_cv_'+str(i+1)+'.hdf5')
    h_model.fit(X_train, Y_train, verbose = 1, epochs=50, batch_size = 128)

    h_model.save('Model'+str(i+1)+'.hdf5')
    h_model = None


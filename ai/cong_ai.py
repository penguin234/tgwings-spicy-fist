import joblib
import pandas as pd
import math
import numpy as np

columns = ['1f_1', '1f_but', '2f_he', '2f_2', '1f_ele']

models = {}
for column in columns:
    model_filename = "ai/pkl/" + f"{column}_model.pkl"
    model = joblib.load(model_filename)
    models[column] = model

def load_and_predict(future_data, target_column):
    max_seats = {
    '1f_1': 410,
    '1f_but': 156,
    '2f_he': 187,
    '2f_2': 326,
    '1f_ele' : 47
    }

    future_data['datetime'] = pd.to_datetime(future_data['date'] + ' ' + future_data['time'])
    future_data['year'] = future_data['datetime'].dt.year
    future_data['month'] = future_data['datetime'].dt.month
    future_data['day'] = future_data['datetime'].dt.day
    future_data['hour'] = future_data['datetime'].dt.hour
    future_data['dayofweek'] = future_data['datetime'].dt.dayofweek
    future_X = future_data[['year', 'month', 'day', 'hour', 'dayofweek']]

    prediction = models[target_column].predict(future_X)
    
    predicted_seats = math.floor(prediction[0])
    
    max_seat = max_seats[target_column]
    congestion_rate = (predicted_seats / max_seat) * 100

    print(f"Loaded model for {target_column} predicts: {predicted_seats} seats")
    print(f"Congestion rate: {congestion_rate:.2f}%")


future_data1 = pd.DataFrame({
    'date': ['6/22/2025'],
    'time': ['20:30'],
})

future_data2 = pd.DataFrame({
    'date': ['3/10/2025'],
    'time': ['12:30'],
})

print("\nLoading models and making predictions:")

for target_column in ['1f_1', '1f_but', '2f_he', '2f_2', '1f_ele']:
    load_and_predict(future_data1, target_column)

for target_column in ['1f_1', '1f_but', '2f_he', '2f_2', '1f_ele']:
    load_and_predict(future_data2, target_column)
import joblib
import pandas as pd
import math

def load_and_predict(future_data):
    max_seats = {
    '1f_1_cong': 410,
    '1f_but_cong': 156,
    '2f_he_cong': 187,
    '2f_2_cong': 326
    }

    future_data['datetime'] = pd.to_datetime(future_data['date'] + ' ' + future_data['time'])
    future_data['year'] = future_data['datetime'].dt.year
    future_data['month'] = future_data['datetime'].dt.month
    future_data['day'] = future_data['datetime'].dt.day
    future_data['hour'] = future_data['datetime'].dt.hour
    future_data['dayofweek'] = future_data['datetime'].dt.dayofweek
    future_X = future_data[['year', 'month', 'day', 'hour', 'dayofweek']]

    model_filename = "ai/pkl/" + f"{target_column}_model.pkl"
    model = joblib.load(model_filename)
    prediction = model.predict(future_X)
    
    predicted_seats = math.floor(prediction[0])
    
    max_seat = max_seats[target_column]
    congestion_rate = (predicted_seats / max_seat) * 100

    print(f"Loaded model for {target_column} predicts: {predicted_seats} seats")
    print(f"Congestion rate: {congestion_rate:.2f}%")


future_data = pd.DataFrame({
    'date': ['4/10/2025'],
    'time': ['18:30'],
})

print("\nLoading models and making predictions:")
for target_column in ['1f_1_cong', '1f_but_cong', '2f_he_cong', '2f_2_cong']:
    load_and_predict(future_data)

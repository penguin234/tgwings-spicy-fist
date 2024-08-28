import joblib
import pandas as pd
import math
from fastapi import FastAPI

columns = ['1f_1', '1f_but', '2f_he', '2f_2', '1f_ele']
codetoc = {
    8: columns[0],
    10: columns[1],
    11: columns[2],
    9: columns[3],
    12: columns[4]
}

models = {}
for column in columns:
    model_filename = "ai/pkl/" + f"{column}_model.pkl"
    model = joblib.load(model_filename)
    models[column] = model
print('model loaded')

def load_and_predict(future_data, target_column):
    print('predict function call')

    max_seats = {
    columns[0]: 410,
    columns[1]: 156,
    columns[2]: 187,
    columns[3]: 326,
    columns[4]: 47
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

    return predicted_seats

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

app = FastAPI()
print('app made')

# date: YYYYDDMM
@app.get("/predict/{room}/{date}/{time}")
async def predict(room, date, time):
    year = int(date[0:4])
    month = int(date[4:6])
    day = int(date[6:8])
    target = pd.DataFrame({
        'date': [str(day) + '/' + str(month) + '/' + str(year)],
        'time': [time]
    })
    return {
        'predict': load_and_predict(target, codetoc[int(room)])
    }

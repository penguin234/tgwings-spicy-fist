import cv2
from ultralytics import YOLO
from fastapi import FastAPI
from datetime import datetime, timedelta
import requests
model = YOLO('ai/yolov8s.pt')

def process_camera():
    cap = cv2.VideoCapture(0)
    frame_interval = 5
    frame_count = 0
    last_person_detected = datetime.now()
    auto_exit_time = timedelta(minutes=1)
    exit_flag = False
    seat_number = 1
    while cap.isOpened():
        success, frame = cap.read()

        if success:
            if frame_count % frame_interval == 0:
                results = model(frame)
                person_detections = [det for det in results[0].boxes if det.cls == 0]

                if not person_detections:
                    last_person_detected = datetime.now()

                for det in person_detections:
                    x1, y1, x2, y2 = map(int, det.xyxy[0])
                    cv2.rectangle(frame, (x1, y1), (x2, y2), (0, 255, 0), 2)
                    cv2.putText(frame, "Person", (x1, y1 - 10), cv2.FONT_HERSHEY_SIMPLEX, 0.9, (0, 255, 0), 2)

                print(f"Number of people detected: {len(person_detections)}")

            if datetime.now() - last_person_detected > auto_exit_time:
                exit_flag = True
                print("No person detected for 30 minutes.")
            # 여기에서 API 호출
                url = "http://localhost:8080/seats/reserve/forcedoff"
                payload = {"seatNumber": seat_number}
                try:
                    response = requests.put(url, json=payload)
                    if response.status_code == 200:
                        print("Seat reservation was successfully cancelled.")
                    else:
                        print(f"Failed to cancel reservation: {response.status_code}, {response.text}")
                except Exception as e:
                    print(f"Error calling the API: {str(e)}")
                break

            frame_count += 1

            cv2.imshow("YOLOv8 Inference", frame)

            if cv2.waitKey(1) & 0xFF == ord("q"):
                break
        else:
            break

    cap.release()
    cv2.destroyAllWindows()

    return {
        len(person_detections),
        exit_flag
    }    

app = FastAPI()
print('app made')

process_camera()
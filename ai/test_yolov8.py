import cv2
from ultralytics import YOLO
import time

model = YOLO('ai/yolov8n.pt')

cap = cv2.VideoCapture(0)

frame_interval = 1
frame_count = 0

while cap.isOpened():
    success, frame = cap.read()

    if success:
        if frame_count % frame_interval == 0:
            results = model(frame)

            person_detections = [det for det in results[0].boxes if det.cls == 0]

            for det in person_detections:
                x1, y1, x2, y2 = map(int, det.xyxy[0])
                cv2.rectangle(frame, (x1, y1), (x2, y2), (0, 255, 0), 2)
                cv2.putText(frame, "Person", (x1, y1 - 10), cv2.FONT_HERSHEY_SIMPLEX, 0.9, (0, 255, 0), 2)

            print(f"Number of people detected: {len(person_detections)}")
            
            annotated_frame = frame
        else:
            annotated_frame = frame

        cv2.imshow("YOLOv8 Inference", annotated_frame)

        if cv2.waitKey(1) & 0xFF == ord("q"):
            break

        frame_count += 1
    else:
        break

    time.sleep(1)

cap.release()
cv2.destroyAllWindows()
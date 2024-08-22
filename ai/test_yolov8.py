import cv2
from ultralytics import YOLO

model = YOLO('yolov8n.pt')

cap = cv2.VideoCapture(0)

#프레임 조절
frame_interval = 5
frame_count = 0

while cap.isOpened() :
    success, frame = cap.read()

    if success:
        if frame_count % frame_interval == 0:
            results = model(frame)

            annotated_frame = results[0].plot()
        else:
            annotated_frame = frame

        cv2.imshow("YOLOv8 Inference", annotated_frame)
        if cv2.waitKey(1) & 0xFF == ord("q"):
            break

        frame_count += 1
    else:
        break

cap.release()
cv2.destroyAllWindows()
import time
import cv2
import matplotlib.pyplot as plt
import mediapipe as mp

cap = cv2.VideoCapture(0)

OUTPUT = True

try:
    with mp.solutions.holistic.Holistic(min_detection_confidence=0.5, min_tracking_confidence=0.5) as holistic:
        while cap.isOpened():
            ret, frame = cap.read()

            if cv2.waitKey(10) & 0xFF == ord('q'):
                break

            frame_rgb = cv2.cvtColor(frame, cv2.COLOR_BGR2RGB)
            t = time.time()
            results = holistic.process(frame_rgb)
            dt = time.time() - t

            print("dt=%f" % dt)
            if results.right_hand_landmarks is not None:
                l = results.right_hand_landmarks.landmark[8]
                print("x=%f, y=%f" % (l.x, l.y))

            if OUTPUT:
                mp.solutions.drawing_utils.draw_landmarks(frame, results.face_landmarks, mp.solutions.holistic.FACEMESH_CONTOURS)
                mp.solutions.drawing_utils.draw_landmarks(frame, results.pose_landmarks, mp.solutions.holistic.POSE_CONNECTIONS)
                mp.solutions.drawing_utils.draw_landmarks(frame, results.left_hand_landmarks, mp.solutions.holistic.HAND_CONNECTIONS)
                mp.solutions.drawing_utils.draw_landmarks(frame, results.right_hand_landmarks, mp.solutions.holistic.HAND_CONNECTIONS)

                cv2.imshow('Preview', frame)
finally:
    cap.release()
    cv2.destroyAllWindows()

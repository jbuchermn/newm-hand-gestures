import time
import cv2
import matplotlib.pyplot as plt
import mediapipe as mp
from dasbus.connection import SessionMessageBus


bus = SessionMessageBus()
proxy = bus.get_proxy("org.newm.Gestures", "/org/newm/Gestures")

def new_gesture():
    res = proxy.New("swipe-3")
    if res != "":
        return bus.get_proxy("org.newm.Gestures.Gesture", res)
    else:
        return None

cap = cv2.VideoCapture(0)

OUTPUT = True

try:
    with mp.solutions.holistic.Holistic(min_detection_confidence=0.5, min_tracking_confidence=0.5) as holistic:

        current = None
        init_counter = 0
        init = 0., 0.
        while cap.isOpened():
            ret, frame = cap.read()

            if cv2.waitKey(10) & 0xFF == ord('q'):
                break

            frame_rgb = cv2.cvtColor(frame, cv2.COLOR_BGR2RGB)
            t = time.time()
            results = holistic.process(frame_rgb)
            dt = time.time() - t

            # print("dt=%f" % dt)
            if results.right_hand_landmarks is not None:
                l = results.right_hand_landmarks.landmark[mp.solutions.holistic.HandLandmark.INDEX_FINGER_TIP]
                # print("x=%f, y=%f" % (l.x, l.y))

                init_counter += 1
                if init_counter > 3:
                    if current is None:
                        current = new_gesture()
                        print("New")
                        init = l.x, l.y
                    else:
                        print("Update")
                        current.Update(["delta_x", "delta_y"], [- (l.x - init[0]), l.y - init[1]])
            else:
                init_counter = 0
                if current is not None:
                    print("Terminate")
                    current.Terminate()
                    current = None

            if OUTPUT:
                mp.solutions.drawing_utils.draw_landmarks(frame, results.face_landmarks, mp.solutions.holistic.FACEMESH_CONTOURS)
                mp.solutions.drawing_utils.draw_landmarks(frame, results.pose_landmarks, mp.solutions.holistic.POSE_CONNECTIONS)
                mp.solutions.drawing_utils.draw_landmarks(frame, results.left_hand_landmarks, mp.solutions.holistic.HAND_CONNECTIONS)
                mp.solutions.drawing_utils.draw_landmarks(frame, results.right_hand_landmarks, mp.solutions.holistic.HAND_CONNECTIONS)

                cv2.imshow('Preview', frame)
finally:
    cap.release()
    cv2.destroyAllWindows()

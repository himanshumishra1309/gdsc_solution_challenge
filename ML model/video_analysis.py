import os
import cv2
import numpy as np
import matplotlib.pyplot as plt
from ultralytics import YOLO
import supervision as sv
from collections import defaultdict

# Create output folder for metrics
output_folder = "path_for_output_metrices_folder"
os.makedirs(output_folder, exist_ok=True)

# Load YOLO model
model = YOLO("yolov8l.pt")  # Larger model for better accuracy

# Open video
video_path = "path_of the video"
cap = cv2.VideoCapture(video_path)

# Get video properties
frame_width = int(cap.get(3))
frame_height = int(cap.get(4))
fps = int(cap.get(cv2.CAP_PROP_FPS))

# Define output video
output_path = "path_of_analyzed_video"
fourcc = cv2.VideoWriter_fourcc(*'mp4v')
out = cv2.VideoWriter(output_path, fourcc, fps, (frame_width, frame_height))

# Initialize annotators and tracker
ellipse_annotator = sv.EllipseAnnotator(thickness=2, color=sv.Color.GREEN)
label_annotator = sv.LabelAnnotator()
tracker = sv.ByteTrack()  # Tracker for consistent player IDs

# Player tracking data
player_data = defaultdict(lambda: {"positions": [], "distances": [], "speed": [], "direction_changes": 0})
frame_count = 0

while cap.isOpened():
    ret, frame = cap.read()
    if not ret:
        break
    
    frame_count += 1
    results = model(frame)
    detections = sv.Detections.from_ultralytics(results[0])
    person_detections = detections[detections.class_id == 0]
    tracked_detections = tracker.update_with_detections(person_detections)

    labels = []
    for i, track_id in enumerate(tracked_detections.tracker_id):
        labels.append(f"Player {track_id}")
        bbox = tracked_detections.xyxy[i]
        center_x, center_y = int((bbox[0] + bbox[2]) / 2), int((bbox[1] + bbox[3]) / 2)
        
        # Store player positions
        if player_data[track_id]["positions"]:
            prev_x, prev_y = player_data[track_id]["positions"][-1]
            distance = np.sqrt((center_x - prev_x)**2 + (center_y - prev_y)**2)
            player_data[track_id]["distances"].append(distance)
            player_data[track_id]["speed"].append(distance * fps / 100)  # Convert to m/s
            
            # Check for direction changes (agility metric)
            if len(player_data[track_id]["positions"]) > 1:
                prev2_x, prev2_y = player_data[track_id]["positions"][-2]
                angle_change = np.abs(np.arctan2(center_y - prev_y, center_x - prev_x) -
                                      np.arctan2(prev_y - prev2_y, prev_x - prev2_x))
                if angle_change > np.pi / 6:
                    player_data[track_id]["direction_changes"] += 1
        
        player_data[track_id]["positions"].append((center_x, center_y))
    
    annotated_frame = ellipse_annotator.annotate(scene=frame, detections=tracked_detections)
    annotated_frame = label_annotator.annotate(scene=annotated_frame, detections=tracked_detections, labels=labels)
    
    out.write(annotated_frame)
    cv2.imshow("Player Tracking", annotated_frame)
    
    if cv2.waitKey(1) & 0xFF == ord('q'):
        break

cap.release()
out.release()
cv2.destroyAllWindows()

# Generate graphs and report
os.makedirs(output_folder, exist_ok=True)

# Set filtering thresholds
MIN_MOVEMENT = 10   # Minimum distance a player must move
MIN_FRAMES = 5      # Minimum number of frames a player must be detected

# Filter out false detections and ensure unique players
filtered_players = {
    track_id: data for track_id, data in player_data.items()
    if np.sum(data["distances"]) > MIN_MOVEMENT and len(data["speed"]) > MIN_FRAMES
}

print(f"Total Players Processed: {len(filtered_players)} (Filtered from {len(player_data)})")

# Ensure only 22 graphs are created
if len(filtered_players) > 22:
    print("⚠ Warning: More than 22 players detected. Check tracking system for duplicate IDs!")

# Generate graphs only for valid players
for track_id, data in filtered_players.items():
    fig, ax = plt.subplots(3, 1, figsize=(8, 10))

    # Speed Plot
    if data["speed"]:
        ax[0].plot(data["speed"], label="Speed (m/s)", color='blue')
    ax[0].set_title(f"Player {track_id} Speed")
    ax[0].legend()

    # Distance Covered Plot
    if data["distances"]:
        ax[1].plot(np.cumsum(data["distances"]), label="Distance Covered (pixels)", color='green')
    ax[1].set_title(f"Player {track_id} Endurance")
    ax[1].legend()

    # Agility (Direction Changes)
    ax[2].bar(["Agility"], [data["direction_changes"]], color='orange', label="Direction Changes")
    ax[2].set_title(f"Player {track_id} Agility")
    ax[2].legend()

    plt.tight_layout()
    plt.savefig(os.path.join(output_folder, f"player_{track_id}_metrics.png"))
    plt.close()

# Write performance report
report_path = os.path.join(output_folder, "performance_report.txt")
with open(report_path, "w") as f:
    for track_id, data in filtered_players.items():
        avg_speed = np.mean(data["speed"]) if data["speed"] else 0
        total_distance = np.sum(data["distances"]) if data["distances"] else 0
        agility_score = data["direction_changes"]

        performance_score = (avg_speed * 2 + total_distance / 100 + agility_score * 3) / 6  

        f.write(f"Player {track_id}:\n")
        f.write(f"- Average Speed: {avg_speed:.2f} m/s\n")
        f.write(f"- Total Distance Covered: {total_distance:.2f} pixels\n")
        f.write(f"- Agility Score: {agility_score}\n")
        f.write(f"- Performance Rating: {performance_score:.2f}/10\n\n")

print(f"Processed video saved as {output_path}")
print(f"Performance metrics saved in {output_folder}/")

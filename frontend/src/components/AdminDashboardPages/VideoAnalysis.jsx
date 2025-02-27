import React, { useState } from "react";
import { Select, SelectTrigger, SelectValue, SelectContent, SelectItem } from "@/components/ui/select";
import { Button } from "@/components/ui/button";

const coachesList = ["Arjun Patel", "Ravi Sharma", "Deepak Joshi"];

const VideoAnalysis = () => {
  const [selectedCoach, setSelectedCoach] = useState(coachesList[0]);
  const [videoFile, setVideoFile] = useState(null);
  const [videoURL, setVideoURL] = useState("");

  // Handle video upload
  const handleVideoUpload = (event) => {
    const file = event.target.files[0];
    if (file) {
      setVideoFile(file);
      setVideoURL(URL.createObjectURL(file));
    }
  };

  // Handle sharing the video
  const handleShare = () => {
    if (videoFile) {
      alert(`Video shared with Coach ${selectedCoach}!`);
    } else {
      alert("Please upload a video first.");
    }
  };

  return (
    <div className="p-6 space-y-6">
      <h1 className="text-2xl font-bold">Video Analysis</h1>

      {/* Select Coach to Share Video With */}
      <Select value={selectedCoach} onValueChange={setSelectedCoach}>
        <SelectTrigger className="w-full">
          <SelectValue>{selectedCoach}</SelectValue>
        </SelectTrigger>
        <SelectContent>
          {coachesList.map((coach) => (
            <SelectItem key={coach} value={coach}>
              {coach}
            </SelectItem>
          ))}
        </SelectContent>
      </Select>

      {/* Video Upload Section */}
      <div className="border p-4 rounded-lg bg-gray-100">
        <input type="file" accept="video/*" onChange={handleVideoUpload} className="mb-4" />
        {videoURL ? (
          <video controls className="w-full rounded-lg">
            <source src={videoURL} type="video/mp4" />
            Your browser does not support the video tag.
          </video>
        ) : (
          <p className="text-gray-500 text-sm">No video uploaded.</p>
        )}
      </div>

      {/* Share Button */}
      <Button className="w-full" onClick={handleShare}>
        Share with {selectedCoach}
      </Button>
    </div>
  );
};

export default VideoAnalysis;

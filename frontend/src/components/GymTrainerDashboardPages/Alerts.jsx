import { useState } from "react";
import { Card, CardContent, CardHeader, CardTitle } from "@/components/ui/card";
import { Button } from "@/components/ui/button";
import { Input } from "@/components/ui/input";
import { Select, SelectContent, SelectItem, SelectTrigger, SelectValue } from "@/components/ui/select";
import DatePicker from "react-datepicker"; 
import "react-datepicker/dist/react-datepicker.css"; 

const Alerts = () => {
  const [messages, setMessages] = useState([
    { sender: "Gym Trainer ", text: "We'll start the new plan soon." },
    { sender: "Athlete", text: "Looking forward sir." },
  ]);
  const [newMessage, setNewMessage] = useState("");
  const [selectedGroup, setSelectedGroup] = useState("Athletes");
  const [meetingDate, setMeetingDate] = useState(null); 
  const [meetingDetails, setMeetingDetails] = useState("");

  const groups = ["Athletes", "Coaches", "Assistant Coaches", "Medical Staff"];

  const sendMessage = () => {
    if (newMessage.trim()) {
      setMessages((prevMessages) => [
        ...prevMessages,
        { sender: "You", text: newMessage },
      ]);
      setNewMessage("");
    }
  };

  const scheduleMeeting = () => {
    if (!meetingDate || !meetingDetails) return;

    alert(`Meeting scheduled for ${meetingDate.toLocaleDateString()} with details: ${meetingDetails}`);
    setMeetingDate(null);
    setMeetingDetails("");
  };

  return (
    <Card>
      <CardHeader>
        <CardTitle>Announcements</CardTitle>
      </CardHeader>
      <CardContent>
        
        <div className="flex flex-col space-y-4 mb-8">
          <div className="flex-1 overflow-auto p-4 bg-gray-100 rounded-md h-64">
            {messages.map((message, idx) => (
              <div key={idx} className="mb-2">
                <p className="font-semibold">{message.sender}:</p>
                <p>{message.text}</p>
              </div>
            ))}
          </div>
          <div className="flex space-x-2">
            <Input
              placeholder="Type your message..."
              value={newMessage}
              onChange={(e) => setNewMessage(e.target.value)}
              className="flex-1"
            />
            <Button onClick={sendMessage}>Send</Button>
          </div>
        </div>

        
        <div className="mb-6">
          <Select value={selectedGroup} onValueChange={setSelectedGroup}>
            <SelectTrigger>
              <SelectValue placeholder="Select Group" />
            </SelectTrigger>
            <SelectContent>
              {groups.map((group, idx) => (
                <SelectItem key={idx} value={group}>
                  {group}
                </SelectItem>
              ))}
            </SelectContent>
          </Select>
        </div>

        
        <div className="mb-6">
          <h3 className="text-lg font-semibold">Schedule a Meeting</h3>
          <div className="space-y-4">
            <div className="flex space-x-2">
              <DatePicker
                selected={meetingDate}
                onChange={(date) => setMeetingDate(date)}
                className="w-48 p-2 border border-gray-300 rounded-md"
                placeholderText="Select Date"
                dateFormat="MM/dd/yyyy"
              />
              <Input
                placeholder="Meeting Details"
                value={meetingDetails}
                onChange={(e) => setMeetingDetails(e.target.value)}
                className="flex-1"
              />
            </div>
            <Button onClick={scheduleMeeting}>Schedule Meeting</Button>
          </div>
        </div>
      </CardContent>
    </Card>
  );
};

export default Alerts;

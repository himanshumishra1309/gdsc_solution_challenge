import { useState } from "react";
import { Card, CardContent, CardHeader, CardTitle } from "@/components/ui/card";
import { Button } from "@/components/ui/button";
import { Input } from "@/components/ui/input";
import { Select, SelectContent, SelectItem, SelectTrigger, SelectValue } from "@/components/ui/select";

const ViewAnnouncements = () => {
  const [messages, setMessages] = useState([
    { sender: "Athlete", text: "Hello coach!" },
    { sender: "Coach", text: "Hey! Get ready for today's workout session." },
  ]);
  const [newMessage, setNewMessage] = useState("");
  const [selectedGroup, setSelectedGroup] = useState("Athletes");

  const groups = ["Head Coach", "Assistant Coach", "Gym Trainers", "Medical Staff"];

  const sendMessage = () => {
    if (newMessage.trim()) {
      setMessages((prevMessages) => [
        ...prevMessages,
        { sender: "You", text: newMessage },
      ]);
      setNewMessage("");
    }
  };

  return (
    <Card>
      <CardHeader>
        <CardTitle>Communication</CardTitle>
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
      </CardContent>
    </Card>
  );
};

export default ViewAnnouncements;

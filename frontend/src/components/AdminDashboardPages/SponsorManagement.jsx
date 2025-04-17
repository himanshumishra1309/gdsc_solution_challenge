import React, { useState } from "react";
import { Card, CardHeader, CardTitle, CardContent } from "@/components/ui/card";
import { Select, SelectTrigger, SelectValue, SelectContent, SelectItem } from "@/components/ui/select";
import { Button } from "@/components/ui/button";
import { Tabs, TabsList, TabsTrigger } from "@/components/ui/tabs";
import {
  Dialog,
  DialogTrigger,
  DialogContent,
  DialogTitle,
  DialogDescription,
  DialogFooter,
  DialogHeader
} from "@/components/ui/dialog";
import { Input } from "@/components/ui/input";
import { Textarea } from "@/components/ui/textarea";
import { Badge } from "@/components/ui/badge";
import { Avatar, AvatarImage, AvatarFallback } from "@/components/ui/avatar";

const sponsors = [
  {
    id: 1,
    name: "Nike",
    contact: "nike@example.com",
    phone: "+91 98765 12345",
    location: "Mumbai",
    since: "2015",
    contribution: "₹1 Crore",
    sport: "Cricket",
    supportedSports: ["Cricket", "Football"],
    status: "current",
    performance: "Platinum"
  },
  {
    id: 2,
    name: "Adidas",
    contact: "adidas@example.com",
    phone: "+91 99999 88888",
    location: "Delhi",
    since: "2020",
    contribution: "₹80 Lakhs",
    sport: "Football",
    supportedSports: ["Football"],
    status: "potential",
    performance: "Gold"
  },
  {
    id: 3,
    name: "Puma",
    contact: "puma@example.com",
    phone: "+91 88888 77777",
    location: "Bangalore",
    since: "2018",
    contribution: "₹50 Lakhs",
    sport: "Hockey",
    supportedSports: ["Hockey"],
    status: "current",
    performance: "Silver"
  }
];

const sportsList = ["All", "Cricket", "Football", "Hockey"];

// Performance badge color mapping
const performanceColors = {
  Platinum: "bg-purple-100 text-purple-800 border-purple-200",
  Gold: "bg-amber-100 text-amber-800 border-amber-200",
  Silver: "bg-gray-100 text-gray-800 border-gray-200"
};

// Generate avatar fallback initials from name
const getInitials = (name) => {
  return name
    .split(' ')
    .map(word => word[0])
    .join('')
    .toUpperCase();
};

const SponsorManagement = () => {
  const [selectedSport, setSelectedSport] = useState("All");
  const [tab, setTab] = useState("all");
  const [potentialSponsors, setPotentialSponsors] = useState(
    sponsors.filter((s) => s.status === "potential")
  );
  const [selectedSponsor, setSelectedSponsor] = useState(null);
  const [showContactDialog, setShowContactDialog] = useState(false);
  const [subject, setSubject] = useState("");
  const [message, setMessage] = useState("");

  const handleSportChange = (sport) => {
    setSelectedSport(sport);
  };

  const handleAddToPotential = (sponsor) => {
    if (!potentialSponsors.some((s) => s.id === sponsor.id)) {
      setPotentialSponsors([...potentialSponsors, { ...sponsor, status: "potential" }]);
    }
    setSelectedSponsor(null);
  };

  const handleAddAsSponsor = (sponsor) => {
    sponsor.status = "current"; 
    setPotentialSponsors(potentialSponsors.filter((s) => s.id !== sponsor.id)); 
    setSelectedSponsor(null);
  };

  const handleRemoveFromPotential = (sponsor) => {
    setPotentialSponsors(potentialSponsors.filter((s) => s.id !== sponsor.id)); 
    setSelectedSponsor(null);
  };

  const handleSendMessage = () => {
    // Send logic here
    setShowContactDialog(false);
    setSubject("");
    setMessage("");
  };

  const filteredSponsors = sponsors.filter((sponsor) => {
    const sportMatch = selectedSport === "All" || sponsor.sport === selectedSport;

    if (tab === "current") {
      return sponsor.status === "current" && sportMatch;
    } else if (tab === "potential") {
      return potentialSponsors.some((s) => s.id === sponsor.id) && sportMatch;
    }
    return sportMatch;
  });

  return (
    <div className="p-6 space-y-6">
      <h1 className="text-2xl font-bold">Sponsorship Management</h1>

      {/* Tabs */}
      <Tabs value={tab} onValueChange={setTab} className="w-full">
        <TabsList className="mb-4 grid w-full grid-cols-3">
          <TabsTrigger value="current">Current</TabsTrigger>
          <TabsTrigger value="potential">Potential</TabsTrigger>
          <TabsTrigger value="all">All</TabsTrigger>
        </TabsList>
      </Tabs>

      {/* Filter by Sport */}
      <Select value={selectedSport} onValueChange={handleSportChange}>
        <SelectTrigger className="w-full md:w-60">
          <SelectValue>{selectedSport}</SelectValue>
        </SelectTrigger>
        <SelectContent>
          {sportsList.map((sport) => (
            <SelectItem key={sport} value={sport}>
              {sport}
            </SelectItem>
          ))}
        </SelectContent>
      </Select>

      {/* Sponsor List */}
      <div className="grid grid-cols-1 md:grid-cols-2 gap-6">
        {filteredSponsors.map((sponsor) => (
          <Card key={sponsor.id} className="relative hover:shadow-md transition-shadow">
            {/* Performance Badge */}
            <Badge className={`absolute top-2 right-2 ${performanceColors[sponsor.performance] || "bg-blue-100 text-blue-800"}`}>
              {sponsor.performance}
            </Badge>

            <CardHeader className="flex flex-row items-center gap-4">
              <Avatar className="h-12 w-12">
                <AvatarFallback className="bg-blue-100 text-blue-800">{getInitials(sponsor.name)}</AvatarFallback>
              </Avatar>
              <CardTitle>{sponsor.name}</CardTitle>
            </CardHeader>
            <CardContent>
              <p className="flex items-center gap-2 text-sm text-gray-600">
                <span className="text-blue-600">📧</span> {sponsor.contact}
              </p>
              <p className="flex items-center gap-2 text-sm text-gray-600 mt-1">
                <span className="text-green-600">🏆</span> {sponsor.supportedSports.join(", ")}
              </p>
              
              <Dialog>
                <DialogTrigger asChild>
                  <Button className="mt-4" variant="outline" onClick={() => setSelectedSponsor(sponsor)}>
                    View Details
                  </Button>
                </DialogTrigger>
                {selectedSponsor?.id === sponsor.id && (
                  <DialogContent className="sm:max-w-3xl w-11/12">
                    <DialogHeader className="flex sm:flex-row justify-between items-start">
                      <div className="flex items-center gap-4">
                        <Avatar className="h-16 w-16">
                          <AvatarFallback className="text-lg bg-blue-100 text-blue-800">{getInitials(sponsor.name)}</AvatarFallback>
                        </Avatar>
                        <div>
                          <DialogTitle className="text-2xl">{sponsor.name}</DialogTitle>
                          <DialogDescription className="mt-1">{sponsor.sport} Sponsor</DialogDescription>
                        </div>
                      </div>
                      <Badge className={`mt-2 sm:mt-0 ${performanceColors[sponsor.performance] || "bg-blue-100 text-blue-800"}`}>
                        {sponsor.performance}
                      </Badge>
                    </DialogHeader>
                    
                    <div className="grid grid-cols-1 md:grid-cols-2 gap-6 py-6">
                      <div className="space-y-4">
                        <h3 className="text-lg font-medium">Contact Information</h3>
                        <div className="space-y-3">
                          <div className="flex items-center gap-2">
                            <span className="text-gray-500 w-24">Email:</span>
                            <span className="font-medium">{sponsor.contact}</span>
                          </div>
                          <div className="flex items-center gap-2">
                            <span className="text-gray-500 w-24">Phone:</span>
                            <span className="font-medium">{sponsor.phone}</span>
                          </div>
                          <div className="flex items-center gap-2">
                            <span className="text-gray-500 w-24">Location:</span>
                            <span className="font-medium">{sponsor.location}</span>
                          </div>
                        </div>
                      </div>
                      
                      <div className="space-y-4">
                        <h3 className="text-lg font-medium">Sponsorship Details</h3>
                        <div className="space-y-3">
                          <div className="flex items-center gap-2">
                            <span className="text-gray-500 w-24">Since:</span>
                            <span className="font-medium">{sponsor.since}</span>
                          </div>
                          <div className="flex items-center gap-2">
                            <span className="text-gray-500 w-24">Contribution:</span>
                            <span className="font-medium">{sponsor.contribution}</span>
                          </div>
                          <div className="flex items-center gap-2">
                            <span className="text-gray-500 w-24">Sports:</span>
                            <span className="font-medium">{sponsor.supportedSports.join(", ")}</span>
                          </div>
                        </div>
                      </div>
                    </div>
                    
                    <div className="py-4">
                      <h3 className="text-lg font-medium mb-4">Sponsorship Timeline</h3>
                      <div className="bg-gray-50 p-4 rounded-md">
                        <p className="text-gray-600">Partnership established in {sponsor.since}. Currently a {sponsor.performance} level sponsor contributing {sponsor.contribution} annually.</p>
                      </div>
                    </div>

                    <DialogFooter className="flex sm:justify-between flex-col sm:flex-row gap-4 items-center">
                      <div className="flex gap-2">
                        {/* Add to Potential (visible only for Current and All tabs) */}
                        {tab !== "potential" && (
                          <Button onClick={() => handleAddToPotential(sponsor)}>
                            Add to Potential
                          </Button>
                        )}

                        {/* Only available in Potential Tab */}
                        {tab === "potential" && (
                          <>
                            <Button onClick={() => handleAddAsSponsor(sponsor)}>Add as Sponsor</Button>
                            <Button variant="outline" onClick={() => handleRemoveFromPotential(sponsor)}>Remove</Button>
                          </>
                        )}
                      </div>
                      
                      <div className="flex gap-2">
                        <Button variant="outline" onClick={() => setShowContactDialog(true)}>
                          Contact
                        </Button>
                        <Button variant="outline" onClick={() => setSelectedSponsor(null)}>
                          Close
                        </Button>
                      </div>
                    </DialogFooter>
                  </DialogContent>
                )}
              </Dialog>

              {/* Contact Dialog */}
              {showContactDialog && selectedSponsor?.id === sponsor.id && (
                <Dialog open={showContactDialog} onOpenChange={setShowContactDialog}>
                  <DialogContent className="sm:max-w-2xl w-11/12">
                    <DialogHeader>
                      <div className="flex items-center gap-4">
                        <Avatar className="h-12 w-12">
                          <AvatarFallback className="bg-blue-100 text-blue-800">{getInitials(selectedSponsor.name)}</AvatarFallback>
                        </Avatar>
                        <div>
                          <DialogTitle className="text-xl">Contact {selectedSponsor.name}</DialogTitle>
                          <DialogDescription>
                            Send a message directly to the sponsor representative
                          </DialogDescription>
                        </div>
                      </div>
                    </DialogHeader>
                    
                    <div className="space-y-4 py-4">
                      <div className="flex items-center">
                        <span className="font-medium text-gray-500 w-16">To:</span>
                        <span className="text-gray-900">{selectedSponsor.contact}</span>
                      </div>
                      
                      <div className="space-y-2">
                        <label className="text-sm font-medium text-gray-500" htmlFor="subject">
                          Subject
                        </label>
                        <Input
                          id="subject"
                          placeholder="Enter subject line"
                          value={subject}
                          onChange={(e) => setSubject(e.target.value)}
                          className="w-full"
                        />
                      </div>
                      
                      <div className="space-y-2">
                        <label className="text-sm font-medium text-gray-500" htmlFor="message">
                          Message
                        </label>
                        <Textarea
                          id="message"
                          placeholder="Type your message here..."
                          rows={8}
                          value={message}
                          onChange={(e) => setMessage(e.target.value)}
                          className="w-full resize-none"
                        />
                      </div>
                    </div>
                    
                    <DialogFooter>
                      <Button variant="outline" onClick={() => setShowContactDialog(false)}>
                        Cancel
                      </Button>
                      <Button onClick={handleSendMessage}>
                        Send Message
                      </Button>
                    </DialogFooter>
                  </DialogContent>
                </Dialog>
              )}
            </CardContent>
          </Card>
        ))}
      </div>
    </div>
  );
};

export default SponsorManagement;
import { useState, useEffect } from "react";
import {
  Table,
  TableBody,
  TableCell,
  TableHead,
  TableHeader,
  TableRow,
} from "@/components/ui/table";
import { Input } from "@/components/ui/input";
import { Button } from "@/components/ui/button";
import { Label } from "@/components/ui/label";
import { Textarea } from "@/components/ui/textarea";
import { Tabs, TabsContent, TabsList, TabsTrigger } from "@/components/ui/tabs";
import {
  Card,
  CardContent,
  CardDescription,
  CardHeader,
  CardTitle,
} from "@/components/ui/card";
import { Badge } from "@/components/ui/badge";
import {
  Dialog,
  DialogContent,
  DialogDescription,
  DialogFooter,
  DialogHeader,
  DialogTitle,
} from "@/components/ui/dialog";
import {
  Select,
  SelectContent,
  SelectItem,
  SelectTrigger,
  SelectValue,
} from "@/components/ui/select";
import { toast, ToastContainer } from "react-toastify";
import "react-toastify/dist/ReactToastify.css";
import { ScrollArea } from "@/components/ui/scroll-area";
import { Search } from "lucide-react";
import axios from "axios";

// API configuration
const api = axios.create({
  baseURL: "http://localhost:8000/api/v1",
});

api.interceptors.request.use(
  (config) => {
    config.withCredentials = true;
    const token = sessionStorage.getItem("athleteAccessToken");
    if (token) {
      config.headers.Authorization = `Bearer ${token}`;
    }
    return config;
  },
  (error) => {
    return Promise.reject(error);
  }
);

const INJURY_ENDPOINTS = {
  createTicket: "/injuries/create",
  getMyTickets: "/injuries/my-tickets",
  getTicketDetails: (id) => `/injuries/my-tickets/${id}`,
  updateReport: (id) => `/injuries/report/${id}`,
  deleteTicket: (id) => `/injuries/${id}`,
  getMessages: (id) => `/injuries/athlete/tickets/${id}/messages`,
  getAssessment: (id) => `/injuries/athlete/tickets/${id}/assessment`
};

const getStatusColor = (status) => {
  switch (status) {
    case "OPEN":
      return "bg-red-500";
    case "IN_PROGRESS":
      return "bg-yellow-500";
    case "CLOSED":
      return "bg-green-500";
    default:
      return "bg-gray-500";
  }
};

function FillInjuryForms() {
  // State management
  const [injuries, setInjuries] = useState([]);
  const [selectedInjury, setSelectedInjury] = useState(null);
  const [injuryDialogOpen, setInjuryDialogOpen] = useState(false);
  const [activeInjuryTab, setActiveInjuryTab] = useState("input");
  const [isEditMode, setIsEditMode] = useState(false);
  const [editableInjury, setEditableInjury] = useState(null);
  const [deleteConfirmOpen, setDeleteConfirmOpen] = useState(false);
  const [selectedTicketId, setSelectedTicketId] = useState(null);
  const [assignedDoctor, setAssignedDoctor] = useState(null);
  const [injurySearchTerm, setInjurySearchTerm] = useState("");
  const [activeDetailTab, setActiveDetailTab] = useState("input");

  const [loading, setLoading] = useState({
    injuries: false,
    details: false,
    create: false,
    update: false,
    delete: false,
    messages: false,
    assessment: false
  });

  const [error, setError] = useState({
    injuries: null,
    details: null,
    create: null,
    update: null,
    delete: null
  });

  const [newInjury, setNewInjury] = useState({
    title: "",
    injuryType: "",
    bodyPart: "",
    painLevel: 5,
    dateOfInjury: "",
    activityContext: "",
    symptoms: "",
    affectingPerformance: "MINIMAL",
    previouslyInjured: false,
    notes: "",
  });

  // Helper functions
  const formatDate = (dateString) => {
    if (!dateString) return "Not specified";
    return new Date(dateString).toLocaleDateString('en-US', {
      year: 'numeric',
      month: 'short',
      day: 'numeric'
    });
  };

  // API functions
  const fetchAssignedDoctor = async () => {
    try {
      const userDataStr = sessionStorage.getItem("userData");
      console.log("User Data:", userDataStr);
      if (userDataStr) {
        const userData = JSON.parse(userDataStr);
        console.log("Parsed User Data:", userData._id);
        if (userData._id) {
          const response = await api.get(`/athletes/${userData._id}/details`);
          if (response.data && response.data.medicalStaffAssigned) {
            setAssignedDoctor(response.data.medicalStaffAssigned);
          }
        }
      } else {
        const response = await api.get("/athletes/profile");
        if (response.data.data && response.data.data.medicalStaffAssigned) {
          setAssignedDoctor(response.data.data.medicalStaffAssigned);
        }
      }
    } catch (err) {
      console.error("Failed to fetch assigned doctor:", err);
    }
  };

  const fetchInjuries = async () => {
    setLoading(prev => ({ ...prev, injuries: true }));
    setError(prev => ({ ...prev, injuries: null }));
    
    try {
      const response = await api.get(INJURY_ENDPOINTS.getMyTickets);
      const injuriesData = [];
      
      if (response.data.data && response.data.data.tickets) {
        // Process open tickets
        if (response.data.data.tickets.open) {
          response.data.data.tickets.open.forEach((item) => {
            injuriesData.push({
              id: item.ticket._id,
              title: item.ticket.injuryReport_id.title,
              injuryType: item.ticket.injuryReport_id.injuryType,
              bodyPart: item.ticket.injuryReport_id.bodyPart,
              painLevel: item.ticket.injuryReport_id.painLevel,
              dateOfInjury: item.ticket.injuryReport_id.dateOfInjury,
              activityContext: item.ticket.injuryReport_id.activityContext,
              symptoms: item.ticket.injuryReport_id.symptoms || [],
              affectingPerformance: item.ticket.injuryReport_id.affectingPerformance,
              previouslyInjured: item.ticket.injuryReport_id.previouslyInjured,
              notes: item.ticket.injuryReport_id.notes,
              status: item.ticket.ticketStatus,
              createdAt: item.ticket.createdAt,
              reportId: item.ticket.injuryReport_id._id,
              doctorReply: null,
              assessment: null,
              rawData: item,
            });
          });
        }

        // Process in-progress tickets
        if (response.data.data.tickets.inProgress) {
          response.data.data.tickets.inProgress.forEach((item) => {
            injuriesData.push({
              id: item.ticket._id,
              title: item.ticket.injuryReport_id.title,
              injuryType: item.ticket.injuryReport_id.injuryType,
              bodyPart: item.ticket.injuryReport_id.bodyPart,
              painLevel: item.ticket.injuryReport_id.painLevel,
              dateOfInjury: item.ticket.injuryReport_id.dateOfInjury,
              activityContext: item.ticket.injuryReport_id.activityContext,
              symptoms: item.ticket.injuryReport_id.symptoms || [],
              affectingPerformance: item.ticket.injuryReport_id.affectingPerformance,
              previouslyInjured: item.ticket.injuryReport_id.previouslyInjured,
              notes: item.ticket.injuryReport_id.notes,
              status: item.ticket.ticketStatus,
              createdAt: item.ticket.createdAt,
              reportId: item.ticket.injuryReport_id._id,
              doctorReply: {
                response: "Please check detailed view",
                medication: "Check detailed view",
                doctorNote: "Check detailed view",
                appointmentDate: "Check detailed view",
                appointmentTime: "Check detailed view",
              },
              assessment: null,
              rawData: item,
            });
          });
        }

        // Process closed tickets
        if (response.data.data.tickets.closed) {
          response.data.data.tickets.closed.forEach((item) => {
            injuriesData.push({
              id: item.ticket._id,
              title: item.ticket.injuryReport_id.title,
              injuryType: item.ticket.injuryReport_id.injuryType,
              bodyPart: item.ticket.injuryReport_id.bodyPart,
              painLevel: item.ticket.injuryReport_id.painLevel,
              dateOfInjury: item.ticket.injuryReport_id.dateOfInjury,
              activityContext: item.ticket.injuryReport_id.activityContext,
              symptoms: item.ticket.injuryReport_id.symptoms || [],
              affectingPerformance: item.ticket.injuryReport_id.affectingPerformance,
              previouslyInjured: item.ticket.injuryReport_id.previouslyInjured,
              notes: item.ticket.injuryReport_id.notes,
              status: item.ticket.ticketStatus,
              createdAt: item.ticket.createdAt,
              reportId: item.ticket.injuryReport_id._id,
              doctorReply: {
                response: "Please check detailed view",
                medication: "Check detailed view",
                doctorNote: "Check detailed view",
                appointmentDate: "Check detailed view",
                appointmentTime: "Check detailed view",
              },
              assessment: item.assessment,
              rawData: item,
            });
          });
        }
      }

      setInjuries(injuriesData);
    } catch (err) {
      console.error("Error fetching injuries:", err);
      setError(prev => ({ 
        ...prev, 
        injuries: err.response?.data?.message || "Failed to load injury reports" 
      }));
      toast.error("Failed to load your injury reports");
      setInjuries([]);
    } finally {
      setLoading(prev => ({ ...prev, injuries: false }));
    }
  };

  const fetchInjuryDetails = async (ticketId) => {
    setLoading(prev => ({ ...prev, details: true }));
    setError(prev => ({ ...prev, details: null }));

    try {
      const response = await api.get(INJURY_ENDPOINTS.getTicketDetails(ticketId));
      const data = response.data.data;
      const reportData = data.ticket.injuryReport_id;

      const formattedInjury = {
        id: data.ticket._id,
        title: reportData.title,
        injuryType: reportData.injuryType,
        bodyPart: reportData.bodyPart,
        painLevel: reportData.painLevel,
        dateOfInjury: reportData.dateOfInjury,
        activityContext: reportData.activityContext,
        symptoms: reportData.symptoms || [],
        affectingPerformance: reportData.affectingPerformance,
        previouslyInjured: reportData.previouslyInjured,
        notes: reportData.notes,
        status: data.ticket.ticketStatus,
        createdAt: data.ticket.createdAt,
        reportId: reportData._id,
        doctorReply: null,
        assessment: null,
        messages: [],
        statusTimeline: data.statusTimeline,
        rawData: data,
      };

      setSelectedInjury(formattedInjury);
      setInjuryDialogOpen(true);

      // Fetch doctor's messages
      try {
        const messagesResponse = await api.get(INJURY_ENDPOINTS.getMessages(ticketId));
        if (messagesResponse.data?.data?.messages?.length > 0) {
          const latestMessage = messagesResponse.data.data.messages[0];
          formattedInjury.doctorReply = {
            response: latestMessage.response,
            medication: latestMessage.medication,
            doctorNote: latestMessage.doctorNote,
            appointmentDate: new Date(latestMessage.appointmentDate).toLocaleDateString(),
            appointmentTime: latestMessage.appointmentTime,
            createdAt: latestMessage.createdAt
          };
          formattedInjury.messages = messagesResponse.data.data.messages;
        }
      } catch (messageErr) {
        console.warn("Could not fetch doctor messages:", messageErr);
      }

      // Fetch medical assessment
      try {
        const assessmentResponse = await api.get(INJURY_ENDPOINTS.getAssessment(ticketId));
        if (assessmentResponse.data?.data?.assessment) {
          formattedInjury.assessment = assessmentResponse.data.data.assessment;
          formattedInjury.doctorInfo = assessmentResponse.data.data.doctorInfo;
        }
      } catch (assessmentErr) {
        console.warn("Could not fetch medical assessment:", assessmentErr);
      }

      setSelectedInjury(formattedInjury);
    } catch (err) {
      console.error("Failed to fetch injury details:", err);
      setError(prev => ({ 
        ...prev, 
        details: err.response?.data?.message || "Failed to load injury details" 
      }));
      toast.error("Failed to load injury details");
      setInjuryDialogOpen(false);
    } finally {
      setLoading(prev => ({ ...prev, details: false }));
    }
  };

  const createInjuryReport = async () => {
    if (!newInjury.title || !newInjury.injuryType || !newInjury.bodyPart || 
        !newInjury.dateOfInjury || !newInjury.activityContext) {
      toast.error("Please fill all required fields");
      return;
    }

    if (!assignedDoctor) {
      toast.error("No assigned doctor found. Please contact your administrator.");
      return;
    }

    const userData = JSON.parse(sessionStorage.getItem("userData") || "{}");
    if (!userData._id) {
      toast.error("User data not found. Please log in again.");
      return;
    }

    setLoading(prev => ({ ...prev, create: true }));
    setError(prev => ({ ...prev, create: null }));
    
    try {
      const formattedInjury = {
        athlete: userData._id,
        doctor: assignedDoctor,
        title: newInjury.title,
        injuryType: newInjury.injuryType,
        bodyPart: newInjury.bodyPart,
        painLevel: parseInt(newInjury.painLevel),
        dateOfInjury: newInjury.dateOfInjury,
        activityContext: newInjury.activityContext,
        symptoms: newInjury.symptoms ? newInjury.symptoms.split(",").map(s => s.trim()) : [],
        affectingPerformance: newInjury.affectingPerformance || "NONE",
        previouslyInjured: newInjury.previouslyInjured || false,
        notes: newInjury.notes || "",
        images: []
      };

      await api.post(INJURY_ENDPOINTS.createTicket, formattedInjury);
      
      toast.success("Injury report submitted successfully");
      setNewInjury({
        title: "",
        injuryType: "",
        bodyPart: "",
        painLevel: 5,
        dateOfInjury: "",
        activityContext: "",
        symptoms: "",
        affectingPerformance: "MINIMAL",
        previouslyInjured: false,
        notes: "",
      });
      setActiveInjuryTab("view");
      fetchInjuries();
    } catch (err) {
      console.error("Failed to submit injury report:", err);
      let errorMessage = "Failed to submit injury report";
      if (err.response) {
        if (err.response.status === 400) {
          errorMessage = err.response.data.message || "Invalid input data";
        } else if (err.response.status === 404) {
          errorMessage = "Doctor or athlete not found";
        } else if (err.response.status === 401) {
          errorMessage = "Authentication error. Please log in again.";
        } else {
          errorMessage = err.response.data.message || errorMessage;
        }
      }
      setError(prev => ({ ...prev, create: errorMessage }));
      toast.error(errorMessage);
    } finally {
      setLoading(prev => ({ ...prev, create: false }));
    }
  };

  const updateInjuryReport = async () => {
    if (!editableInjury || !editableInjury.reportId) {
      toast.error("Invalid injury data");
      return;
    }

    setLoading(prev => ({ ...prev, update: true }));
    setError(prev => ({ ...prev, update: null }));

    try {
      const updateData = {
        title: editableInjury.title,
        injuryType: editableInjury.injuryType,
        bodyPart: editableInjury.bodyPart,
        painLevel: editableInjury.painLevel,
        dateOfInjury: editableInjury.dateOfInjury,
        activityContext: editableInjury.activityContext,
        symptoms: editableInjury.symptoms,
        affectingPerformance: editableInjury.affectingPerformance,
        previouslyInjured: editableInjury.previouslyInjured,
        notes: editableInjury.notes,
      };

      await api.put(INJURY_ENDPOINTS.updateReport(editableInjury.reportId), updateData);
      
      toast.success("Injury report updated successfully");
      setIsEditMode(false);
      fetchInjuries();
      setInjuryDialogOpen(false);
    } catch (err) {
      console.error("Failed to update injury report:", err);
      setError(prev => ({ 
        ...prev, 
        update: err.response?.data?.message || "Failed to update injury report" 
      }));
      toast.error(err.response?.data?.message || "Failed to update injury report");
    } finally {
      setLoading(prev => ({ ...prev, update: false }));
    }
  };

  const deleteInjuryReport = async () => {
    if (!selectedTicketId) {
      toast.error("No ticket selected for deletion");
      return;
    }

    setLoading(prev => ({ ...prev, delete: true }));
    setError(prev => ({ ...prev, delete: null }));

    try {
      await api.delete(INJURY_ENDPOINTS.deleteTicket(selectedTicketId));
      
      toast.success("Injury report deleted successfully");
      setDeleteConfirmOpen(false);
      setSelectedTicketId(null);
      setInjuryDialogOpen(false);
      fetchInjuries();
    } catch (err) {
      console.error("Failed to delete injury ticket:", err);
      setError(prev => ({ 
        ...prev, 
        delete: err.response?.data?.message || "Failed to delete injury report" 
      }));
      toast.error(err.response?.data?.message || "Failed to delete injury report");
    } finally {
      setLoading(prev => ({ ...prev, delete: false }));
      setDeleteConfirmOpen(false);
    }
  };

  // Event handlers
  const handleNewInjuryChange = (e) => {
    const { name, value, type, checked } = e.target;
    setNewInjury(prev => ({
      ...prev,
      [name]: type === "checkbox" ? checked : value,
    }));
  };

  const handleEditInputChange = (e) => {
    const { name, value, type, checked } = e.target;
    setEditableInjury(prev => ({
      ...prev,
      [name]: type === "checkbox" ? checked : value,
    }));
  };

  const handleViewInjuryDetails = (injury) => {
    if (injury.id) {
      fetchInjuryDetails(injury.id);
    } else {
      setSelectedInjury(injury);
      setInjuryDialogOpen(true);
    }
  };

  const handleEnterEditMode = () => {
    if (selectedInjury && selectedInjury.status === "OPEN") {
      setEditableInjury({ ...selectedInjury });
      setIsEditMode(true);
    } else {
      toast.error("Only open tickets can be edited");
    }
  };

  const handleCancelEdit = () => {
    setIsEditMode(false);
    setEditableInjury(null);
  };

  // Filter injuries based on search term
  const filteredInjuries = injuries.filter(injury =>
    injury.title.toLowerCase().includes(injurySearchTerm.toLowerCase()) ||
    injury.injuryType.toLowerCase().includes(injurySearchTerm.toLowerCase()) ||
    injury.bodyPart.toLowerCase().includes(injurySearchTerm.toLowerCase())
  );

  // Initialize data
  useEffect(() => {
    fetchInjuries();
    fetchAssignedDoctor();
  }, []);

  return (
    <div className="space-y-6 p-4">
      <ToastContainer position="top-right" autoClose={3000} />
      
      <Card>
        <CardHeader>
          <CardTitle>Injury Reports</CardTitle>
          <CardDescription>
            Report and manage your injuries for medical staff attention
          </CardDescription>
        </CardHeader>
        <CardContent>
          <Tabs defaultValue="view" value={activeInjuryTab} onValueChange={setActiveInjuryTab}>
            <TabsList className="mb-4">
              <TabsTrigger value="view">View Reports</TabsTrigger>
              <TabsTrigger value="input">New Report</TabsTrigger>
            </TabsList>
            
            <TabsContent value="view">
              <div className="space-y-4">
                <div className="flex items-center space-x-2">
                  <div className="relative flex-1">
                    <Search className="absolute left-2.5 top-2.5 h-4 w-4 text-muted-foreground" />
                    <Input
                      type="search"
                      placeholder="Search injury reports..."
                      className="pl-8"
                      value={injurySearchTerm}
                      onChange={(e) => setInjurySearchTerm(e.target.value)}
                    />
                  </div>
                </div>
                
                {loading.injuries ? (
                  <div className="text-center py-8">Loading your injury reports...</div>
                ) : error.injuries ? (
                  <div className="text-center py-8 text-red-500">{error.injuries}</div>
                ) : filteredInjuries.length === 0 ? (
                  <div className="text-center py-8 text-gray-500">
                    {injurySearchTerm 
                      ? "No matching injury reports found" 
                      : "You haven't submitted any injury reports yet"}
                  </div>
                ) : (
                  <ScrollArea className="h-[400px]">
                    <Table>
                      <TableHeader>
                        <TableRow>
                          <TableHead>Title</TableHead>
                          <TableHead>Type</TableHead>
                          <TableHead>Body Part</TableHead>
                          <TableHead>Date Reported</TableHead>
                          <TableHead>Status</TableHead>
                          <TableHead>Actions</TableHead>
                        </TableRow>
                      </TableHeader>
                      <TableBody>
                        {filteredInjuries.map((injury) => (
                          <TableRow key={injury.id}>
                            <TableCell className="font-medium">{injury.title}</TableCell>
                            <TableCell>{injury.injuryType}</TableCell>
                            <TableCell>{injury.bodyPart}</TableCell>
                            <TableCell>{formatDate(injury.createdAt)}</TableCell>
                            <TableCell>
                              <Badge className={getStatusColor(injury.status)}>
                                {injury.status.replace('_', ' ')}
                              </Badge>
                            </TableCell>
                            <TableCell>
                              <Button 
                                variant="ghost" 
                                size="sm" 
                                onClick={() => handleViewInjuryDetails(injury)}
                              >
                                View
                              </Button>
                              {injury.status === "OPEN" && (
                                <Button 
                                  variant="ghost" 
                                  size="sm"
                                  className="text-red-500"
                                  onClick={() => {
                                    setSelectedTicketId(injury.id);
                                    setDeleteConfirmOpen(true);
                                  }}
                                >
                                  Delete
                                </Button>
                              )}
                            </TableCell>
                          </TableRow>
                        ))}
                      </TableBody>
                    </Table>
                  </ScrollArea>
                )}
              </div>
            </TabsContent>
            
            <TabsContent value="input">
              <div className="space-y-4">
                <div className="grid grid-cols-1 md:grid-cols-2 gap-4">
                  <div className="space-y-2">
                    <Label htmlFor="title">Injury Title *</Label>
                    <Input
                      id="title"
                      name="title"
                      placeholder="Brief description of injury"
                      value={newInjury.title}
                      onChange={handleNewInjuryChange}
                      required
                    />
                  </div>
                  
                  <div className="space-y-2">
                    <Label htmlFor="injuryType">Injury Type *</Label>
                    <Select 
                      value={newInjury.injuryType} 
                      onValueChange={(value) => setNewInjury({...newInjury, injuryType: value})}
                      required
                    >
                      <SelectTrigger>
                        <SelectValue placeholder="Select injury type" />
                      </SelectTrigger>
                      <SelectContent>
                        <SelectItem value="Sprain">Sprain</SelectItem>
                        <SelectItem value="Strain">Strain</SelectItem>
                        <SelectItem value="Fracture">Fracture</SelectItem>
                        <SelectItem value="Dislocation">Dislocation</SelectItem>
                        <SelectItem value="Contusion">Contusion (Bruise)</SelectItem>
                        <SelectItem value="Laceration">Laceration (Cut)</SelectItem>
                        <SelectItem value="Inflammation">Inflammation</SelectItem>
                        <SelectItem value="Other">Other</SelectItem>
                      </SelectContent>
                    </Select>
                  </div>
                  
                  <div className="space-y-2">
                    <Label htmlFor="bodyPart">Body Part *</Label>
                    <Input
                      id="bodyPart"
                      name="bodyPart"
                      placeholder="E.g., Right Ankle"
                      value={newInjury.bodyPart}
                      onChange={handleNewInjuryChange}
                      required
                    />
                  </div>
                  
                  <div className="space-y-2">
                    <Label htmlFor="painLevel">Pain Level (1-10) *</Label>
                    <div className="flex items-center space-x-2">
                      <Input
                        id="painLevel"
                        name="painLevel"
                        type="range"
                        min="1"
                        max="10"
                        value={newInjury.painLevel}
                        onChange={handleNewInjuryChange}
                        className="flex-1"
                      />
                      <span>{newInjury.painLevel}</span>
                    </div>
                  </div>
                  
                  <div className="space-y-2">
                    <Label htmlFor="dateOfInjury">Date of Injury *</Label>
                    <Input
                      id="dateOfInjury"
                      name="dateOfInjury"
                      type="date"
                      value={newInjury.dateOfInjury}
                      onChange={handleNewInjuryChange}
                      required
                      max={new Date().toISOString().split("T")[0]}
                    />
                  </div>
                  
                  <div className="space-y-2">
                    <Label htmlFor="activityContext">Activity Context *</Label>
                    <Input
                      id="activityContext"
                      name="activityContext"
                      placeholder="E.g., Basketball Match"
                      value={newInjury.activityContext}
                      onChange={handleNewInjuryChange}
                      required
                    />
                  </div>
                  
                  <div className="space-y-2">
                    <Label htmlFor="symptoms">Symptoms (comma separated)</Label>
                    <Input
                      id="symptoms"
                      name="symptoms"
                      placeholder="E.g., Swelling, Pain when walking"
                      value={newInjury.symptoms}
                      onChange={handleNewInjuryChange}
                    />
                  </div>
                  
                  <div className="space-y-2">
                    <Label htmlFor="affectingPerformance">Effect on Performance</Label>
                    <Select 
                      value={newInjury.affectingPerformance} 
                      onValueChange={(value) => setNewInjury({...newInjury, affectingPerformance: value})}
                    >
                      <SelectTrigger>
                        <SelectValue placeholder="Select impact" />
                      </SelectTrigger>
                      <SelectContent>
                        <SelectItem value="CANNOT_PLAY">Cannot Play</SelectItem>
                        <SelectItem value="LIMITED">Limited</SelectItem>
                        <SelectItem value="MINIMAL">Minimal</SelectItem>
                        <SelectItem value="NONE">None</SelectItem>
                      </SelectContent>
                    </Select>
                  </div>
                  
                  <div className="space-y-2 flex items-center">
                    <div className="flex items-center space-x-2">
                      <input
                        type="checkbox"
                        id="previouslyInjured"
                        name="previouslyInjured"
                        checked={newInjury.previouslyInjured}
                        onChange={handleNewInjuryChange}
                        className="w-5 h-5"
                      />
                      <Label htmlFor="previouslyInjured">
                        Previously injured this area?
                      </Label>
                    </div>
                  </div>
                </div>
                
                <div className="space-y-2">
                  <Label htmlFor="notes">Additional Notes</Label>
                  <Textarea
                    id="notes"
                    name="notes"
                    value={newInjury.notes}
                    onChange={handleNewInjuryChange}
                    placeholder="Provide any additional details about your injury..."
                    className="min-h-[100px]"
                  />
                </div>
                
                <div className="flex justify-end space-x-2">
                  <Button variant="outline" onClick={() => setActiveInjuryTab("view")}>
                    Cancel
                  </Button>
                  <Button 
                    onClick={createInjuryReport} 
                    disabled={loading.create}
                  >
                    {loading.create ? "Submitting..." : "Submit Injury Report"}
                  </Button>
                </div>
              </div>
            </TabsContent>
          </Tabs>
        </CardContent>
      </Card>
      
      {/* Injury details dialog */}
      <Dialog open={injuryDialogOpen} onOpenChange={setInjuryDialogOpen}>
        <DialogContent className="sm:max-w-[800px]">
          {loading.details ? (
            <div className="text-center py-8">Loading injury details...</div>
          ) : !selectedInjury ? (
            <div className="text-center py-8 text-red-500">
              Failed to load injury details
            </div>
          ) : isEditMode ? (
            <>
              <DialogHeader>
                <DialogTitle>Edit Injury Report</DialogTitle>
                <DialogDescription>
                  Update the details of your injury report
                </DialogDescription>
              </DialogHeader>
              
              <div className="grid gap-4 py-4">
                <div className="space-y-2">
                  <Label htmlFor="edit-title">Injury Title</Label>
                  <Input
                    id="edit-title"
                    name="title"
                    value={editableInjury.title}
                    onChange={handleEditInputChange}
                  />
                </div>
                
                <div className="grid grid-cols-2 gap-4">
                  <div className="space-y-2">
                    <Label htmlFor="edit-type">Injury Type</Label>
                    <Select 
                      value={editableInjury.injuryType} 
                      onValueChange={(value) => setEditableInjury({...editableInjury, injuryType: value})}
                    >
                      <SelectTrigger>
                        <SelectValue placeholder="Select type" />
                      </SelectTrigger>
                      <SelectContent>
                        <SelectItem value="Sprain">Sprain</SelectItem>
                        <SelectItem value="Strain">Strain</SelectItem>
                        <SelectItem value="Fracture">Fracture</SelectItem>
                        <SelectItem value="Dislocation">Dislocation</SelectItem>
                        <SelectItem value="Contusion">Contusion</SelectItem>
                        <SelectItem value="Laceration">Laceration</SelectItem>
                        <SelectItem value="Inflammation">Inflammation</SelectItem>
                        <SelectItem value="Other">Other</SelectItem>
                      </SelectContent>
                    </Select>
                  </div>
                  
                  <div className="space-y-2">
                    <Label htmlFor="edit-bodyPart">Body Part</Label>
                    <Input
                      id="edit-bodyPart"
                      name="bodyPart"
                      value={editableInjury.bodyPart}
                      onChange={handleEditInputChange}
                    />
                  </div>
                  
                  <div className="space-y-2">
                    <Label htmlFor="edit-painLevel">Pain Level (1-10)</Label>
                    <div className="flex items-center space-x-2">
                      <Input
                        id="edit-painLevel"
                        name="painLevel"
                        type="range"
                        min="1"
                        max="10"
                        value={editableInjury.painLevel}
                        onChange={handleEditInputChange}
                        className="flex-1"
                      />
                      <span>{editableInjury.painLevel}</span>
                    </div>
                  </div>
                  
                  <div className="space-y-2">
                    <Label htmlFor="edit-dateOfInjury">Date of Injury</Label>
                    <Input
                      id="edit-dateOfInjury"
                      name="dateOfInjury"
                      type="date"
                      value={editableInjury.dateOfInjury ? editableInjury.dateOfInjury.split('T')[0] : ''}
                      onChange={handleEditInputChange}
                    />
                  </div>
                  
                  <div className="space-y-2">
                    <Label htmlFor="edit-activityContext">Activity Context</Label>
                    <Input
                      id="edit-activityContext"
                      name="activityContext"
                      value={editableInjury.activityContext}
                      onChange={handleEditInputChange}
                    />
                  </div>
                  
                  <div className="space-y-2">
                    <Label htmlFor="edit-symptoms">Symptoms</Label>
                    <Input
                      id="edit-symptoms"
                      name="symptoms"
                      value={editableInjury.symptoms}
                      onChange={handleEditInputChange}
                      placeholder="Comma separated symptoms"
                    />
                  </div>
                  
                  <div className="space-y-2">
                    <Label htmlFor="edit-affectingPerformance">Effect on Performance</Label>
                    <Select 
                      value={editableInjury.affectingPerformance} 
                      onValueChange={(value) => setEditableInjury({...editableInjury, affectingPerformance: value})}
                    >
                      <SelectTrigger>
                        <SelectValue placeholder="Select impact" />
                      </SelectTrigger>
                      <SelectContent>
                        <SelectItem value="CANNOT_PLAY">Cannot Play</SelectItem>
                        <SelectItem value="LIMITED">Limited</SelectItem>
                        <SelectItem value="MINIMAL">Minimal</SelectItem>
                        <SelectItem value="NONE">None</SelectItem>
                      </SelectContent>
                    </Select>
                  </div>
                  
                  <div className="space-y-2 flex items-center">
                    <div className="flex items-center space-x-2">
                      <input
                        type="checkbox"
                        id="edit-previouslyInjured"
                        name="previouslyInjured"
                        checked={editableInjury.previouslyInjured}
                        onChange={handleEditInputChange}
                        className="w-5 h-5"
                      />
                      <Label htmlFor="edit-previouslyInjured">
                        Previously injured this area?
                      </Label>
                    </div>
                  </div>
                </div>
                
                <div className="space-y-2">
                  <Label htmlFor="edit-notes">Additional Notes</Label>
                  <Textarea
                    id="edit-notes"
                    name="notes"
                    value={editableInjury.notes}
                    onChange={handleEditInputChange}
                    className="min-h-[100px]"
                  />
                </div>
              </div>
              
              <DialogFooter>
                <Button variant="outline" onClick={handleCancelEdit}>
                  Cancel
                </Button>
                <Button 
                  onClick={updateInjuryReport}
                  disabled={loading.update}
                >
                  {loading.update ? "Updating..." : "Update Report"}
                </Button>
              </DialogFooter>
            </>
          ) : (
            <>
              <DialogHeader>
                <DialogTitle className="flex items-center justify-between">
                  <span>{selectedInjury.title}</span>
                  <Badge className={getStatusColor(selectedInjury.status)}>
                    {selectedInjury.status.replace('_', ' ')}
                  </Badge>
                </DialogTitle>
                <DialogDescription>
                  Reported on {formatDate(selectedInjury.createdAt)}
                </DialogDescription>
              </DialogHeader>
              
              <Tabs 
                defaultValue="input" 
                value={activeDetailTab} 
                onValueChange={setActiveDetailTab}
                className="w-full"
              >
                <TabsList className="grid w-full grid-cols-3">
                  <TabsTrigger value="input">Your Input</TabsTrigger>
                  <TabsTrigger value="reply">
                    Short Reply
                    {!selectedInjury.doctorReply && (
                      <span className="ml-2 text-xs bg-yellow-500 text-white px-2 py-1 rounded-full">
                        Pending
                      </span>
                    )}
                  </TabsTrigger>
                  <TabsTrigger value="assessment">
                    Medical Assessment
                    {!selectedInjury.assessment && (
                      <span className="ml-2 text-xs bg-yellow-500 text-white px-2 py-1 rounded-full">
                        Pending
                      </span>
                    )}
                  </TabsTrigger>
                </TabsList>
                
                <TabsContent value="input" className="mt-4">
                  <ScrollArea className="h-[400px] pr-4">
                    <div className="grid grid-cols-2 gap-4">
                      <div className="space-y-1">
                        <h4 className="text-sm font-semibold">Injury Type</h4>
                        <p>{selectedInjury.injuryType || "Not specified"}</p>
                      </div>
                      
                      <div className="space-y-1">
                        <h4 className="text-sm font-semibold">Body Part</h4>
                        <p>{selectedInjury.bodyPart || "Not specified"}</p>
                      </div>
                      
                      <div className="space-y-1">
                        <h4 className="text-sm font-semibold">Pain Level</h4>
                        <p>{selectedInjury.painLevel ? `${selectedInjury.painLevel} / 10` : "Not specified"}</p>
                      </div>
                      
                      <div className="space-y-1">
                        <h4 className="text-sm font-semibold">Date of Injury</h4>
                        <p>{selectedInjury.dateOfInjury ? formatDate(selectedInjury.dateOfInjury) : "Not specified"}</p>
                      </div>
                      
                      <div className="space-y-1">
                        <h4 className="text-sm font-semibold">Activity Context</h4>
                        <p>{selectedInjury.activityContext || "Not specified"}</p>
                      </div>
                      
                      <div className="space-y-1">
                        <h4 className="text-sm font-semibold">Affecting Performance</h4>
                        <p>{selectedInjury.affectingPerformance || "Not specified"}</p>
                      </div>
                      
                      <div className="col-span-2 space-y-1">
                        <h4 className="text-sm font-semibold">Symptoms</h4>
                        {selectedInjury.symptoms && selectedInjury.symptoms.length > 0 ? (
                          <ul className="list-disc pl-5">
                            {selectedInjury.symptoms.map((symptom, index) => (
                              <li key={index}>{symptom}</li>
                            ))}
                          </ul>
                        ) : (
                          <p>No symptoms reported</p>
                        )}
                      </div>
                      
                      <div className="space-y-1">
                        <h4 className="text-sm font-semibold">Previously Injured</h4>
                        <p>{selectedInjury.previouslyInjured ? "Yes" : "No"}</p>
                      </div>
                      
                      <div className="col-span-2 space-y-1">
                        <h4 className="text-sm font-semibold">Additional Notes</h4>
                        <p className="whitespace-pre-line">{selectedInjury.notes || "None"}</p>
                      </div>
                    </div>
                  </ScrollArea>
                  
                  {selectedInjury.status === "OPEN" && (
                    <div className="flex justify-end space-x-2 mt-4">
                      <Button variant="outline" onClick={handleEnterEditMode}>
                        Edit Report
                      </Button>
                      <Button
                        variant="destructive"
                        onClick={() => {
                          setSelectedTicketId(selectedInjury.id);
                          setDeleteConfirmOpen(true);
                        }}
                      >
                        Delete Report
                      </Button>
                    </div>
                  )}
                </TabsContent>
                
                <TabsContent value="reply" className="mt-4">
                  {selectedInjury.doctorReply ? (
                    <ScrollArea className="h-[400px] pr-4">
                      <div className="space-y-4">
                        <div>
                          <h4 className="text-sm font-semibold">Doctor's Response</h4>
                          <p>{selectedInjury.doctorReply.response}</p>
                        </div>
                        
                        <div>
                          <h4 className="text-sm font-semibold">Recommended Medication</h4>
                          <p>{selectedInjury.doctorReply.medication}</p>
                        </div>
                        
                        <div>
                          <h4 className="text-sm font-semibold">Doctor's Notes</h4>
                          <p>{selectedInjury.doctorReply.doctorNote}</p>
                        </div>
                        
                        <div className="grid grid-cols-2 gap-4">
                          <div>
                            <h4 className="text-sm font-semibold">Appointment Date</h4>
                            <p>{selectedInjury.doctorReply.appointmentDate}</p>
                          </div>
                          <div>
                            <h4 className="text-sm font-semibold">Appointment Time</h4>
                            <p>{selectedInjury.doctorReply.appointmentTime}</p>
                          </div>
                        </div>
                      </div>
                    </ScrollArea>
                  ) : (
                    <div className="h-[400px] flex items-center justify-center flex-col gap-4">
                      <p className="text-gray-500">The doctor hasn't provided a reply yet.</p>
                      <Badge className="bg-yellow-500">Awaiting Doctor's Response</Badge>
                    </div>
                  )}
                </TabsContent>
                
                <TabsContent value="assessment" className="mt-4">
                  {selectedInjury.assessment ? (
                    <ScrollArea className="h-[400px] pr-4">
                      <div className="space-y-4">
                        <div className="grid grid-cols-2 gap-4">
                          <div>
                            <h4 className="text-sm font-semibold">Diagnosis</h4>
                            <p>{selectedInjury.assessment.diagnosis}</p>
                          </div>
                          <div>
                            <h4 className="text-sm font-semibold">Severity</h4>
                            <p>{selectedInjury.assessment.severity}</p>
                          </div>
                        </div>
                        
                        {selectedInjury.assessment.diagnosisDetails && (
                          <div>
                            <h4 className="text-sm font-semibold">Diagnosis Details</h4>
                            <p>{selectedInjury.assessment.diagnosisDetails}</p>
                          </div>
                        )}
                        
                        <div>
                          <h4 className="text-sm font-semibold">Treatment Plan</h4>
                          <p>{selectedInjury.assessment.treatmentPlan}</p>
                        </div>
                        
                        {selectedInjury.assessment.rehabilitationProtocol && (
                          <div>
                            <h4 className="text-sm font-semibold">Rehabilitation Protocol</h4>
                            <p>{selectedInjury.assessment.rehabilitationProtocol}</p>
                          </div>
                        )}
                        
                        {selectedInjury.assessment.estimatedRecoveryTime && (
                          <div>
                            <h4 className="text-sm font-semibold">Estimated Recovery Time</h4>
                            <p>
                              {selectedInjury.assessment.estimatedRecoveryTime.value}{" "}
                              {selectedInjury.assessment.estimatedRecoveryTime.unit.toLowerCase()}
                            </p>
                          </div>
                        )}
                        
                        {selectedInjury.assessment.clearanceStatus && (
                          <div>
                            <h4 className="text-sm font-semibold">Clearance Status</h4>
                            <p>
                              {selectedInjury.assessment.clearanceStatus
                                .replace(/_/g, " ")
                                .toLowerCase()}
                            </p>
                          </div>
                        )}
                        
                        {selectedInjury.assessment.restrictionsList &&
                          selectedInjury.assessment.restrictionsList.length > 0 && (
                            <div>
                              <h4 className="text-sm font-semibold">Restrictions</h4>
                              <ul className="list-disc pl-5">
                                {selectedInjury.assessment.restrictionsList.map(
                                  (restriction, index) => (
                                    <li key={index}>{restriction}</li>
                                  )
                                )}
                              </ul>
                            </div>
                          )}
                      </div>
                    </ScrollArea>
                  ) : (
                    <div className="h-[400px] flex items-center justify-center flex-col gap-4">
                      <p className="text-gray-500">
                        A comprehensive medical assessment hasn't been completed yet.
                      </p>
                      <Badge className="bg-yellow-500">Assessment Pending</Badge>
                    </div>
                  )}
                </TabsContent>
              </Tabs>
            </>
          )}
        </DialogContent>
      </Dialog>
      
      {/* Delete confirmation dialog */}
      <Dialog open={deleteConfirmOpen} onOpenChange={setDeleteConfirmOpen}>
        <DialogContent>
          <DialogHeader>
            <DialogTitle>Confirm Deletion</DialogTitle>
            <DialogDescription>
              Are you sure you want to delete this injury report? This action cannot be undone.
            </DialogDescription>
          </DialogHeader>
          <DialogFooter>
            <Button variant="outline" onClick={() => setDeleteConfirmOpen(false)}>
              Cancel
            </Button>
            <Button 
              variant="destructive" 
              onClick={deleteInjuryReport}
              disabled={loading.delete}
            >
              {loading.delete ? "Deleting..." : "Delete Report"}
            </Button>
          </DialogFooter>
        </DialogContent>
      </Dialog>
    </div>
  );
}

export default FillInjuryForms;
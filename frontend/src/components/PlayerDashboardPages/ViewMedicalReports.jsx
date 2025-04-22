import { useState, useEffect, useRef } from "react";
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
  CardFooter,
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
  DialogTrigger,
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
import axios from "axios";

// API URLs for injury management
const api = axios.create({
  baseURL: "http://localhost:8000/api/v1",
});

// Add a request interceptor to automatically add the token to all requests
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

// Injury endpoint definitions
const INJURY_ENDPOINTS = {
  createTicket: "/injuries/create",
  getMyTickets: "/injuries/my-tickets",
  getTicketDetails: (id) => `/injuries/my-tickets/${id}`,
  updateReport: (id) => `/injuries/report/${id}`,
  deleteTicket: (id) => `/injuries/${id}`,
  getMessages: (id) => `/injuries/athlete/tickets/${id}/messages`,
  getAssessment: (id) => `/injuries/athlete/tickets/${id}/assessment`
};

// Add this near the top of your file where you define the INJURY_ENDPOINTS
const MEDICAL_REPORT_ENDPOINTS = {
  getMyReports: "/medical-reports/me",
  getReportDetails: (id) => `/medical-reports/me/${id}`
};

// Status badge color mapping
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

function MedicalRecords() {
  // State for injuries
  const [injuries, setInjuries] = useState([]);
  const [selectedInjury, setSelectedInjury] = useState(null);
  const [injuryDialogOpen, setInjuryDialogOpen] = useState(false);
  const [activeInjuryTab, setActiveInjuryTab] = useState("input");
  const [isEditMode, setIsEditMode] = useState(false);
  const [editableInjury, setEditableInjury] = useState(null);
  const [deleteConfirmOpen, setDeleteConfirmOpen] = useState(false);
  const [selectedTicketId, setSelectedTicketId] = useState(null);
  const [assignedDoctor, setAssignedDoctor] = useState(null);

  // State for loading and errors
  const [loading, setLoading] = useState({
    injuries: false,
    details: false,
    create: false,
    update: false,
    delete: false,
    records: false,
    recordDetails: false
  });

  const [error, setError] = useState({
    injuries: null,
    details: null,
    create: null,
    update: null,
    delete: null,
    records: null,
    recordDetails: null
  });

  // State for medical records
  const [records, setRecords] = useState([]);
  const [selectedRecord, setSelectedRecord] = useState(null);
  const [recordDialogOpen, setRecordDialogOpen] = useState(false);

  // State for searching
  const [injurySearchTerm, setInjurySearchTerm] = useState("");
  const [recordSearchTerm, setRecordSearchTerm] = useState("");

  // State for new injury form
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

  // Fetch athlete's injuries and assigned doctor on component mount
  useEffect(() => {
    fetchMyInjuries();
    fetchAssignedDoctor();
    fetchMyMedicalReports();
  }, []);

  // Check if user is logged in
  useEffect(() => {
    const token = sessionStorage.getItem("athleteAccessToken");
    if (!token) {
      toast.error("Please log in to access the injury management system");
    }
  }, []);

  // Function to fetch assigned doctor from local storage or API
const fetchAssignedDoctor = async () => {
  try {
    // First try to get from userData in localStorage
    const userDataStr = localStorage.getItem("userData");
    
    if (userDataStr) {
      const userData = JSON.parse(userDataStr);
      console.log("User data from localStorage:", userData);
      
      if (userData._id) {
        // If we have the athlete ID but need to fetch complete profile
        const response = await api.get(`/athletes/${userData._id}/details`);
        console.log("Athlete profile response:", response.data);
        
        if (response.data && response.data.medicalStaffAssigned) {
          setAssignedDoctor(response.data.medicalStaffAssigned);
          console.log("Assigned doctor ID:", response.data.medicalStaffAssigned);
        } else {
          console.log("No medicalStaffAssigned found in response:", response.data);
          // For debugging, let's see what fields exist in the response
          console.log("Available fields:", Object.keys(response.data));
        }
      }
    } else {
      // Fallback to the profile endpoint if no userData in localStorage
      const response = await api.get("/athletes/profile");
      if (response.data.data && response.data.data.medicalStaffAssigned) {
        setAssignedDoctor(response.data.data.medicalStaffAssigned);
      }
    }
  } catch (err) {
    console.error("Failed to fetch assigned doctor:", err);
    // Don't show an error toast here since it's not critical for the user
  }
};

// New function to fetch doctor's short messages for a ticket
const fetchShortMessages = async (ticketId) => {
  try {
    const response = await api.get(INJURY_ENDPOINTS.getMessages(ticketId));
    console.log("Short messages response:", response.data);
    
    if (response.data && response.data.data && response.data.data.messages && response.data.data.messages.length > 0) {
      // Get the most recent message
      const latestMessage = response.data.data.messages[0]; // API returns most recent first
      
      // Update the selected injury with the message data
      setSelectedInjury(prev => ({
        ...prev,
        doctorReply: {
          response: latestMessage.response,
          medication: latestMessage.medication,
          doctorNote: latestMessage.doctorNote,
          appointmentDate: new Date(latestMessage.appointmentDate).toLocaleDateString(),
          appointmentTime: latestMessage.appointmentTime,
          createdAt: latestMessage.createdAt
        },
        allMessages: response.data.data.messages
      }));
      return true;
    }
    return false;
  } catch (err) {
    console.error("Failed to fetch doctor messages:", err);
    // Don't show an error toast as this isn't critical
    return false;
  }
};


// New function to fetch medical assessment for a ticket
const fetchAssessment = async (ticketId) => {
  try {
    const response = await api.get(INJURY_ENDPOINTS.getAssessment(ticketId));
    console.log("Assessment response:", response.data);
    
    if (response.data && response.data.data && response.data.data.assessment) {
      // Update the selected injury with the assessment data
      setSelectedInjury(prev => ({
        ...prev,
        assessment: response.data.data.assessment,
        doctorInfo: response.data.data.doctorInfo
      }));
      return true;
    }
    return false;
  } catch (err) {
    console.error("Failed to fetch medical assessment:", err);
    // Don't show an error toast as this isn't critical
    return false;
  }
};

// Add these functions inside your MedicalRecords component

// Function to fetch all medical reports for the logged-in athlete
const fetchMyMedicalReports = async () => {
  setLoading((prev) => ({ ...prev, records: true }));
  setError((prev) => ({ ...prev, records: null }));

  try {
    const response = await api.get(MEDICAL_REPORT_ENDPOINTS.getMyReports);
    console.log("Medical reports response:", response.data);
    
    if (response.data?.data?.reports) {
      setRecords(response.data.data.reports);
    } else {
      setRecords([]);
    }
  } catch (err) {
    console.error("Failed to fetch medical reports:", err);
    setError((prev) => ({
      ...prev,
      records: err.response?.data?.message || "Failed to load your medical reports"
    }));
    toast.error(err.response?.data?.message || "Failed to load your medical records");
  } finally {
    setLoading((prev) => ({ ...prev, records: false }));
  }
};

// Function to fetch details of a specific medical report
const fetchMedicalReportDetails = async (reportId) => {
  setLoading((prev) => ({ ...prev, recordDetails: true }));
  setError((prev) => ({ ...prev, recordDetails: null }));

  try {
    const response = await api.get(MEDICAL_REPORT_ENDPOINTS.getReportDetails(reportId));
    console.log("Medical report details response:", response.data);
    
    if (response.data?.data) {
      setSelectedRecord(response.data.data);
      setRecordDialogOpen(true);
    }
  } catch (err) {
    console.error("Failed to fetch medical report details:", err);
    setError((prev) => ({
      ...prev,
      recordDetails: err.response?.data?.message || "Failed to load report details"
    }));
    toast.error(err.response?.data?.message || "Failed to load medical report details");
  } finally {
    setLoading((prev) => ({ ...prev, recordDetails: false }));
  }
};

  // Function to fetch all injuries for the logged-in athlete
  const fetchMyInjuries = async () => {
    setLoading((prev) => ({ ...prev, injuries: true }));
    setError((prev) => ({ ...prev, injuries: null }));

    try {
      // Use the api instance with interceptor
      const response = await api.get(INJURY_ENDPOINTS.getMyTickets);
      
      console.log("Injuries response:", response.data); // Debug logging
      
      // Process the injuries data
      const injuriesData = [];
      
      // Extract and format open tickets
      if (response.data.data && response.data.data.tickets) {
        if (response.data.data.tickets.open) {
          response.data.data.tickets.open.forEach((item) => {
            injuriesData.push({
              id: item.ticket._id,
              athleteName: "You", // Since these are the logged-in athlete's injuries
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
              rawData: item, // Keep the raw data for reference
            });
          });
        }

        // Extract and format in-progress tickets
        if (response.data.data.tickets.inProgress) {
          response.data.data.tickets.inProgress.forEach((item) => {
            // Find doctor's short message
            const doctorReply = {
              // This assumes the backend returns the latest message first
              // You might need to adjust this based on your actual data structure
              response: "Please check the detailed view for doctor's response.",
              medication: "Check detailed view",
              doctorNote: "Check detailed view",
              appointmentDate: "Check detailed view",
              appointmentTime: "Check detailed view",
            };

            injuriesData.push({
              id: item.ticket._id,
              athleteName: "You",
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
              doctorReply,
              assessment: null,
              rawData: item,
            });
          });
        }

        // Extract and format closed tickets
        if (response.data.data.tickets.closed) {
          response.data.data.tickets.closed.forEach((item) => {
            const doctorReply = {
              response: "Please check the detailed view for doctor's response.",
              medication: "Check detailed view",
              doctorNote: "Check detailed view",
              appointmentDate: "Check detailed view",
              appointmentTime: "Check detailed view",
            };

            injuriesData.push({
              id: item.ticket._id,
              athleteName: "You",
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
              doctorReply,
              assessment: item.assessment,
              rawData: item,
            });
          });
        }
      }

      setInjuries(injuriesData);
    } catch (err) {
      console.error("Failed to fetch injuries:", err);
      // Check for specific authentication errors
      if (err.response && err.response.status === 401) {
        // Token expired or invalid, suggest login
        toast.error("Your session has expired. Please log in again.");
      } else {
        setError((prev) => ({
          ...prev,
          injuries:
            err.response?.data?.message ||
            "Failed to load your injuries. Please try again.",
        }));
        toast.error(
          err.response?.data?.message || "Failed to load your injuries"
        );
      }
    } finally {
      setLoading((prev) => ({ ...prev, injuries: false }));
    }
  };

  // Function to fetch details of a specific injury ticket
  // Function to fetch details of a specific injury ticket along with doctor's messages and assessments
const fetchInjuryDetails = async (ticketId) => {
  setLoading((prev) => ({ ...prev, details: true }));
  setError((prev) => ({ ...prev, details: null }));

  try {
    // Use the api instance with interceptor to fetch basic ticket details
    const response = await api.get(INJURY_ENDPOINTS.getTicketDetails(ticketId));

    const data = response.data.data;
    const reportData = data.ticket.injuryReport_id;

    // Create initial formatted injury object with basic data
    const formattedInjury = {
      id: data.ticket._id,
      athleteName: "You",
      title: reportData.title,
      injuryType: reportData.injuryType,
      bodyPart: reportData.bodyPart,
      painLevel: reportData.painLevel,
      dateOfInjury: new Date(reportData.dateOfInjury).toISOString().split("T")[0],
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

    // Set initial data to prevent UI flicker
    setSelectedInjury(formattedInjury);
    setInjuryDialogOpen(true);

    // Fetch doctor's short messages in parallel
    try {
      const messagesResponse = await api.get(INJURY_ENDPOINTS.getMessages(ticketId));
      console.log("Doctor messages response:", messagesResponse.data);
      
      if (messagesResponse.data?.data?.messages?.length > 0) {
        // Get the most recent message
        const latestMessage = messagesResponse.data.data.messages[0]; // API returns latest first
        
        // Update the injury object with message data
        formattedInjury.doctorReply = {
          response: latestMessage.response,
          medication: latestMessage.medication,
          doctorNote: latestMessage.doctorNote,
          appointmentDate: new Date(latestMessage.appointmentDate).toLocaleDateString(),
          appointmentTime: latestMessage.appointmentTime,
          createdAt: latestMessage.createdAt
        };
        
        // Store all messages for potential future use
        formattedInjury.messages = messagesResponse.data.data.messages;
      }
    } catch (messageErr) {
      console.warn("Could not fetch doctor messages:", messageErr);
      // Don't fail the entire process for message fetch failure
    }

    // Fetch medical assessment in parallel
    try {
      const assessmentResponse = await api.get(INJURY_ENDPOINTS.getAssessment(ticketId));
      console.log("Medical assessment response:", assessmentResponse.data);
      
      if (assessmentResponse.data?.data?.assessment) {
        // Update the injury object with assessment data
        formattedInjury.assessment = assessmentResponse.data.data.assessment;
        formattedInjury.doctorInfo = assessmentResponse.data.data.doctorInfo;
      }
    } catch (assessmentErr) {
      console.warn("Could not fetch medical assessment:", assessmentErr);
      // Don't fail the entire process for assessment fetch failure
    }

    // Update the UI with complete data
    setSelectedInjury(formattedInjury);
    
  } catch (err) {
    console.error("Failed to fetch injury details:", err);
    setError((prev) => ({
      ...prev,
      details: err.response?.data?.message || "Failed to load injury details. Please try again."
    }));
    toast.error(err.response?.data?.message || "Failed to load injury details");
    setInjuryDialogOpen(false);
  } finally {
    setLoading((prev) => ({ ...prev, details: false }));
  }
};

  // Handle submitting a new injury report
const handleSubmitInjury = async (e) => {
  e.preventDefault();

  // Validate form
  if (
    !newInjury.title ||
    !newInjury.injuryType ||
    !newInjury.bodyPart ||
    !newInjury.dateOfInjury ||
    !newInjury.activityContext
  ) {
    toast.error("Please fill all required fields");
    return;
  }

  if (!assignedDoctor) {
    toast.error("No assigned doctor found. Please contact your administrator.");
    return;
  }

  // Get athlete ID from localStorage
  const userData = JSON.parse(localStorage.getItem("userData") || "{}");
  if (!userData._id) {
    toast.error("User data not found. Please log in again.");
    return;
  }

  setLoading((prev) => ({ ...prev, create: true }));
  setError((prev) => ({ ...prev, create: null }));

  try {
    // Format the data for submission
    const formattedInjury = {
      athlete: userData._id,                 // Required athlete ID
      doctor: assignedDoctor,                // Required doctor ID
      title: newInjury.title,                // Required
      injuryType: newInjury.injuryType,      // Required
      bodyPart: newInjury.bodyPart,          // Required
      painLevel: parseInt(newInjury.painLevel), // Required
      dateOfInjury: newInjury.dateOfInjury,  // Required
      activityContext: newInjury.activityContext, // Required
      
      // Optional fields with proper formatting
      symptoms: newInjury.symptoms
        ? newInjury.symptoms.split(",").map((s) => s.trim())
        : [],
      affectingPerformance: newInjury.affectingPerformance || "NONE",
      previouslyInjured: newInjury.previouslyInjured || false,
      notes: newInjury.notes || "",
      images: []  // Optional field, empty array if no images
    };

    console.log("Submitting injury report:", formattedInjury);

    // Make the API call to create the injury report using the api instance
    const response = await api.post(
      INJURY_ENDPOINTS.createTicket,
      formattedInjury
    );

    console.log("Injury report response:", response.data);

    // Show success toast
    toast.success("Injury report submitted successfully");

    // Reset form
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

    // Refresh the injury list
    fetchMyInjuries();
  } catch (err) {
    console.error("Failed to submit injury report:", err);
    
    // Provide more detailed error messages based on what went wrong
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
    
    setError((prev) => ({
      ...prev,
      create: errorMessage
    }));
    
    toast.error(errorMessage);
  } finally {
    setLoading((prev) => ({ ...prev, create: false }));
  }
};

  // Handle updating an injury report
  const handleUpdateInjury = async () => {
    if (!editableInjury || !editableInjury.reportId) {
      toast.error("Invalid injury data");
      return;
    }

    setLoading((prev) => ({ ...prev, update: true }));
    setError((prev) => ({ ...prev, update: null }));

    try {
      // Format the data for update
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

      // Make the API call to update the report using the api instance
      await api.put(
        INJURY_ENDPOINTS.updateReport(editableInjury.reportId),
        updateData
      );

      // Show success toast
      toast.success("Injury report updated successfully");

      // Exit edit mode and refresh data
      setIsEditMode(false);
      fetchMyInjuries();
      setInjuryDialogOpen(false);
    } catch (err) {
      console.error("Failed to update injury report:", err);
      setError((prev) => ({
        ...prev,
        update:
          err.response?.data?.message ||
          "Failed to update injury report. Please try again.",
      }));
      toast.error(
        err.response?.data?.message || "Failed to update injury report"
      );
    } finally {
      setLoading((prev) => ({ ...prev, update: false }));
    }
  };

  // Handle deleting an injury ticket
  const handleDeleteInjury = async () => {
    if (!selectedTicketId) {
      toast.error("No ticket selected for deletion");
      return;
    }

    setLoading((prev) => ({ ...prev, delete: true }));
    setError((prev) => ({ ...prev, delete: null }));

    try {
      // Make the API call to delete the ticket using the api instance
      await api.delete(INJURY_ENDPOINTS.deleteTicket(selectedTicketId));

      // Show success toast
      toast.success("Injury report deleted successfully");

      // Reset states and refresh data
      setDeleteConfirmOpen(false);
      setSelectedTicketId(null);
      setInjuryDialogOpen(false);
      fetchMyInjuries();
    } catch (err) {
      console.error("Failed to delete injury ticket:", err);
      setError((prev) => ({
        ...prev,
        delete:
          err.response?.data?.message ||
          "Failed to delete injury report. Please try again.",
      }));
      toast.error(
        err.response?.data?.message ||
          "Failed to delete injury report. Only OPEN tickets can be deleted."
      );
    } finally {
      setLoading((prev) => ({ ...prev, delete: false }));
      setDeleteConfirmOpen(false);
    }
  };

  // Handle viewing injury details
  const handleViewInjuryDetails = (injury) => {
    if (injury.id) {
      fetchInjuryDetails(injury.id);
    } else {
      setSelectedInjury(injury);
      setInjuryDialogOpen(true);
    }
    setActiveInjuryTab("input");
  };

  // Handle entering edit mode
  const handleEnterEditMode = () => {
    if (selectedInjury && selectedInjury.status === "OPEN") {
      setEditableInjury({ ...selectedInjury });
      setIsEditMode(true);
    } else {
      toast.error("Only open tickets can be edited");
    }
  };

  // Handle canceling edit mode
  const handleCancelEdit = () => {
    setIsEditMode(false);
    setEditableInjury(null);
  };

  // Handle edit form input changes
  const handleEditInputChange = (e) => {
    const { name, value, type, checked } = e.target;
    setEditableInjury((prev) => ({
      ...prev,
      [name]: type === "checkbox" ? checked : value,
    }));
  };

  // Filter injuries based on search term
  const filteredInjuries = injuries.filter((injury) =>
    injury.title.toLowerCase().includes(injurySearchTerm.toLowerCase())
  );

  // Filter records based on search term (mock functionality)
  // Update the filtered records definition to use the actual search term
const filteredRecords = records.filter((record) =>
  (record.testName || "").toLowerCase().includes(recordSearchTerm.toLowerCase()) ||
  (record.doctorInfo?.name || "").toLowerCase().includes(recordSearchTerm.toLowerCase())
);

  // Handle injury form input changes
  const handleInjuryInputChange = (e) => {
    const { name, value, type, checked } = e.target;
    setNewInjury((prev) => ({
      ...prev,
      [name]: type === "checkbox" ? checked : value,
    }));
  };

  // Handle opening medical record details (mock function)
  const handleViewRecordDetails = (record) => {
    setSelectedRecord(record);
    setRecordDialogOpen(true);
  };

  // Calculate BMI (utility function)
  const calculateBMI = (height, weight) => {
    if (!height || !weight) return "N/A";
    const heightInMeters = parseInt(height) / 100;
    const weightInKg = parseInt(weight);
    return (weightInKg / (heightInMeters * heightInMeters)).toFixed(2);
  };

  return (
    <div className="container mx-auto p-6">
      {/* Debug button - uncomment if needed */}
      {/* <Button 
        onClick={() => {
          console.log("Current token:", localStorage.getItem("token"));
          console.log("Is token valid format:", 
            localStorage.getItem("token")?.startsWith("eyJ") || "Invalid format");
        }}
        variant="outline"
        className="mb-4"
      >
        Debug Auth
      </Button> */}

      <Tabs defaultValue="injuries" className="w-full">
        <TabsList className="grid w-full grid-cols-2 mb-6">
          <TabsTrigger value="injuries" className="text-xl">
            Injury Management
          </TabsTrigger>
          <TabsTrigger value="records" className="text-xl">
            Medical Records
          </TabsTrigger>
        </TabsList>

        {/* Injuries Tab */}
        <TabsContent value="injuries">
          <div className="grid grid-cols-1 gap-6">
            {/* Add New Injury Card */}
            <Card>
              <CardHeader>
                <CardTitle className="text-2xl">Report New Injury</CardTitle>
                <CardDescription>
                  Fill out this form to report a new injury. Your medical staff
                  will be notified.
                </CardDescription>
              </CardHeader>
              <CardContent>
                <form onSubmit={handleSubmitInjury} className="space-y-4">
                  <div className="grid grid-cols-1 md:grid-cols-2 gap-4">
                    <div className="space-y-2">
                      <Label htmlFor="title" className="text-lg">
                        Injury Title*
                      </Label>
                      <Input
                        id="title"
                        name="title"
                        value={newInjury.title}
                        onChange={handleInjuryInputChange}
                        placeholder="E.g., Ankle Sprain"
                        className="text-lg p-3"
                        required
                        disabled={loading.create}
                      />
                    </div>
                    <div className="space-y-2">
                      <Label htmlFor="injuryType" className="text-lg">
                        Injury Type*
                      </Label>
                      <Select
                        onValueChange={(value) =>
                          handleInjuryInputChange({
                            target: { name: "injuryType", value },
                          })
                        }
                        defaultValue={newInjury.injuryType}
                        disabled={loading.create}
                      >
                        <SelectTrigger className="text-lg p-3">
                          <SelectValue placeholder="Select injury type" />
                        </SelectTrigger>
                        <SelectContent>
                          <SelectItem value="Sprain">Sprain</SelectItem>
                          <SelectItem value="Strain">Strain</SelectItem>
                          <SelectItem value="Fracture">Fracture</SelectItem>
                          <SelectItem value="Dislocation">
                            Dislocation
                          </SelectItem>
                          <SelectItem value="Contusion">
                            Contusion (Bruise)
                          </SelectItem>
                          <SelectItem value="Laceration">
                            Laceration (Cut)
                          </SelectItem>
                          <SelectItem value="Inflammation">
                            Inflammation
                          </SelectItem>
                          <SelectItem value="Other">Other</SelectItem>
                        </SelectContent>
                      </Select>
                    </div>
                    <div className="space-y-2">
                      <Label htmlFor="bodyPart" className="text-lg">
                        Body Part*
                      </Label>
                      <Input
                        id="bodyPart"
                        name="bodyPart"
                        value={newInjury.bodyPart}
                        onChange={handleInjuryInputChange}
                        placeholder="E.g., Right Ankle"
                        className="text-lg p-3"
                        required
                        disabled={loading.create}
                      />
                    </div>
                    <div className="space-y-2">
                      <Label htmlFor="painLevel" className="text-lg">
                        Pain Level (1-10)*
                      </Label>
                      <div className="flex items-center space-x-2">
                        <Input
                          id="painLevel"
                          name="painLevel"
                          type="range"
                          min="1"
                          max="10"
                          value={newInjury.painLevel}
                          onChange={handleInjuryInputChange}
                          className="flex-1"
                          disabled={loading.create}
                        />
                        <span className="text-lg font-medium">
                          {newInjury.painLevel}
                        </span>
                      </div>
                    </div>
                    <div className="space-y-2">
                      <Label htmlFor="dateOfInjury" className="text-lg">
                        Date of Injury*
                      </Label>
                      <Input
                        id="dateOfInjury"
                        name="dateOfInjury"
                        type="date"
                        value={newInjury.dateOfInjury}
                        onChange={handleInjuryInputChange}
                        className="text-lg p-3"
                        required
                        disabled={loading.create}
                        max={new Date().toISOString().split("T")[0]} // Prevent future dates
                      />
                    </div>
                    <div className="space-y-2">
                      <Label htmlFor="activityContext" className="text-lg">
                        Activity Context*
                      </Label>
                      <Input
                        id="activityContext"
                        name="activityContext"
                        value={newInjury.activityContext}
                        onChange={handleInjuryInputChange}
                        placeholder="E.g., Basketball Match"
                        className="text-lg p-3"
                        required
                        disabled={loading.create}
                      />
                    </div>
                    <div className="space-y-2">
                      <Label htmlFor="symptoms" className="text-lg">
                        Symptoms (comma separated)
                      </Label>
                      <Input
                        id="symptoms"
                        name="symptoms"
                        value={newInjury.symptoms}
                        onChange={handleInjuryInputChange}
                        placeholder="E.g., Swelling, Pain when walking"
                        className="text-lg p-3"
                        disabled={loading.create}
                      />
                    </div>
                    <div className="space-y-2">
                      <Label htmlFor="affectingPerformance" className="text-lg">
                        Effect on Performance
                      </Label>
                      <Select
                        onValueChange={(value) =>
                          handleInjuryInputChange({
                            target: { name: "affectingPerformance", value },
                          })
                        }
                        defaultValue={newInjury.affectingPerformance}
                        disabled={loading.create}
                      >
                        <SelectTrigger className="text-lg p-3">
                          <SelectValue placeholder="Select impact" />
                        </SelectTrigger>
                        <SelectContent>
                          <SelectItem value="CANNOT_PLAY">
                            Cannot Play
                          </SelectItem>
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
                          onChange={handleInjuryInputChange}
                          className="w-5 h-5"
                          disabled={loading.create}
                        />
                        <Label htmlFor="previouslyInjured" className="text-lg">
                          Previously injured this area?
                        </Label>
                      </div>
                    </div>
                  </div>
                  <div className="space-y-2">
                    <Label htmlFor="notes" className="text-lg">
                      Additional Notes
                    </Label>
                    <Textarea
                      id="notes"
                      name="notes"
                      value={newInjury.notes}
                      onChange={handleInjuryInputChange}
                      placeholder="Provide any additional details about your injury..."
                      className="text-lg p-3 min-h-[100px]"
                      disabled={loading.create}
                    />
                  </div>
                  <Button
                    type="submit"
                    className="text-lg py-3 px-6"
                    disabled={loading.create}
                  >
                    {loading.create ? (
                      <>
                        <span className="mr-2">Submitting...</span>
                      </>
                    ) : (
                      "Submit Injury Report"
                    )}
                  </Button>

                  {error.create && (
                    <div className="text-red-500 mt-2">{error.create}</div>
                  )}
                </form>
              </CardContent>
            </Card>

            {/* View Injuries Card */}
            <Card>
              <CardHeader>
                <CardTitle className="text-2xl">View Your Injuries</CardTitle>
                <CardDescription>
                  View and manage your reported injuries.
                </CardDescription>
                <Input
                  placeholder="Search injuries..."
                  value={injurySearchTerm}
                  onChange={(e) => setInjurySearchTerm(e.target.value)}
                  className="max-w-md text-lg p-3"
                />
              </CardHeader>
              <CardContent>
                {loading.injuries ? (
                  <div className="flex justify-center py-8">
                    <div className="animate-spin rounded-full h-12 w-12 border-t-2 border-b-2 border-blue-500"></div>
                  </div>
                ) : error.injuries ? (
                  <div className="text-center text-red-500 py-8">
                    {error.injuries}
                    <Button
                      variant="outline"
                      onClick={fetchMyInjuries}
                      className="mt-4"
                    >
                      Try Again
                    </Button>
                  </div>
                ) : (
                  <div className="rounded-md border">
                    <Table>
                      <TableHeader>
                        <TableRow>
                          <TableHead className="text-lg">Injury</TableHead>
                          <TableHead className="text-lg">Body Part</TableHead>
                          <TableHead className="text-lg">Date</TableHead>
                          <TableHead className="text-lg">Status</TableHead>
                          <TableHead className="text-lg text-right">
                            Actions
                          </TableHead>
                        </TableRow>
                      </TableHeader>
                      <TableBody>
                        {filteredInjuries.length > 0 ? (
                          filteredInjuries.map((injury) => (
                            <TableRow key={injury.id}>
                              <TableCell className="text-lg font-medium">
                                {injury.title}
                              </TableCell>
                              <TableCell className="text-lg">
                                {injury.bodyPart}
                              </TableCell>
                              <TableCell className="text-lg">
                                {new Date(
                                  injury.dateOfInjury
                                ).toLocaleDateString()}
                              </TableCell>
                              <TableCell>
                                <Badge
                                  className={`text-lg ${getStatusColor(
                                    injury.status
                                  )}`}
                                >
                                  {injury.status}
                                </Badge>
                              </TableCell>
                              <TableCell className="text-right">
                                <div className="flex justify-end gap-2">
                                  <Button
                                    variant="outline"
                                    onClick={() =>
                                      handleViewInjuryDetails(injury)
                                    }
                                    className="text-lg"
                                    disabled={loading.details}
                                  >
                                    View
                                  </Button>

                                  {injury.status === "OPEN" && (
                                    <Button
                                      variant="outline"
                                      className="text-lg text-red-500"
                                      onClick={() => {
                                        setSelectedTicketId(injury.id);
                                        setDeleteConfirmOpen(true);
                                      }}
                                      disabled={loading.delete}
                                    >
                                      Delete
                                    </Button>
                                  )}
                                </div>
                              </TableCell>
                            </TableRow>
                          ))
                        ) : (
                          <TableRow>
                            <TableCell
                              colSpan={5}
                              className="text-center py-4 text-lg"
                            >
                              No injuries found
                            </TableCell>
                          </TableRow>
                        )}
                      </TableBody>
                    </Table>
                  </div>
                )}
              </CardContent>
            </Card>
          </div>
        </TabsContent>

        {/* Medical Records Tab */}
        <TabsContent value="records">
          <Card>
            <CardHeader>
              <CardTitle className="text-2xl">Medical Records</CardTitle>
              <CardDescription>View your medical records.</CardDescription>
              <Input
                placeholder="Search records..."
                value={recordSearchTerm}
                onChange={(e) => setRecordSearchTerm(e.target.value)}
                className="max-w-md text-lg p-3"
              />
            </CardHeader>
            <CardContent>
              <div className="rounded-md border">
                <Table>
                  <TableHeader>
                    <TableRow>
                      <TableHead className="text-lg">Date</TableHead>
                      <TableHead className="text-lg">Type</TableHead>
                      <TableHead className="text-lg">Doctor</TableHead>
                      <TableHead className="text-lg text-right">
                        Actions
                      </TableHead>
                    </TableRow>
                  </TableHeader>
<TableBody>
  {loading.records ? (
    <TableRow>
      <TableCell colSpan={4} className="text-center py-8">
        <div className="flex justify-center">
          <div className="animate-spin rounded-full h-8 w-8 border-t-2 border-b-2 border-blue-500"></div>
        </div>
      </TableCell>
    </TableRow>
  ) : error.records ? (
    <TableRow>
      <TableCell colSpan={4} className="text-center py-4 text-lg text-red-500">
        {error.records}
        <Button variant="outline" onClick={fetchMyMedicalReports} className="mt-2">
          Try Again
        </Button>
      </TableCell>
    </TableRow>
  ) : filteredRecords.length > 0 ? (
    filteredRecords.map((record) => (
      <TableRow key={record.id}>
        <TableCell className="text-lg">
          {new Date(record.reportDate).toLocaleDateString()}
        </TableCell>
        <TableCell className="text-lg">
          {record.testName || "General Checkup"}
        </TableCell>
        <TableCell className="text-lg">
          {record.doctorInfo?.name || "Unknown Doctor"}
        </TableCell>
        <TableCell className="text-right">
          <Button
            variant="outline"
            onClick={() => fetchMedicalReportDetails(record.id)}
            className="text-lg"
            disabled={loading.recordDetails}
          >
            View Details
          </Button>
        </TableCell>
      </TableRow>
    ))
  ) : (
    <TableRow>
      <TableCell colSpan={4} className="text-center py-4 text-lg">
        No medical records found
      </TableCell>
    </TableRow>
  )}
</TableBody>
                </Table>
              </div>
            </CardContent>
          </Card>
        </TabsContent>
      </Tabs>

      {/* Injury Details Dialog */}
      {selectedInjury && (
        <Dialog
          open={injuryDialogOpen}
          onOpenChange={(open) => {
            setInjuryDialogOpen(open);
            if (!open) {
              setIsEditMode(false);
              setEditableInjury(null);
            }
          }}
        >
          <DialogContent className="max-w-3xl">
            <DialogHeader>
              <DialogTitle className="text-2xl">
                {isEditMode ? "Edit Injury Report" : selectedInjury.title}
              </DialogTitle>
              <DialogDescription>
                Reported on{" "}
                {new Date(selectedInjury.createdAt).toLocaleDateString()} •
                Status:{" "}
                <Badge className={getStatusColor(selectedInjury.status)}>
                  {selectedInjury.status}
                </Badge>
              </DialogDescription>
            </DialogHeader>

            {isEditMode ? (
              // Edit Form
              <div className="space-y-4">
                <div className="grid grid-cols-1 md:grid-cols-2 gap-4">
                  <div className="space-y-2">
                    <Label htmlFor="edit-title" className="text-lg">
                      Injury Title*
                    </Label>
                    <Input
                      id="edit-title"
                      name="title"
                      value={editableInjury.title}
                      onChange={handleEditInputChange}
                      className="text-lg p-3"
                      required
                    />
                  </div>
                  <div className="space-y-2">
                    <Label htmlFor="edit-injuryType" className="text-lg">
                      Injury Type*
                    </Label>
                    <Select
                      onValueChange={(value) =>
                        handleEditInputChange({
                          target: { name: "injuryType", value },
                        })
                      }
                      defaultValue={editableInjury.injuryType}
                    >
                      <SelectTrigger
                        className="text-lg p-3"
                        id="edit-injuryType"
                      >
                        <SelectValue placeholder="Select injury type" />
                      </SelectTrigger>
                      <SelectContent>
                        <SelectItem value="Sprain">Sprain</SelectItem>
                        <SelectItem value="Strain">Strain</SelectItem>
                        <SelectItem value="Fracture">Fracture</SelectItem>
                        <SelectItem value="Dislocation">Dislocation</SelectItem>
                        <SelectItem value="Contusion">
                          Contusion (Bruise)
                        </SelectItem>
                        <SelectItem value="Laceration">
                          Laceration (Cut)
                        </SelectItem>
                        <SelectItem value="Inflammation">
                          Inflammation
                        </SelectItem>
                        <SelectItem value="Other">Other</SelectItem>
                      </SelectContent>
                    </Select>
                  </div>
                  <div className="space-y-2">
                    <Label htmlFor="edit-bodyPart" className="text-lg">
                      Body Part*
                    </Label>
                    <Input
                      id="edit-bodyPart"
                      name="bodyPart"
                      value={editableInjury.bodyPart}
                      onChange={handleEditInputChange}
                      className="text-lg p-3"
                      required
                    />
                  </div>
                  <div className="space-y-2">
                    <Label htmlFor="edit-painLevel" className="text-lg">
                      Pain Level (1-10)*
                    </Label>
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
                      <span className="text-lg font-medium">
                        {editableInjury.painLevel}
                      </span>
                    </div>
                  </div>
                  <div className="space-y-2">
                    <Label htmlFor="edit-notes" className="text-lg">
                      Additional Notes
                    </Label>
                    <Textarea
                      id="edit-notes"
                      name="notes"
                      value={editableInjury.notes}
                      onChange={handleEditInputChange}
                      className="text-lg p-3"
                    />
                  </div>
                </div>

                <div className="flex justify-end space-x-3 mt-4">
                  <Button
                    variant="outline"
                    onClick={handleCancelEdit}
                    disabled={loading.update}
                  >
                    Cancel
                  </Button>
                  <Button
                    onClick={handleUpdateInjury}
                    disabled={loading.update}
                  >
                    {loading.update ? "Updating..." : "Save Changes"}
                  </Button>
                </div>
              </div>
            ) : (
              // View Details
              <Tabs
                defaultValue={activeInjuryTab}
                onValueChange={setActiveInjuryTab}
                className="w-full"
              >
                <TabsList className="grid w-full grid-cols-3">
                  <TabsTrigger value="input" className="text-lg">
                    Your Input
                  </TabsTrigger>
                  <TabsTrigger value="reply" className="text-lg">
                    Short Reply
                    {!selectedInjury.doctorReply && (
                      <span className="ml-2 text-xs bg-yellow-500 text-white px-2 py-1 rounded-full">
                        Pending
                      </span>
                    )}
                  </TabsTrigger>
                  <TabsTrigger value="assessment" className="text-lg">
                    Medical Assessment
                    {!selectedInjury.assessment && (
                      <span className="ml-2 text-xs bg-yellow-500 text-white px-2 py-1 rounded-full">
                        Pending
                      </span>
                    )}
                  </TabsTrigger>
                </TabsList>

                <TabsContent value="input" className="mt-6">
                  <ScrollArea className="h-[350px] pr-4">
                    <div className="space-y-4">
                      <div className="grid grid-cols-2 gap-4">
                        <div>
                          <h4 className="text-lg font-semibold">Injury Type</h4>
                          <p className="text-lg">{selectedInjury.injuryType}</p>
                        </div>
                        <div>
                          <h4 className="text-lg font-semibold">Body Part</h4>
                          <p className="text-lg">{selectedInjury.bodyPart}</p>
                        </div>
                        <div>
                          <h4 className="text-lg font-semibold">Pain Level</h4>
                          <p className="text-lg">
                            {selectedInjury.painLevel}/10
                          </p>
                        </div>
                        <div>
                          <h4 className="text-lg font-semibold">
                            Date of Injury
                          </h4>
                          <p className="text-lg">
                            {new Date(
                              selectedInjury.dateOfInjury
                            ).toLocaleDateString()}
                          </p>
                        </div>
                        <div>
                          <h4 className="text-lg font-semibold">
                            Activity Context
                          </h4>
                          <p className="text-lg">
                            {selectedInjury.activityContext}
                          </p>
                        </div>
                        <div>
                          <h4 className="text-lg font-semibold">
                            Affecting Performance
                          </h4>
                          <p className="text-lg">
                            {selectedInjury.affectingPerformance
                              .replace("_", " ")
                              .toLowerCase()}
                          </p>
                        </div>
                      </div>

                      <div>
                        <h4 className="text-lg font-semibold">Symptoms</h4>
                        {selectedInjury.symptoms &&
                        selectedInjury.symptoms.length > 0 ? (
                          <ul className="list-disc pl-5">
                            {selectedInjury.symptoms.map((symptom, index) => (
                              <li key={index} className="text-lg">
                                {symptom}
                              </li>
                            ))}
                          </ul>
                        ) : (
                          <p className="text-lg">No symptoms reported</p>
                        )}
                      </div>

                      <div>
                        <h4 className="text-lg font-semibold">
                          Previously Injured
                        </h4>
                        <p className="text-lg">
                          {selectedInjury.previouslyInjured ? "Yes" : "No"}
                        </p>
                      </div>

                      <div>
                        <h4 className="text-lg font-semibold">
                          Additional Notes
                        </h4>
                        <p className="text-lg">
                          {selectedInjury.notes ||
                            "No additional notes provided."}
                        </p>
                      </div>
                    </div>
                  </ScrollArea>

                  {selectedInjury.status === "OPEN" && (
                    <div className="flex justify-end mt-4 space-x-3">
                      <Button onClick={handleEnterEditMode} variant="outline">
                        Edit Report
                      </Button>
                      <Button
                        onClick={() => {
                          setSelectedTicketId(selectedInjury.id);
                          setDeleteConfirmOpen(true);
                        }}
                        variant="destructive"
                        disabled={loading.delete}
                      >
                        Delete Report
                      </Button>
                    </div>
                  )}
                </TabsContent>

                <TabsContent value="reply" className="mt-6">
                  {selectedInjury.doctorReply ? (
                    <ScrollArea className="h-[350px] pr-4">
                      <div className="space-y-4">
                        <div>
                          <h4 className="text-lg font-semibold">
                            Doctor's Response
                          </h4>
                          <p className="text-lg">
                            {selectedInjury.doctorReply.response}
                          </p>
                        </div>
                        <div>
                          <h4 className="text-lg font-semibold">
                            Recommended Medication
                          </h4>
                          <p className="text-lg">
                            {selectedInjury.doctorReply.medication}
                          </p>
                        </div>
                        <div>
                          <h4 className="text-lg font-semibold">
                            Doctor's Notes
                          </h4>
                          <p className="text-lg">
                            {selectedInjury.doctorReply.doctorNote}
                          </p>
                        </div>
                        <div className="grid grid-cols-2 gap-4">
                          <div>
                            <h4 className="text-lg font-semibold">
                              Appointment Date
                            </h4>
                            <p className="text-lg">
                              {selectedInjury.doctorReply.appointmentDate}
                            </p>
                          </div>
                          <div>
                            <h4 className="text-lg font-semibold">
                              Appointment Time
                            </h4>
                            <p className="text-lg">
                              {selectedInjury.doctorReply.appointmentTime}
                            </p>
                          </div>
                        </div>
                      </div>
                    </ScrollArea>
                  ) : (
                    <div className="h-[350px] flex items-center justify-center flex-col gap-4">
                      <p className="text-lg text-center text-gray-500">
                        The doctor hasn't provided a reply yet.
                      </p>
                      <Badge className="bg-yellow-500 text-lg py-2 px-4">
                        Awaiting Doctor's Response
                      </Badge>
                    </div>
                  )}
                </TabsContent>

                <TabsContent value="assessment" className="mt-6">
                  {selectedInjury.assessment ? (
                    <ScrollArea className="h-[350px] pr-4">
                      <div className="space-y-4">
                        <div className="grid grid-cols-2 gap-4">
                          <div>
                            <h4 className="text-lg font-semibold">Diagnosis</h4>
                            <p className="text-lg">
                              {selectedInjury.assessment.diagnosis}
                            </p>
                          </div>
                          <div>
                            <h4 className="text-lg font-semibold">Severity</h4>
                            <p className="text-lg">
                              {selectedInjury.assessment.severity}
                            </p>
                          </div>
                        </div>

                        {selectedInjury.assessment.diagnosisDetails && (
                          <div>
                            <h4 className="text-lg font-semibold">
                              Diagnosis Details
                            </h4>
                            <p className="text-lg">
                              {selectedInjury.assessment.diagnosisDetails}
                            </p>
                          </div>
                        )}

                        <div>
                          <h4 className="text-lg font-semibold">
                            Treatment Plan
                          </h4>
                          <p className="text-lg">
                            {selectedInjury.assessment.treatmentPlan}
                          </p>
                        </div>

                        {selectedInjury.assessment.rehabilitationProtocol && (
                          <div>
                            <h4 className="text-lg font-semibold">
                              Rehabilitation Protocol
                            </h4>
                            <p className="text-lg">
                              {selectedInjury.assessment.rehabilitationProtocol}
                            </p>
                          </div>
                        )}

                        {selectedInjury.assessment.estimatedRecoveryTime && (
                          <div>
                            <h4 className="text-lg font-semibold">
                              Estimated Recovery Time
                            </h4>
                            <p className="text-lg">
                              {
                                selectedInjury.assessment.estimatedRecoveryTime
                                  .value
                              }{" "}
                              {selectedInjury.assessment.estimatedRecoveryTime.unit.toLowerCase()}
                            </p>
                          </div>
                        )}

                        {selectedInjury.assessment.clearanceStatus && (
                          <div>
                            <h4 className="text-lg font-semibold">
                              Clearance Status
                            </h4>
                            <p className="text-lg">
                              {selectedInjury.assessment.clearanceStatus
                                .replace(/_/g, " ")
                                .toLowerCase()}
                            </p>
                          </div>
                        )}

                        {selectedInjury.assessment.restrictionsList &&
                          selectedInjury.assessment.restrictionsList.length >
                            0 && (
                            <div>
                              <h4 className="text-lg font-semibold">
                                Restrictions
                              </h4>
                              <ul className="list-disc pl-5">
                                {selectedInjury.assessment.restrictionsList.map(
                                  (restriction, index) => (
                                    <li key={index} className="text-lg">
                                      {restriction}
                                    </li>
                                  )
                                )}
                              </ul>
                            </div>
                          )}
                      </div>
                    </ScrollArea>
                  ) : (
                    <div className="h-[350px] flex items-center justify-center flex-col gap-4">
                      <p className="text-lg text-center text-gray-500">
                        A comprehensive medical assessment hasn't been completed
                        yet.
                      </p>
                      <Badge className="bg-yellow-500 text-lg py-2 px-4">
                        Assessment Pending
                      </Badge>
                    </div>
                  )}
                </TabsContent>
              </Tabs>
            )}

            <DialogFooter>
              <Button
                onClick={() => setInjuryDialogOpen(false)}
                className="text-lg"
              >
                Close
              </Button>
            </DialogFooter>
          </DialogContent>
        </Dialog>
      )}

      {/* Delete Confirmation Dialog */}
      <Dialog open={deleteConfirmOpen} onOpenChange={setDeleteConfirmOpen}>
        <DialogContent className="max-w-md">
          <DialogHeader>
            <DialogTitle className="text-xl">Delete Injury Report?</DialogTitle>
            <DialogDescription className="pt-2">
              This action cannot be undone. The report will be permanently
              deleted.
              <div className="text-amber-600 mt-2 font-medium">
                Note: Only open tickets that haven't been processed by a doctor
                can be deleted.
              </div>
            </DialogDescription>
          </DialogHeader>
          <div className="flex justify-end space-x-3 mt-6">
            <Button
              variant="outline"
              onClick={() => setDeleteConfirmOpen(false)}
              disabled={loading.delete}
            >
              Cancel
            </Button>
            <Button
              onClick={handleDeleteInjury}
              disabled={loading.delete}
              variant="destructive"
              className="bg-red-600 hover:bg-red-700"
            >
              {loading.delete ? "Deleting..." : "Delete"}
            </Button>
          </div>
        </DialogContent>
      </Dialog>

      {/* Medical Record Details Dialog (Placeholder) */}
      {selectedRecord && (
<Dialog open={recordDialogOpen} onOpenChange={setRecordDialogOpen}>
  <DialogContent className="max-w-4xl">
    <DialogHeader>
      <DialogTitle className="text-2xl">
        {selectedRecord?.testName || "Medical Report"}
      </DialogTitle>
      <DialogDescription>
        {selectedRecord && (
          <div className="flex flex-wrap gap-2 items-center mt-1">
            <span>Reported on {new Date(selectedRecord.reportDate).toLocaleDateString()}</span>
            <Badge className={selectedRecord.medicalClearance === "Fit to Play" ? "bg-green-500" : "bg-amber-500"}>
              {selectedRecord.medicalClearance}
            </Badge>
            <span className="ml-2">•</span>
            <span>Status: {selectedRecord.medicalStatus}</span>
            {selectedRecord.nextCheckupDate && (
              <>
                <span className="ml-2">•</span>
                <span>Next Checkup: {new Date(selectedRecord.nextCheckupDate).toLocaleDateString()}</span>
              </>
            )}
          </div>
        )}
      </DialogDescription>
    </DialogHeader>

    {selectedRecord ? (
      <ScrollArea className="h-[500px] pr-4">
        <div className="space-y-6">
          {/* Doctor Information */}
          {selectedRecord.doctorInfo && (
            <Card className="p-4 bg-slate-50">
              <h3 className="text-xl font-bold mb-2">Medical Staff Information</h3>
              <div className="grid grid-cols-2 gap-x-8 gap-y-2">
                <div>
                  <span className="font-semibold">Name:</span> {selectedRecord.doctorInfo.name}
                </div>
                {selectedRecord.doctorInfo.specialization && (
                  <div>
                    <span className="font-semibold">Specialization:</span> {selectedRecord.doctorInfo.specialization}
                  </div>
                )}
                {selectedRecord.doctorInfo.designation && (
                  <div>
                    <span className="font-semibold">Designation:</span> {selectedRecord.doctorInfo.designation}
                  </div>
                )}
                {selectedRecord.doctorInfo.contactNumber && (
                  <div>
                    <span className="font-semibold">Contact:</span> {selectedRecord.doctorInfo.contactNumber}
                  </div>
                )}
              </div>
            </Card>
          )}
          
          {/* Vitals Section */}
          {selectedRecord.vitals && Object.keys(selectedRecord.vitals).some(key => selectedRecord.vitals[key]) && (
            <div>
              <h3 className="text-xl font-bold mb-2">Vitals</h3>
              <div className="grid grid-cols-3 gap-x-8 gap-y-2">
                {selectedRecord.vitals.height && (
                  <div>
                    <span className="font-semibold">Height:</span> {selectedRecord.vitals.height} cm
                  </div>
                )}
                {selectedRecord.vitals.weight && (
                  <div>
                    <span className="font-semibold">Weight:</span> {selectedRecord.vitals.weight} kg
                  </div>
                )}
                {selectedRecord.vitals.bmi && (
                  <div>
                    <span className="font-semibold">BMI:</span> {selectedRecord.vitals.bmi}
                  </div>
                )}
                {selectedRecord.vitals.bloodPressure && (
                  <div>
                    <span className="font-semibold">Blood Pressure:</span> {selectedRecord.vitals.bloodPressure}
                  </div>
                )}
                {selectedRecord.vitals.restingHeartRate && (
                  <div>
                    <span className="font-semibold">Resting Heart Rate:</span> {selectedRecord.vitals.restingHeartRate} bpm
                  </div>
                )}
                {selectedRecord.vitals.oxygenSaturation && (
                  <div>
                    <span className="font-semibold">O₂ Saturation:</span> {selectedRecord.vitals.oxygenSaturation}%
                  </div>
                )}
              </div>
            </div>
          )}

          {/* Medical Condition Section */}
          <div>
            <h3 className="text-xl font-bold mb-2">Medical Status</h3>
            <div className="grid grid-cols-2 gap-x-8 gap-y-2">
              <div>
                <span className="font-semibold">Medical Status:</span> {selectedRecord.medicalStatus}
              </div>
              <div>
                <span className="font-semibold">Medical Clearance:</span> {selectedRecord.medicalClearance}
              </div>
              {selectedRecord.chronicMedicalCondition && (
                <div className="col-span-2">
                  <span className="font-semibold">Chronic Medical Condition:</span> {selectedRecord.chronicMedicalCondition}
                </div>
              )}
              {selectedRecord.prescribedMedication && (
                <div className="col-span-2">
                  <span className="font-semibold">Prescribed Medication:</span> {selectedRecord.prescribedMedication.name} 
                  {selectedRecord.prescribedMedication.dosage && ` (${selectedRecord.prescribedMedication.dosage})`}
                </div>
              )}
            </div>
          </div>

          {/* Test Results */}
          {selectedRecord.testResults && Object.keys(selectedRecord.testResults).some(key => selectedRecord.testResults[key]) && (
            <div>
              <h3 className="text-xl font-bold mb-2">Test Results</h3>
              <div className="space-y-2">
                {Object.entries(selectedRecord.testResults).map(([key, value]) => {
                  if (value && key !== "additionalResults") {
                    return (
                      <div key={key} className="grid grid-cols-3">
                        <span className="font-semibold col-span-1 capitalize">{key.replace(/([A-Z])/g, ' $1').trim()}:</span>
                        <span className="col-span-2">{value}</span>
                      </div>
                    );
                  }
                  return null;
                })}
                
                {selectedRecord.testResults.additionalResults && selectedRecord.testResults.additionalResults.length > 0 && (
                  <div className="mt-2">
                    <span className="font-semibold">Additional Results:</span>
                    <ul className="list-disc pl-8 mt-1">
                      {selectedRecord.testResults.additionalResults.map((result, idx) => (
                        <li key={idx}>{result}</li>
                      ))}
                    </ul>
                  </div>
                )}
              </div>
            </div>
          )}

          {/* Notes and Recommendations */}
          <div>
            <h3 className="text-xl font-bold mb-2">Notes & Recommendations</h3>
            {selectedRecord.doctorsNotes && (
              <div className="mb-4">
                <h4 className="text-lg font-semibold">Doctor's Notes</h4>
                <p className="whitespace-pre-line">{selectedRecord.doctorsNotes}</p>
              </div>
            )}
            
            {selectedRecord.physicianNotes && (
              <div className="mb-4">
                <h4 className="text-lg font-semibold">Physician Notes</h4>
                <p className="whitespace-pre-line">{selectedRecord.physicianNotes}</p>
              </div>
            )}
            
            {selectedRecord.recommendations && selectedRecord.recommendations.length > 0 && (
              <div>
                <h4 className="text-lg font-semibold">Recommendations</h4>
                <ul className="list-disc pl-6">
                  {selectedRecord.recommendations.map((rec, idx) => (
                    <li key={idx} className="mb-1">{rec}</li>
                  ))}
                </ul>
              </div>
            )}
          </div>

          {/* Attachments */}
          {selectedRecord.attachments && selectedRecord.attachments.length > 0 && (
            <div>
              <h3 className="text-xl font-bold mb-2">Attachments</h3>
              <div className="grid grid-cols-2 gap-4">
                {selectedRecord.attachments.map((attachment, idx) => (
                  <a 
                    key={idx}
                    href={attachment.fileUrl}
                    target="_blank"
                    rel="noopener noreferrer"
                    className="flex items-center p-3 border rounded-md hover:bg-slate-50"
                  >
                    <div className="mr-3 text-blue-500">
                      <svg xmlns="http://www.w3.org/2000/svg" width="24" height="24" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2" strokeLinecap="round" strokeLinejoin="round">
                        <path d="M14 2H6a2 2 0 0 0-2 2v16a2 2 0 0 0 2 2h12a2 2 0 0 0 2-2V8z"></path>
                        <polyline points="14 2 14 8 20 8"></polyline>
                        <line x1="16" y1="13" x2="8" y2="13"></line>
                        <line x1="16" y1="17" x2="8" y2="17"></line>
                        <polyline points="10 9 9 9 8 9"></polyline>
                      </svg>
                    </div>
                    <div>
                      <p className="font-medium">{attachment.name || `File ${idx + 1}`}</p>
                      <p className="text-sm text-gray-500">
                        {new Date(attachment.uploadDate).toLocaleDateString()}
                      </p>
                    </div>
                  </a>
                ))}
              </div>
            </div>
          )}
        </div>
      </ScrollArea>
    ) : (
      <div className="h-64 flex items-center justify-center">
        <div className="animate-spin rounded-full h-12 w-12 border-t-2 border-b-2 border-blue-500"></div>
      </div>
    )}

    <DialogFooter>
      <Button onClick={() => setRecordDialogOpen(false)} className="text-lg">
        Close
      </Button>
    </DialogFooter>
  </DialogContent>
</Dialog>
      )}

      <ToastContainer position="bottom-right" />
    </div>
  );
}

export default MedicalRecords;
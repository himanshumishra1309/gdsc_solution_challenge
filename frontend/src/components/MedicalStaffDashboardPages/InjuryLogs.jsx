import { useState, useEffect } from "react";
import axios from "axios";
import { format } from "date-fns";
import { 
  Card, CardContent, CardHeader, CardTitle, CardDescription 
} from "@/components/ui/card";
import { 
  Tabs, TabsContent, TabsList, TabsTrigger 
} from "@/components/ui/tabs";
import { 
  Table, TableBody, TableCell, TableHead, TableHeader, TableRow 
} from "@/components/ui/table";
import { 
  Dialog, DialogContent, DialogDescription, DialogFooter, 
  DialogHeader, DialogTitle, DialogTrigger 
} from "@/components/ui/dialog";
import { 
  Select, SelectContent, SelectItem, SelectTrigger, SelectValue 
} from "@/components/ui/select";
import { 
  Form, FormControl, FormDescription, FormField, FormItem, 
  FormLabel, FormMessage 
} from "@/components/ui/form";
import { Button } from "@/components/ui/button";
import { Input } from "@/components/ui/input";
import { Textarea } from "@/components/ui/textarea";
import { Badge } from "@/components/ui/badge";
import { Alert, AlertDescription, AlertTitle } from "@/components/ui/alert";
import { ScrollArea } from "@/components/ui/scroll-area";
import { Loader2, AlertCircle, CheckCircle2, Calendar } from "lucide-react";
import { useForm } from "react-hook-form";
import { zodResolver } from "@hookform/resolvers/zod";
import * as z from "zod";
import { ToastContainer, toast } from "react-toastify";
import 'react-toastify/dist/ReactToastify.css';

// Create an API instance
const api = axios.create({
  baseURL: "http://localhost:8000/api/v1",
  withCredentials: true,
});

// Add token to all requests
api.interceptors.request.use(
  (config) => {
    config.withCredentials = true;
    const token = sessionStorage.getItem("coachAccessToken") || localStorage.getItem("token");
    if (token) {
      config.headers.Authorization = `Bearer ${token}`;
    }
    return config;
  },
  (error) => {
    return Promise.reject(error);
  }
);

// Define endpoints
const ENDPOINTS = {
  getDoctorInjuries: "/injuries/doctor", // Will get current doctor's injuries
  addShortMessage: (ticketId) => `/injuries/${ticketId}/short-message`,
  addAssessment: (ticketId) => `/injuries/${ticketId}/assessment`,
  updateAssessment: (assessmentId) => `/injuries/assessment/${assessmentId}`,
};

// Validation schemas
const shortMessageSchema = z.object({
  response: z.string().min(5, "Response must be at least 5 characters"),
  medication: z.string().min(3, "Medication must be at least 3 characters"),
  doctorNote: z.string().min(5, "Doctor note must be at least 5 characters"),
  appointmentDate: z.string().min(1, "Appointment date is required"),
  appointmentTime: z.string().min(1, "Appointment time is required"),
});

const assessmentSchema = z.object({
  diagnosis: z.string().min(5, "Diagnosis must be at least 5 characters"),
  diagnosisDetails: z.string().optional(),
  severity: z.enum(["MINOR", "MODERATE", "SEVERE", "CRITICAL"]),
  treatmentPlan: z.string().min(10, "Treatment plan must be detailed"),
  rehabilitationProtocol: z.string().optional(),
  restrictionsList: z.string().optional(),
  estimatedRecoveryTime: z.object({
    value: z.number().min(1, "Value must be at least 1"),
    unit: z.enum(["DAYS", "WEEKS", "MONTHS"])
  }),
  clearanceStatus: z.enum([
    "NO_ACTIVITY", 
    "LIMITED_ACTIVITY", 
    "FULL_CLEARANCE_PENDING", 
    "FULLY_CLEARED"
  ]),
  notes: z.string().optional(),
});

const InjuryLogs = () => {
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState(null);
  const [injuries, setInjuries] = useState({
    open: [],
    inProgress: [],
    closed: [],
  });
  const [statistics, setStatistics] = useState({
    total: 0,
    open: 0,
    inProgress: 0,
    closed: 0,
  });
  const [doctorInfo, setDoctorInfo] = useState(null);
  
  const [selectedTicket, setSelectedTicket] = useState(null);
  const [shortMessageDialogOpen, setShortMessageDialogOpen] = useState(false);
  const [assessmentDialogOpen, setAssessmentDialogOpen] = useState(false);
  const [submitting, setSubmitting] = useState(false);

  // Setup forms
  const shortMessageForm = useForm({
    resolver: zodResolver(shortMessageSchema),
    defaultValues: {
      response: "",
      medication: "",
      doctorNote: "",
      appointmentDate: format(new Date(), "yyyy-MM-dd"),
      appointmentTime: "10:00",
    },
  });

  const assessmentForm = useForm({
    resolver: zodResolver(assessmentSchema),
    defaultValues: {
      diagnosis: "",
      diagnosisDetails: "",
      severity: "MODERATE",
      treatmentPlan: "",
      rehabilitationProtocol: "",
      restrictionsList: "",
      estimatedRecoveryTime: {
        value: 7,
        unit: "DAYS",
      },
      clearanceStatus: "LIMITED_ACTIVITY",
      notes: "",
    },
  });

  // Fetch injuries on component mount
  useEffect(() => {
    fetchInjuries();
  }, []);

  const fetchInjuries = async () => {
    setLoading(true);
    setError(null);
    
    try {
      const response = await api.get(ENDPOINTS.getDoctorInjuries);
      console.log("Injuries response:", response.data);
      
      if (response.data && response.data.data) {
        setInjuries({
          open: response.data.data.tickets.open || [],
          inProgress: response.data.data.tickets.inProgress || [],
          closed: response.data.data.tickets.closed || [],
        });
        
        setStatistics(response.data.data.statistics || {
          total: 0,
          open: 0,
          inProgress: 0,
          closed: 0,
        });
        
        setDoctorInfo(response.data.data.doctor || null);
      }
    } catch (err) {
      console.error("Failed to fetch injuries:", err);
      setError(err.response?.data?.message || "Failed to fetch injuries");
      toast.error("Failed to fetch injuries. Please try again.");
    } finally {
      setLoading(false);
    }
  };

  const handleOpenShortMessageDialog = (ticket) => {
    setSelectedTicket(ticket);
    setShortMessageDialogOpen(true);
  };

  const handleOpenAssessmentDialog = (ticket) => {
    setSelectedTicket(ticket);
    setAssessmentDialogOpen(true);
  };

  const handleSubmitShortMessage = async (data) => {
    if (!selectedTicket) return;
    
    setSubmitting(true);
    
    try {
      const response = await api.post(
        ENDPOINTS.addShortMessage(selectedTicket.ticket._id),
        data
      );
      
      console.log("Short message response:", response.data);
      toast.success("Short message added successfully");
      
      // Close dialog and reset form
      setShortMessageDialogOpen(false);
      shortMessageForm.reset();
      
      // Refresh data
      fetchInjuries();
    } catch (err) {
      console.error("Failed to add short message:", err);
      toast.error(err.response?.data?.message || "Failed to add short message");
    } finally {
      setSubmitting(false);
    }
  };

  const handleSubmitAssessment = async (data) => {
    if (!selectedTicket) return;
    
    setSubmitting(true);
    
    // Convert comma-separated restrictions list to array
    if (data.restrictionsList) {
      data.restrictionsList = data.restrictionsList
        .split(',')
        .map(item => item.trim())
        .filter(item => item);
    } else {
      data.restrictionsList = [];
    }
    
    try {
      const response = await api.post(
        ENDPOINTS.addAssessment(selectedTicket.ticket._id),
        data
      );
      
      console.log("Assessment response:", response.data);
      toast.success("Assessment added successfully");
      
      // Close dialog and reset form
      setAssessmentDialogOpen(false);
      assessmentForm.reset();
      
      // Refresh data
      fetchInjuries();
    } catch (err) {
      console.error("Failed to add assessment:", err);
      toast.error(err.response?.data?.message || "Failed to add assessment");
    } finally {
      setSubmitting(false);
    }
  };

  const getStatusBadge = (status) => {
    switch (status) {
      case "OPEN":
        return <Badge className="bg-red-500 hover:bg-red-600">Open</Badge>;
      case "IN_PROGRESS":
        return <Badge className="bg-yellow-500 hover:bg-yellow-600">In Progress</Badge>;
      case "CLOSED":
        return <Badge className="bg-green-500 hover:bg-green-600">Closed</Badge>;
      default:
        return <Badge className="bg-gray-500 hover:bg-gray-600">Unknown</Badge>;
    }
  };
  
  if (loading) {
    return (
      <div className="flex items-center justify-center h-[70vh]">
        <Loader2 className="mr-2 h-8 w-8 animate-spin" />
        <p className="text-xl">Loading injury data...</p>
      </div>
    );
  }
  
  if (error) {
    return (
      <Alert variant="destructive" className="max-w-2xl mx-auto mt-8">
        <AlertCircle className="h-4 w-4" />
        <AlertTitle>Error</AlertTitle>
        <AlertDescription>
          {error}
          <Button 
            className="ml-4" 
            variant="outline" 
            onClick={fetchInjuries}
          >
            Try Again
          </Button>
        </AlertDescription>
      </Alert>
    );
  }

  return (
    <div className="container mx-auto p-6">
      {doctorInfo && (
        <Card className="mb-6">
          <CardHeader>
            <CardTitle>Medical Staff Dashboard</CardTitle>
            <CardDescription>
              Welcome, Dr. {doctorInfo.name}. You have {statistics.total} total injury cases.
            </CardDescription>
          </CardHeader>
          <CardContent>
            <div className="grid grid-cols-4 gap-4">
              <div className="bg-blue-50 p-4 rounded-lg">
                <p className="text-sm text-blue-700">Total Cases</p>
                <h3 className="text-2xl font-bold">{statistics.total}</h3>
              </div>
              <div className="bg-red-50 p-4 rounded-lg">
                <p className="text-sm text-red-700">Open</p>
                <h3 className="text-2xl font-bold">{statistics.open}</h3>
              </div>
              <div className="bg-yellow-50 p-4 rounded-lg">
                <p className="text-sm text-yellow-700">In Progress</p>
                <h3 className="text-2xl font-bold">{statistics.inProgress}</h3>
              </div>
              <div className="bg-green-50 p-4 rounded-lg">
                <p className="text-sm text-green-700">Closed</p>
                <h3 className="text-2xl font-bold">{statistics.closed}</h3>
              </div>
            </div>
          </CardContent>
        </Card>
      )}

      <Tabs defaultValue="current">
        <TabsList className="grid w-full grid-cols-2 mb-8">
          <TabsTrigger value="current" className="text-lg">Current Injuries</TabsTrigger>
          <TabsTrigger value="past" className="text-lg">Past Injuries</TabsTrigger>
        </TabsList>
        
        <TabsContent value="current">
          <Card>
            <CardHeader>
              <CardTitle>Current Injuries</CardTitle>
              <CardDescription>
                Manage open and in-progress injury cases that require your attention.
              </CardDescription>
            </CardHeader>
            <CardContent>
              <div className="rounded-md border">
                <Table>
                  <TableHeader>
                    <TableRow>
                      <TableHead>Athlete</TableHead>
                      <TableHead>Injury</TableHead>
                      <TableHead>Body Part</TableHead>
                      <TableHead>Date Reported</TableHead>
                      <TableHead>Status</TableHead>
                      <TableHead className="text-right">Actions</TableHead>
                    </TableRow>
                  </TableHeader>
                  <TableBody>
                    {/* Open cases */}
                    {injuries.open.length > 0 ? (
                      injuries.open.map((item) => (
                        <TableRow key={item.ticket._id}>
                          <TableCell className="font-medium">
                            {item.ticket.injuryReport_id.athlete.name}
                          </TableCell>
                          <TableCell>{item.ticket.injuryReport_id.title}</TableCell>
                          <TableCell>{item.ticket.injuryReport_id.bodyPart}</TableCell>
                          <TableCell>
                            {new Date(item.ticket.createdAt).toLocaleDateString()}
                          </TableCell>
                          <TableCell>
                            {getStatusBadge(item.ticket.ticketStatus)}
                          </TableCell>
                          <TableCell className="text-right">
                            <Button
                              variant="outline"
                              size="sm"
                              className="mr-2"
                              onClick={() => handleOpenShortMessageDialog(item)}
                            >
                              Send Quick Reply
                            </Button>
                            <Button
                              variant="default"
                              size="sm"
                              onClick={() => handleOpenAssessmentDialog(item)}
                            >
                              Full Assessment
                            </Button>
                          </TableCell>
                        </TableRow>
                      ))
                    ) : null}
                    
                    {/* In-progress cases */}
                    {injuries.inProgress.length > 0 ? (
                      injuries.inProgress.map((item) => (
                        <TableRow key={item.ticket._id}>
                          <TableCell className="font-medium">
                            {item.ticket.injuryReport_id.athlete.name}
                          </TableCell>
                          <TableCell>{item.ticket.injuryReport_id.title}</TableCell>
                          <TableCell>{item.ticket.injuryReport_id.bodyPart}</TableCell>
                          <TableCell>
                            {new Date(item.ticket.createdAt).toLocaleDateString()}
                          </TableCell>
                          <TableCell>
                            {getStatusBadge(item.ticket.ticketStatus)}
                          </TableCell>
                          <TableCell className="text-right">
                            <Button
                              variant="default"
                              size="sm"
                              onClick={() => handleOpenAssessmentDialog(item)}
                            >
                              Complete Assessment
                            </Button>
                          </TableCell>
                        </TableRow>
                      ))
                    ) : null}
                    
                    {/* No cases message */}
                    {injuries.open.length === 0 && injuries.inProgress.length === 0 && (
                      <TableRow>
                        <TableCell colSpan={6} className="text-center py-6 text-muted-foreground">
                          No current injuries requiring your attention.
                        </TableCell>
                      </TableRow>
                    )}
                  </TableBody>
                </Table>
              </div>
            </CardContent>
          </Card>
        </TabsContent>
        
        <TabsContent value="past">
          <Card>
            <CardHeader>
              <CardTitle>Past Injuries</CardTitle>
              <CardDescription>
                View previously assessed and closed injury cases.
              </CardDescription>
            </CardHeader>
            <CardContent>
              <div className="rounded-md border">
                <Table>
                  <TableHeader>
                    <TableRow>
                      <TableHead>Athlete</TableHead>
                      <TableHead>Injury</TableHead>
                      <TableHead>Body Part</TableHead>
                      <TableHead>Date Reported</TableHead>
                      <TableHead>Severity</TableHead>
                      <TableHead className="text-right">View Details</TableHead>
                    </TableRow>
                  </TableHeader>
                  <TableBody>
                    {injuries.closed.length > 0 ? (
                      injuries.closed.map((item) => (
                        <TableRow key={item.ticket._id}>
                          <TableCell className="font-medium">
                            {item.ticket.injuryReport_id.athlete.name}
                          </TableCell>
                          <TableCell>{item.ticket.injuryReport_id.title}</TableCell>
                          <TableCell>{item.ticket.injuryReport_id.bodyPart}</TableCell>
                          <TableCell>
                            {new Date(item.ticket.createdAt).toLocaleDateString()}
                          </TableCell>
                          <TableCell>
                            {item.assessment ? (
                              <Badge className={
                                item.assessment.severity === "MINOR" 
                                  ? "bg-green-500" 
                                  : item.assessment.severity === "MODERATE" 
                                  ? "bg-yellow-500" 
                                  : item.assessment.severity === "SEVERE" 
                                  ? "bg-orange-500" 
                                  : "bg-red-500"
                              }>
                                {item.assessment.severity}
                              </Badge>
                            ) : (
                              <span className="text-gray-500">Not specified</span>
                            )}
                          </TableCell>
                          <TableCell className="text-right">
                            <Button
                              variant="outline"
                              size="sm"
                              onClick={() => {
                                // Here you could show a dialog with detailed view
                                toast.info("This feature is coming soon");
                              }}
                            >
                              View Details
                            </Button>
                          </TableCell>
                        </TableRow>
                      ))
                    ) : (
                      <TableRow>
                        <TableCell colSpan={6} className="text-center py-6 text-muted-foreground">
                          No past injuries to display.
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

      {/* Short Message Dialog - Improved Version */}
{shortMessageDialogOpen && (
  <div className="fixed inset-0 z-50 flex items-center justify-center">
    {/* Backdrop */}
    <div 
      className="absolute inset-0 bg-black/50" 
      onClick={() => !submitting && setShortMessageDialogOpen(false)}
    ></div>
    
    {/* Dialog content */}
    <div className="relative bg-white rounded-lg max-w-3xl w-full mx-4 shadow-xl overflow-hidden">
      {/* Header */}
      <div className="px-6 py-4 border-b bg-blue-50">
        <h3 className="text-lg font-medium text-blue-900">Quick Medical Response</h3>
        <p className="text-sm text-blue-700 mt-1">
          Provide initial feedback and schedule an appointment
        </p>
      </div>
      
      <div className="flex flex-col md:flex-row">
        {/* Left side - Injury details */}
        {selectedTicket && (
          <div className="w-full md:w-1/3 p-4 bg-gray-50 border-r">
            <h4 className="font-medium text-gray-900 mb-3">Patient Details</h4>
            <div className="space-y-3">
              <div>
                <p className="text-xs text-gray-500">Athlete</p>
                <p className="font-medium">{selectedTicket.ticket.injuryReport_id.athlete.name}</p>
              </div>
              <div>
                <p className="text-xs text-gray-500">Injury</p>
                <p className="font-medium">{selectedTicket.ticket.injuryReport_id.title}</p>
              </div>
              <div>
                <p className="text-xs text-gray-500">Body Part</p>
                <p className="font-medium">{selectedTicket.ticket.injuryReport_id.bodyPart}</p>
              </div>
              <div>
                <p className="text-xs text-gray-500">Pain Level</p>
                <div className="flex items-center">
                  <div className="flex-1 h-2 bg-gray-200 rounded-full">
                    <div 
                      className={`h-2 rounded-full ${
                        selectedTicket.ticket.injuryReport_id.painLevel >= 7 ? 'bg-red-500' :
                        selectedTicket.ticket.injuryReport_id.painLevel >= 4 ? 'bg-yellow-500' :
                        'bg-green-500'
                      }`}
                      style={{ width: `${selectedTicket.ticket.injuryReport_id.painLevel * 10}%` }}
                    ></div>
                  </div>
                  <span className="ml-2 font-medium">{selectedTicket.ticket.injuryReport_id.painLevel}/10</span>
                </div>
              </div>
              {selectedTicket.ticket.injuryReport_id.symptoms && (
                <div>
                  <p className="text-xs text-gray-500">Symptoms</p>
                  <p className="font-medium">
                    {Array.isArray(selectedTicket.ticket.injuryReport_id.symptoms) 
                      ? selectedTicket.ticket.injuryReport_id.symptoms.join(", ")
                      : selectedTicket.ticket.injuryReport_id.symptoms}
                  </p>
                </div>
              )}
            </div>
          </div>
        )}
        
        {/* Right side - Form */}
        <div className="w-full md:w-2/3 p-4">
          <form onSubmit={shortMessageForm.handleSubmit(handleSubmitShortMessage)} className="space-y-4">
            {/* Response section */}
            <div>
              <label className="block text-sm font-medium text-gray-700 mb-1">
                Initial Assessment <span className="text-red-500">*</span>
              </label>
              <textarea 
                {...shortMessageForm.register("response", { required: "Initial assessment is required" })}
                placeholder="Provide your initial assessment of the injury based on reported symptoms..."
                className={`w-full border rounded-md p-3 min-h-[100px] ${
                  shortMessageForm.formState.errors.response ? 'border-red-500' : 'border-gray-300'
                }`}
              />
              {shortMessageForm.formState.errors.response && (
                <p className="mt-1 text-sm text-red-500">{shortMessageForm.formState.errors.response.message}</p>
              )}
            </div>
            
            {/* Two column layout for medication and notes */}
            <div className="grid grid-cols-1 md:grid-cols-2 gap-4">
              <div>
                <label className="block text-sm font-medium text-gray-700 mb-1">
                  Recommended Medication <span className="text-red-500">*</span>
                </label>
                <input 
                  type="text"
                  {...shortMessageForm.register("medication", { required: "Medication is required" })}
                  placeholder="e.g., Ibuprofen 400mg twice daily"
                  className={`w-full border rounded-md p-3 ${
                    shortMessageForm.formState.errors.medication ? 'border-red-500' : 'border-gray-300'
                  }`}
                />
                {shortMessageForm.formState.errors.medication && (
                  <p className="mt-1 text-sm text-red-500">{shortMessageForm.formState.errors.medication.message}</p>
                )}
              </div>
              
              <div>
                <label className="block text-sm font-medium text-gray-700 mb-1">
                  Doctor's Notes <span className="text-red-500">*</span>
                </label>
                <textarea 
                  {...shortMessageForm.register("doctorNote", { required: "Doctor note is required" })}
                  placeholder="Additional notes for the athlete"
                  className={`w-full border rounded-md p-3 min-h-[80px] ${
                    shortMessageForm.formState.errors.doctorNote ? 'border-red-500' : 'border-gray-300'
                  }`}
                />
                {shortMessageForm.formState.errors.doctorNote && (
                  <p className="mt-1 text-sm text-red-500">{shortMessageForm.formState.errors.doctorNote.message}</p>
                )}
              </div>
            </div>
            
            {/* Appointment section with title */}
            <div className="pt-2 border-t mt-6">
              <h4 className="font-medium text-gray-900 mb-3">Schedule Appointment</h4>
              <div className="grid grid-cols-1 md:grid-cols-2 gap-4">
                <div>
                  <label className="block text-sm font-medium text-gray-700 mb-1">
                    Date <span className="text-red-500">*</span>
                  </label>
                  <input 
                    type="date"
                    {...shortMessageForm.register("appointmentDate", { required: "Appointment date is required" })}
                    min={format(new Date(), "yyyy-MM-dd")}
                    className={`w-full border rounded-md p-3 ${
                      shortMessageForm.formState.errors.appointmentDate ? 'border-red-500' : 'border-gray-300'
                    }`}
                  />
                  {shortMessageForm.formState.errors.appointmentDate && (
                    <p className="mt-1 text-sm text-red-500">{shortMessageForm.formState.errors.appointmentDate.message}</p>
                  )}
                </div>
                
                <div>
                  <label className="block text-sm font-medium text-gray-700 mb-1">
                    Time <span className="text-red-500">*</span>
                  </label>
                  <input 
                    type="time"
                    {...shortMessageForm.register("appointmentTime", { required: "Appointment time is required" })}
                    className={`w-full border rounded-md p-3 ${
                      shortMessageForm.formState.errors.appointmentTime ? 'border-red-500' : 'border-gray-300'
                    }`}
                  />
                  {shortMessageForm.formState.errors.appointmentTime && (
                    <p className="mt-1 text-sm text-red-500">{shortMessageForm.formState.errors.appointmentTime.message}</p>
                  )}
                </div>
              </div>
            </div>
            
            {/* Footer with actions */}
            <div className="flex justify-end space-x-3 pt-4 border-t mt-4">
              <button 
                type="button" 
                className="px-4 py-2 border border-gray-300 rounded-md text-gray-700 bg-white hover:bg-gray-50 transition-colors"
                onClick={() => setShortMessageDialogOpen(false)}
                disabled={submitting}
              >
                Cancel
              </button>
              <button 
                type="submit"
                className="px-4 py-2 bg-blue-600 text-white rounded-md hover:bg-blue-500 transition-colors disabled:opacity-50 flex items-center"
                disabled={submitting}
              >
                {submitting ? (
                  <>
                    <div className="w-4 h-4 border-2 border-white border-t-transparent rounded-full animate-spin mr-2"></div>
                    Sending...
                  </>
                ) : (
                  "Send Response"
                )}
              </button>
            </div>
          </form>
        </div>
      </div>
    </div>
  </div>
)}

      {/* Injury Assessment Dialog */}
      <Dialog open={assessmentDialogOpen} onOpenChange={setAssessmentDialogOpen}>
        <DialogContent className="max-w-3xl max-h-[90vh] overflow-y-auto">
          <DialogHeader  className="border-b pb-4">
            <DialogTitle className="text-xl">Complete Injury Assessment</DialogTitle>
            <DialogDescription>
              Provide a comprehensive assessment of the athlete's injury.
            </DialogDescription>
          </DialogHeader>
          
          {selectedTicket && (
            <div className="mb-4 p-4 bg-gray-50 rounded-md border">
              <h4 className="font-medium text-gray-900 mb-2">Injury Details</h4>
              <p><strong>Athlete:</strong> {selectedTicket.ticket.injuryReport_id.athlete.name}</p>
              <p><strong>Injury:</strong> {selectedTicket.ticket.injuryReport_id.title}</p>
              <p><strong>Body Part:</strong> {selectedTicket.ticket.injuryReport_id.bodyPart}</p>
              <p><strong>Pain Level:</strong> {selectedTicket.ticket.injuryReport_id.painLevel}/10</p>
            </div>
          )}
          
          <ScrollArea className="h-[500px] pr-4">
            <Form {...assessmentForm}>
              <form onSubmit={assessmentForm.handleSubmit(handleSubmitAssessment)} className="space-y-6">
                <FormField
                  control={assessmentForm.control}
                  name="diagnosis"
                  render={({ field }) => (
                    <FormItem>
                      <FormLabel className="font-medium">Diagnosis*</FormLabel>
                      <FormControl>
                        <Input 
                          placeholder="e.g., Grade 2 Ankle Sprain"
                          {...field}
                          className="border-gray-300 focus:border-blue-500 focus:ring-blue-500"
                        />
                      </FormControl>
                      <FormMessage className="text-red-500 text-sm" />
                    </FormItem>
                  )}
                />
                
                <FormField
                  control={assessmentForm.control}
                  name="diagnosisDetails"
                  render={({ field }) => (
                    <FormItem>
                      <FormLabel className="font-medium">Diagnosis Details</FormLabel>
                      <FormControl>
                        <Textarea 
                          placeholder="Provide detailed diagnosis information"
                          className="min-h-[100px] border-gray-300 focus:border-blue-500 focus:ring-blue-500"
                          {...field}
                        />
                      </FormControl>
                      <FormMessage className="text-red-500 text-sm" />
                    </FormItem>
                  )}
                />
                
                <FormField
                  control={assessmentForm.control}
                  name="severity"
                  render={({ field }) => (
                    <FormItem>
                      <FormLabel className="font-medium">Severity*</FormLabel>
                      <Select 
                        onValueChange={field.onChange} 
                        defaultValue={field.value}
                      >
                        <FormControl>
                          <SelectTrigger className="border-gray-300 focus:border-blue-500 focus:ring-blue-500">
                            <SelectValue placeholder="Select severity" />
                          </SelectTrigger>
                        </FormControl>
                        <SelectContent>
                          <SelectItem value="MINOR">Minor</SelectItem>
                          <SelectItem value="MODERATE">Moderate</SelectItem>
                          <SelectItem value="SEVERE">Severe</SelectItem>
                          <SelectItem value="CRITICAL">Critical</SelectItem>
                        </SelectContent>
                      </Select>
                      <FormMessage className="text-red-500 text-sm" />
                    </FormItem>
                  )}
                />
                
                <FormField
                  control={assessmentForm.control}
                  name="treatmentPlan"
                  render={({ field }) => (
                    <FormItem>
                      <FormLabel className="font-medium">Treatment Plan*</FormLabel>
                      <FormControl>
                        <Textarea 
                          placeholder="Detailed treatment plan"
                          className="min-h-[120px] border-gray-300 focus:border-blue-500 focus:ring-blue-500 "
                          {...field}
                        />
                      </FormControl>
                      <FormMessage className="text-red-500 text-sm" />
                    </FormItem>
                  )}
                />
                
                <FormField
                  control={assessmentForm.control}
                  name="rehabilitationProtocol"
                  render={({ field }) => (
                    <FormItem>
                      <FormLabel className="font-medium">Rehabilitation Protocol</FormLabel>
                      <FormControl>
                        <Textarea 
                          placeholder="Detailed rehabilitation protocol"
                          className="min-h-[100px] border-gray-300 focus:border-blue-500 focus:ring-blue-500 "
                          {...field}
                        />
                      </FormControl>
                      <FormMessage className="text-red-500 text-sm"  />
                    </FormItem>
                  )}
                />
                
                <FormField
                  control={assessmentForm.control}
                  name="restrictionsList"
                  render={({ field }) => (
                    <FormItem>
                      <FormLabel className="font-medium">Restrictions (comma-separated)</FormLabel>
                      <FormControl>
                        <Input 
                          placeholder="e.g., No running, No weight bearing"
                          className="border-gray-300 focus:border-blue-500 focus:ring-blue-500"
                          {...field}
                        />
                      </FormControl>
                      <FormDescription className="text-gray-500 text-sm">
                        Enter restrictions separated by commas
                      </FormDescription>
                      <FormMessage className="text-red-500 text-sm"/>
                    </FormItem>
                  )}
                />
                
                <div className="grid grid-cols-1 md:grid-cols-2 gap-6">
                  <FormField
                    control={assessmentForm.control}
                    name="estimatedRecoveryTime.value"
                    render={({ field }) => (
                      <FormItem>
                        <FormLabel className="font-medium">Recovery Time</FormLabel>
                        <FormControl>
                          <Input 
                            type="number"
                            min="1"
                            className="border-gray-300 focus:border-blue-500 focus:ring-blue-500"
                            {...field}
                            onChange={(e) => field.onChange(parseInt(e.target.value))}
                          />
                        </FormControl>
                        <FormMessage className="text-red-500 text-sm" />
                      </FormItem>
                    )}
                  />
                  
                  <FormField
                    control={assessmentForm.control}
                    name="estimatedRecoveryTime.unit"
                    render={({ field }) => (
                      <FormItem>
                        <FormLabel className="font-medium">Time Unit</FormLabel>
                        <Select 
                          onValueChange={field.onChange} 
                          defaultValue={field.value}
                        >
                          <FormControl>
                            <SelectTrigger className="border-gray-300 focus:border-blue-500 focus:ring-blue-500">
                              <SelectValue placeholder="Select time unit" />
                            </SelectTrigger>
                          </FormControl>
                          <SelectContent>
                            <SelectItem value="DAYS">Days</SelectItem>
                            <SelectItem value="WEEKS">Weeks</SelectItem>
                            <SelectItem value="MONTHS">Months</SelectItem>
                          </SelectContent>
                        </Select>
                        <FormMessage className="text-red-500 text-sm" />
                      </FormItem>
                    )}
                  />
                </div>
                
                <FormField
                  control={assessmentForm.control}
                  name="clearanceStatus"
                  render={({ field }) => (
                    <FormItem>
                      <FormLabel>Clearance Status</FormLabel>
                      <Select 
                        onValueChange={field.onChange} 
                        defaultValue={field.value}
                      >
                        <FormControl>
                          <SelectTrigger>
                            <SelectValue placeholder="Select clearance status" />
                          </SelectTrigger>
                        </FormControl>
                        <SelectContent>
                          <SelectItem value="NO_ACTIVITY">No Activity</SelectItem>
                          <SelectItem value="LIMITED_ACTIVITY">Limited Activity</SelectItem>
                          <SelectItem value="FULL_CLEARANCE_PENDING">Full Clearance Pending</SelectItem>
                          <SelectItem value="FULLY_CLEARED">Fully Cleared</SelectItem>
                        </SelectContent>
                      </Select>
                      <FormMessage />
                    </FormItem>
                  )}
                />
                
                <FormField
                  control={assessmentForm.control}
                  name="notes"
                  render={({ field }) => (
                    <FormItem>
                      <FormLabel className="font-medium">Additional Notes</FormLabel>
                      <FormControl>
                        <Textarea 
                          placeholder="Any additional notes"
                          className="min-h-[80px] border-gray-300 focus:border-blue-500 focus:ring-blue-500"
                          {...field}
                        />
                      </FormControl>
                      <FormMessage className="text-red-500 text-sm"/>
                    </FormItem>
                  )}
                />
                
                <DialogFooter className="border-t pt-4">
                  <Button 
                    type="button" 
                    variant="outline" 
                    onClick={() => setAssessmentDialogOpen(false)}
                    disabled={submitting}
                    className="mr-2"
                  >
                    Cancel
                  </Button>
                  <Button 
                    type="submit"
                    disabled={submitting}
                    className="bg-green-600 hover:bg-green-700"
                  >
                    {submitting ? (
                      <>
                        <Loader2 className="mr-2 h-4 w-4 animate-spin" />
                        Submitting...
                      </>
                    ) : (
                      "Submit Assessment"
                    )}
                  </Button>
                </DialogFooter>
              </form>
            </Form>
          </ScrollArea>
        </DialogContent>
      </Dialog>

      <ToastContainer position="bottom-right" />
    </div>
  );
};

export default InjuryLogs;
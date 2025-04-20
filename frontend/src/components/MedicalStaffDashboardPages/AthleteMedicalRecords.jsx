import { useState, useEffect } from "react";
import { useParams, useNavigate } from "react-router-dom";
import axios from "axios";
import { Tabs, TabsContent, TabsList, TabsTrigger } from "@/components/ui/tabs";
import { Card, CardContent, CardHeader, CardTitle } from "@/components/ui/card";
import { Button } from "@/components/ui/button";
import { Input } from "@/components/ui/input";
import { Label } from "@/components/ui/label";
import { Textarea } from "@/components/ui/textarea";
import { Badge } from "@/components/ui/badge";
import { Separator } from "@/components/ui/separator";
import {
  Select,
  SelectContent,
  SelectItem,
  SelectTrigger,
  SelectValue,
} from "@/components/ui/select";
import {
  Dialog,
  DialogContent,
  DialogHeader,
  DialogTitle,
  DialogFooter,
} from "@/components/ui/dialog";
import {
    Loader2,
    ArrowLeft,
    Clipboard,
    FilePlus,
    ListFilter,
    Calendar,
    Stethoscope,
    Activity,
    BarChart,
    UserRound,
    Dumbbell,
    Brain,
    Filter,
    FileText,
    HeartPulse,
    Apple,
    Minus,
    Plus,
    Upload,
    X,
    Printer  // Add this line
  } from "lucide-react";
import { Alert, AlertDescription } from "@/components/ui/alert";
import { Accordion, AccordionContent, AccordionItem, AccordionTrigger } from "@/components/ui/accordion";

function AthleteMedicalRecords() {
  const { athleteId } = useParams();
  const navigate = useNavigate();
  const [loading, setLoading] = useState(true);
  const [submitLoading, setSubmitLoading] = useState(false);
  const [athlete, setAthlete] = useState(null);
  const [reportDates, setReportDates] = useState([]);
  const [error, setError] = useState(null);
  const [selectedReport, setSelectedReport] = useState(null);
  const [reportModalOpen, setReportModalOpen] = useState(false);
  const [selectedDate, setSelectedDate] = useState(null);
  const [dateMedicalReports, setDateMedicalReports] = useState([]);
  const [selectedFiles, setSelectedFiles] = useState([]);
  const [dateLoading, setDateLoading] = useState(false);
  const [allMedicalReports, setAllMedicalReports] = useState([]);
  
  // State for the new medical report form with all possible fields from the backend model
  const [newReport, setNewReport] = useState({
    testName: "",
    testDate: "",
    medicalStatus: "Active",
    medicalClearance: "Fit to Play",
    chronicMedicalCondition: "",
    vitals: {
      height: "",
      weight: "",
      bloodPressure: "",
      restingHeartRate: "",
      oxygenSaturation: "",
      respiratoryRate: "",
      bodyTemperature: "",
    },
    performanceMetrics: {
      vo2Max: "",
      sprintSpeed: "",
      agilityScore: "",
      strength: "",
      flexibilityTest: "",
      reactionTime: "",
      enduranceLevel: "",
    },
    injuryDetails: {
      currentInjuries: [{ type: "", location: "", severity: "", notes: "" }],
      pastInjuries: "",
      ongoingTreatment: "",
      returnToPlayStatus: "",
    },
    testResults: {
      bloodTest: "",
      urineTest: "",
      ecg: "",
      mriScan: "",
      xray: "",
      additionalResults: []
    },
    nutrition: {
      caloricIntake: "",
      waterIntake: "",
      nutrientDeficiencies: "",
      supplements: [""],
      dietaryRestrictions: [""],
      dietaryRecommendations: "",
    },
    mentalHealth: {
      stressLevel: "",
      sleepQuality: "",
      cognitiveScore: "",
      mentalHealthNotes: "",
    },
    doctorsNotes: "",
    physicianNotes: "",
    recommendations: [""],
    nextCheckupDate: ""
  });

  // Fetch athlete data and medical report dates
  useEffect(() => {
    const fetchData = async () => {
        setLoading(true);
        try {
          // Fetch athlete data
          const athleteResponse = await axios.get(
            `http://localhost:8000/api/v1/athletes/${athleteId}/details`,
            { withCredentials: true }
          );
          
          if (athleteResponse.data) {
            setAthlete(athleteResponse.data);
          }
          
          // Fetch medical reports directly instead of dates
          const reportsResponse = await axios.get(
            `http://localhost:8000/api/v1/medical-reports/athlete/${athleteId}`,
            { withCredentials: true }
          );
          
          if (reportsResponse.data.success) {
            const reports = reportsResponse.data.data.reports;
            
            // Group reports by date for the sidebar display
            const reportsByDate = {};
            reports.forEach(report => {
              const date = new Date(report.reportDate).toISOString().split('T')[0];
              if (!reportsByDate[date]) {
                reportsByDate[date] = {
                  _id: date,
                  count: 1,
                  tests: [{
                    test: report.testName,
                    athlete: report.athleteId,
                    status: report.medicalStatus
                  }]
                };
              } else {
                reportsByDate[date].count += 1;
                reportsByDate[date].tests.push({
                  test: report.testName,
                  athlete: report.athleteId,
                  status: report.medicalStatus
                });
              }
            });
            
            // Convert to array and sort by date (newest first)
            const sortedDates = Object.values(reportsByDate).sort((a, b) => 
              new Date(b._id) - new Date(a._id)
            );
            
            setReportDates(sortedDates);
            
            // Store all reports for quick access when user selects a date
            setAllMedicalReports(reports);
          }
        } catch (err) {
          console.error("Error fetching data:", err);
          setError(err.response?.data?.message || "Error loading data");
        } finally {
          setLoading(false);
        }
      };
      
      fetchData();
    }, [athleteId]);
  
  // Fetch reports for a specific date
  const fetchReportsByDate = (date) => {
    setDateLoading(true);
    try {
      const reportsForDate = allMedicalReports.filter(report => {
        const reportDate = new Date(report.reportDate).toISOString().split('T')[0];
        return reportDate === date;
      });
      
      setDateMedicalReports(reportsForDate);
      setSelectedDate(date);
    } catch (err) {
      console.error("Error filtering reports by date:", err);
      setError("Error loading reports for this date");
    } finally {
      setDateLoading(false);
    }
  };
  
  // Fetch a single report by ID
  const fetchReportById = (reportId) => {
    try {
      const report = allMedicalReports.find(r => r._id === reportId);
      console.log(report)
      
      if (report) {
        setSelectedReport(report);
        setReportModalOpen(true);
      } else {
        setError("Report not found");
      }
    } catch (err) {
      console.error("Error fetching report details:", err);
      setError("Error loading report details");
    }
  };
  
  // Handle form input changes
  const handleInputChange = (e) => {
    const { name, value } = e.target;
    setNewReport({
      ...newReport,
      [name]: value
    });
  };
  
  // Handle nested object changes
  const handleNestedChange = (section, field, value) => {
    setNewReport({
      ...newReport,
      [section]: {
        ...newReport[section],
        [field]: value
      }
    });
  };
  
  // Handle array field changes
  const handleArrayChange = (section, index, field, value) => {
    const updatedArray = [...newReport[section]];
    updatedArray[index] = value;
    
    setNewReport({
      ...newReport,
      [section]: updatedArray
    });
  };
  
  // Handle nested array field changes
  const handleNestedArrayChange = (section, subsection, index, field, value) => {
    const updatedArray = [...newReport[section][subsection]];
    
    if (field) {
      updatedArray[index] = {
        ...updatedArray[index],
        [field]: value
      };
    } else {
      updatedArray[index] = value;
    }
    
    setNewReport({
      ...newReport,
      [section]: {
        ...newReport[section],
        [subsection]: updatedArray
      }
    });
  };
  
  // Add new item to array
  const addArrayItem = (section, defaultValue) => {
    setNewReport({
      ...newReport,
      [section]: [...newReport[section], defaultValue]
    });
  };
  
  // Add new item to nested array
  const addNestedArrayItem = (section, subsection, defaultValue) => {
    setNewReport({
      ...newReport,
      [section]: {
        ...newReport[section],
        [subsection]: [...newReport[section][subsection], defaultValue]
      }
    });
  };
  
  // Remove item from array
  const removeArrayItem = (section, index) => {
    const updated = [...newReport[section]];
    updated.splice(index, 1);
    
    setNewReport({
      ...newReport,
      [section]: updated
    });
  };
  
  // Remove item from nested array
  const removeNestedArrayItem = (section, subsection, index) => {
    const updated = [...newReport[section][subsection]];
    updated.splice(index, 1);
    
    setNewReport({
      ...newReport,
      [section]: {
        ...newReport[section],
        [subsection]: updated
      }
    });
  };
  
  // Handle file selection
  const handleFileChange = (e) => {
    if (e.target.files) {
      const fileArray = Array.from(e.target.files);
      setSelectedFiles([...selectedFiles, ...fileArray]);
    }
  };
  
  // Remove selected file
  const removeFile = (index) => {
    const updated = [...selectedFiles];
    updated.splice(index, 1);
    setSelectedFiles(updated);
  };
  
  // Submit the new medical report
  const handleSubmitReport = async () => {
    setSubmitLoading(true);
    setError(null);
    
    try {
      // Create a FormData object to handle file uploads
      const formData = new FormData();
      
      // Add the athlete ID
      formData.append("athleteId", athleteId);
      
      // Add all form fields
      Object.keys(newReport).forEach(key => {
        if (typeof newReport[key] === 'object' && newReport[key] !== null && !(newReport[key] instanceof File)) {
          // For nested objects (vitals, injuryDetails, etc.)
          Object.keys(newReport[key]).forEach(nestedKey => {
            if (Array.isArray(newReport[key][nestedKey])) {
              // For arrays inside nested objects
              newReport[key][nestedKey].forEach((item, index) => {
                if (typeof item === 'object' && item !== null) {
                  // For objects inside arrays
                  Object.keys(item).forEach(itemKey => {
                    if (item[itemKey]) {
                      formData.append(`${key}[${nestedKey}][${index}][${itemKey}]`, item[itemKey]);
                    }
                  });
                } else if (item) {
                  // For primitive values in arrays
                  formData.append(`${key}[${nestedKey}][${index}]`, item);
                }
              });
            } else if (newReport[key][nestedKey]) {
              // For primitive values in nested objects
              formData.append(`${key}[${nestedKey}]`, newReport[key][nestedKey]);
            }
          });
        } else if (newReport[key]) {
          // For top-level primitives
          formData.append(key, newReport[key]);
        }
      });
      
      // Add files
      selectedFiles.forEach(file => {
        formData.append("medicalFiles", file);
      });
      
      // Send the request
      const response = await axios.post(
        "http://localhost:8000/api/v1/medical-reports",
        formData,
        { 
          withCredentials: true,
          headers: {
            "Content-Type": "multipart/form-data"
          }
        }
      );
      
      if (response.data.success) {
        // Refresh the report dates
        const datesResponse = await axios.get(
          `http://localhost:8000/api/v1/medical-reports/dates?athleteId=${athleteId}`,
          { withCredentials: true }
        );
        
        if (datesResponse.data.success) {
          setReportDates(datesResponse.data.data || []);
        }
        
        // Reset the form
        setNewReport({
          testName: "",
          testDate: "",
          medicalStatus: "Active",
          medicalClearance: "Fit to Play",
          chronicMedicalCondition: "",
          vitals: {
            height: "",
            weight: "",
            bloodPressure: "",
            restingHeartRate: "",
            oxygenSaturation: "",
            respiratoryRate: "",
            bodyTemperature: "",
          },
          performanceMetrics: {
            vo2Max: "",
            sprintSpeed: "",
            agilityScore: "",
            strength: "",
            flexibilityTest: "",
            reactionTime: "",
            enduranceLevel: "",
          },
          injuryDetails: {
            currentInjuries: [{ type: "", location: "", severity: "", notes: "" }],
            pastInjuries: "",
            ongoingTreatment: "",
            returnToPlayStatus: "",
          },
          testResults: {
            bloodTest: "",
            urineTest: "",
            ecg: "",
            mriScan: "",
            xray: "",
            additionalResults: []
          },
          nutrition: {
            caloricIntake: "",
            waterIntake: "",
            nutrientDeficiencies: "",
            supplements: [""],
            dietaryRestrictions: [""],
            dietaryRecommendations: "",
          },
          mentalHealth: {
            stressLevel: "",
            sleepQuality: "",
            cognitiveScore: "",
            mentalHealthNotes: "",
          },
          doctorsNotes: "",
          physicianNotes: "",
          recommendations: [""],
          nextCheckupDate: ""
        });
        
        // Clear selected files
        setSelectedFiles([]);
        
        // Show success alert
        alert("Medical report created successfully!");
      }
    } catch (err) {
      console.error("Error submitting report:", err);
      setError(err.response?.data?.message || "Error creating medical report");
    } finally {
      setSubmitLoading(false);
    }
  };
  
  // Format date for display
  const formatDate = (dateString) => {
    if (!dateString) return "N/A";
    const date = new Date(dateString);
    return date.toLocaleDateString('en-US', {
      year: 'numeric',
      month: 'short',
      day: 'numeric'
    });
  };

  if (loading) {
    return (
      <div className="flex justify-center items-center h-screen">
        <Loader2 className="h-8 w-8 animate-spin text-blue-600" />
        <span className="ml-2 text-lg">Loading medical records...</span>
      </div>
    );
  }

  if (error) {
    return (
      <div className="p-6">
        <Alert variant="destructive" className="mb-4">
          <AlertDescription>{error}</AlertDescription>
        </Alert>
        <Button onClick={() => navigate(-1)} className="mt-4">
          Go Back
        </Button>
      </div>
    );
  }

  return (
    <div className="p-6 space-y-6">
      <div className="flex items-center justify-between">
        <div className="flex items-center">
          <Button 
            variant="ghost" 
            size="sm" 
            onClick={() => navigate(-1)}
            className="mr-2"
          >
            <ArrowLeft className="h-4 w-4 mr-1" />
            Back
          </Button>
          <h1 className="text-2xl font-bold">{athlete?.name}'s Medical Records</h1>
        </div>
        
        <Badge 
          className={athlete?.medicalStatus === "Injured" 
            ? "bg-red-100 text-red-800" 
            : "bg-green-100 text-green-800"
          }
        >
          {athlete?.medicalStatus || "Active"}
        </Badge>
      </div>
      
      <div className="grid grid-cols-1 md:grid-cols-3 gap-4 mb-6">
        <Card>
          <CardHeader className="pb-2">
            <CardTitle className="text-sm text-gray-500">Basic Info</CardTitle>
          </CardHeader>
          <CardContent>
            <div className="space-y-1">
              <p><span className="font-medium">Age:</span> {athlete?.age || "N/A"}</p>
              <p><span className="font-medium">Gender:</span> {athlete?.gender}</p>
              <p><span className="font-medium">Sports:</span> {athlete?.sports?.join(", ")}</p>
              <p><span className="font-medium">Height:</span> {athlete?.height} cm</p>
              <p><span className="font-medium">Weight:</span> {athlete?.weight} kg</p>
            </div>
          </CardContent>
        </Card>
        
        <Card>
          <CardHeader className="pb-2">
            <CardTitle className="text-sm text-gray-500">Medical Info</CardTitle>
          </CardHeader>
          <CardContent>
            <div className="space-y-1">
              <p><span className="font-medium">Blood Group:</span> {athlete?.bloodGroup || "N/A"}</p>
              <p><span className="font-medium">Allergies:</span> {athlete?.allergies?.join(", ") || "None"}</p>
              <p><span className="font-medium">Medical Conditions:</span> {athlete?.medicalConditions?.join(", ") || "None"}</p>
            </div>
          </CardContent>
        </Card>
        
        <Card>
          <CardHeader className="pb-2">
            <CardTitle className="text-sm text-gray-500">Emergency Contact</CardTitle>
          </CardHeader>
          <CardContent>
            <div className="space-y-1">
              <p><span className="font-medium">Name:</span> {athlete?.emergencyContactName}</p>
              <p><span className="font-medium">Number:</span> {athlete?.emergencyContactNumber}</p>
              <p><span className="font-medium">Relation:</span> {athlete?.emergencyContactRelationship}</p>
            </div>
          </CardContent>
        </Card>
      </div>

      <Tabs defaultValue="past-records" className="w-full">
        <TabsList className="grid grid-cols-2 w-full max-w-md mx-auto">
          <TabsTrigger value="add-record" className="flex items-center">
            <FilePlus className="h-4 w-4 mr-2" />
            Add New Record
          </TabsTrigger>
          <TabsTrigger value="past-records" className="flex items-center">
            <ListFilter className="h-4 w-4 mr-2" />
            Past Records ({reportDates.length})
          </TabsTrigger>
        </TabsList>
        
        <TabsContent value="add-record" className="mt-6">
          <Card>
            <CardHeader>
              <CardTitle className="text-xl">New Medical Report</CardTitle>
            </CardHeader>
            <CardContent>
              {error && (
                <Alert variant="destructive" className="mb-4">
                  <AlertDescription>{error}</AlertDescription>
                </Alert>
              )}
              
              <Accordion type="multiple" className="w-full">
                {/* Basic Report Information */}
                <AccordionItem value="basic-info" defaultOpen={true}>
                  <AccordionTrigger className="text-lg font-medium">
                    <UserRound className="h-5 w-5 mr-2" />
                    Basic Report Information
                  </AccordionTrigger>
                  <AccordionContent className="p-2">
                    <div className="grid grid-cols-1 md:grid-cols-2 gap-4">
                      <div>
                        <Label htmlFor="testName">Test/Examination Name</Label>
                        <Input
                          id="testName"
                          name="testName"
                          value={newReport.testName}
                          onChange={handleInputChange}
                          placeholder="e.g. Annual Physical, Knee Examination"
                        />
                      </div>
                      
                      <div>
                        <Label htmlFor="testDate">Test Date</Label>
                        <Input
                          id="testDate"
                          name="testDate"
                          type="date"
                          value={newReport.testDate}
                          onChange={handleInputChange}
                        />
                      </div>
                      
                      <div>
                        <Label htmlFor="medicalStatus">Medical Status</Label>
                        <Select 
                          name="medicalStatus"
                          value={newReport.medicalStatus} 
                          onValueChange={(value) => setNewReport({...newReport, medicalStatus: value})}
                        >
                          <SelectTrigger>
                            <SelectValue placeholder="Select status" />
                          </SelectTrigger>
                          <SelectContent>
                            <SelectItem value="Active">Active</SelectItem>
                            <SelectItem value="Injured">Injured</SelectItem>
                            <SelectItem value="Recovering">Recovering</SelectItem>
                            <SelectItem value="Limited Participation">Limited Participation</SelectItem>
                            <SelectItem value="Not Cleared">Not Cleared</SelectItem>
                          </SelectContent>
                        </Select>
                      </div>
                      
                      <div>
                        <Label htmlFor="medicalClearance">Medical Clearance</Label>
                        <Select 
                          name="medicalClearance"
                          value={newReport.medicalClearance} 
                          onValueChange={(value) => setNewReport({...newReport, medicalClearance: value})}
                        >
                          <SelectTrigger>
                            <SelectValue placeholder="Select clearance" />
                          </SelectTrigger>
                          <SelectContent>
                            <SelectItem value="Fit to Play">Fit to Play</SelectItem>
                            <SelectItem value="Limited Activity">Limited Activity</SelectItem>
                            <SelectItem value="Not Cleared">Not Cleared</SelectItem>
                            <SelectItem value="Pending Evaluation">Pending Evaluation</SelectItem>
                          </SelectContent>
                        </Select>
                      </div>
                      
                      <div>
                        <Label htmlFor="chronicMedicalCondition">Chronic Medical Condition</Label>
                        <Input
                          id="chronicMedicalCondition"
                          name="chronicMedicalCondition"
                          value={newReport.chronicMedicalCondition}
                          onChange={handleInputChange}
                          placeholder="e.g. Asthma, Diabetes"
                        />
                      </div>
                      
                      <div>
                        <Label htmlFor="nextCheckupDate">Next Checkup Date</Label>
                        <Input
                          id="nextCheckupDate"
                          name="nextCheckupDate"
                          type="date"
                          value={newReport.nextCheckupDate}
                          onChange={handleInputChange}
                        />
                      </div>
                    </div>
                  </AccordionContent>
                </AccordionItem>
                
                {/* Vitals */}
                <AccordionItem value="vitals">
                  <AccordionTrigger className="text-lg font-medium">
                    <HeartPulse className="h-5 w-5 mr-2" />
                    Vitals
                  </AccordionTrigger>
                  <AccordionContent className="p-2">
                    <div className="grid grid-cols-1 sm:grid-cols-2 md:grid-cols-3 gap-4">
                      <div>
                        <Label htmlFor="height">Height (cm)</Label>
                        <Input
                          id="height"
                          type="number"
                          value={newReport.vitals.height}
                          onChange={(e) => handleNestedChange('vitals', 'height', e.target.value)}
                        />
                      </div>
                      
                      <div>
                        <Label htmlFor="weight">Weight (kg)</Label>
                        <Input
                          id="weight"
                          type="number"
                          value={newReport.vitals.weight}
                          onChange={(e) => handleNestedChange('vitals', 'weight', e.target.value)}
                        />
                      </div>
                      
                      <div>
                        <Label htmlFor="bloodPressure">Blood Pressure</Label>
                        <Input
                          id="bloodPressure"
                          placeholder="e.g. 120/80"
                          value={newReport.vitals.bloodPressure}
                          onChange={(e) => handleNestedChange('vitals', 'bloodPressure', e.target.value)}
                        />
                      </div>
                      
                      <div>
                        <Label htmlFor="restingHeartRate">Resting Heart Rate (bpm)</Label>
                        <Input
                          id="restingHeartRate"
                          type="number"
                          value={newReport.vitals.restingHeartRate}
                          onChange={(e) => handleNestedChange('vitals', 'restingHeartRate', e.target.value)}
                        />
                      </div>
                      
                      <div>
                        <Label htmlFor="oxygenSaturation">Oxygen Saturation (%)</Label>
                        <Input
                          id="oxygenSaturation"
                          type="number"
                          value={newReport.vitals.oxygenSaturation}
                          onChange={(e) => handleNestedChange('vitals', 'oxygenSaturation', e.target.value)}
                        />
                      </div>
                      
                      <div>
                        <Label htmlFor="respiratoryRate">Respiratory Rate (breaths/min)</Label>
                        <Input
                          id="respiratoryRate"
                          type="number"
                          value={newReport.vitals.respiratoryRate}
                          onChange={(e) => handleNestedChange('vitals', 'respiratoryRate', e.target.value)}
                        />
                      </div>
                      
                      <div>
                        <Label htmlFor="bodyTemperature">Body Temperature (°C)</Label>
                        <Input
                          id="bodyTemperature"
                          type="number"
                          step="0.1"
                          value={newReport.vitals.bodyTemperature}
                          onChange={(e) => handleNestedChange('vitals', 'bodyTemperature', e.target.value)}
                        />
                      </div>
                    </div>
                  </AccordionContent>
                </AccordionItem>
                
                {/* Performance Metrics */}
                <AccordionItem value="performance">
                  <AccordionTrigger className="text-lg font-medium">
                    <BarChart className="h-5 w-5 mr-2" />
                    Performance Metrics
                  </AccordionTrigger>
                  <AccordionContent className="p-2">
                    <div className="grid grid-cols-1 sm:grid-cols-2 md:grid-cols-3 gap-4">
                      <div>
                        <Label htmlFor="vo2Max">VO2 Max</Label>
                        <Input
                          id="vo2Max"
                          type="number"
                          step="0.1"
                          value={newReport.performanceMetrics.vo2Max}
                          onChange={(e) => handleNestedChange('performanceMetrics', 'vo2Max', e.target.value)}
                        />
                      </div>
                      
                      <div>
                        <Label htmlFor="sprintSpeed">Sprint Speed (m/s)</Label>
                        <Input
                          id="sprintSpeed"
                          type="number"
                          step="0.1"
                          value={newReport.performanceMetrics.sprintSpeed}
                          onChange={(e) => handleNestedChange('performanceMetrics', 'sprintSpeed', e.target.value)}
                        />
                      </div>
                      
                      <div>
                        <Label htmlFor="agilityScore">Agility Score</Label>
                        <Input
                          id="agilityScore"
                          type="number"
                          value={newReport.performanceMetrics.agilityScore}
                          onChange={(e) => handleNestedChange('performanceMetrics', 'agilityScore', e.target.value)}
                        />
                      </div>
                      
                      <div>
                        <Label htmlFor="strength">Strength Score</Label>
                        <Input
                          id="strength"
                          type="number"
                          value={newReport.performanceMetrics.strength}
                          onChange={(e) => handleNestedChange('performanceMetrics', 'strength', e.target.value)}
                        />
                      </div>
                      
                      <div>
                        <Label htmlFor="flexibilityTest">Flexibility Test</Label>
                        <Input
                          id="flexibilityTest"
                          type="number"
                          value={newReport.performanceMetrics.flexibilityTest}
                          onChange={(e) => handleNestedChange('performanceMetrics', 'flexibilityTest', e.target.value)}
                        />
                      </div>
                      
                      <div>
                        <Label htmlFor="reactionTime">Reaction Time (ms)</Label>
                        <Input
                          id="reactionTime"
                          type="number"
                          value={newReport.performanceMetrics.reactionTime}
                          onChange={(e) => handleNestedChange('performanceMetrics', 'reactionTime', e.target.value)}
                        />
                      </div>
                      
                      <div>
                        <Label htmlFor="enduranceLevel">Endurance Level</Label>
                        <Input
                          id="enduranceLevel"
                          type="number"
                          value={newReport.performanceMetrics.enduranceLevel}
                          onChange={(e) => handleNestedChange('performanceMetrics', 'enduranceLevel', e.target.value)}
                        />
                      </div>
                    </div>
                  </AccordionContent>
                </AccordionItem>
                
                {/* Injury Details */}
                <AccordionItem value="injury">
                  <AccordionTrigger className="text-lg font-medium">
                    <Activity className="h-5 w-5 mr-2" />
                    Injury & Treatment Details
                  </AccordionTrigger>
                  <AccordionContent className="p-2">
                    <div className="space-y-4">
                      <div>
                        <div className="flex items-center justify-between mb-2">
                          <Label>Current Injuries</Label>
                          <Button 
                            type="button" 
                            variant="outline" 
                            size="sm"
                            onClick={() => addNestedArrayItem('injuryDetails', 'currentInjuries', { type: "", location: "", severity: "", notes: "" })}
                          >
                            <Plus className="h-4 w-4 mr-1" /> Add Injury
                          </Button>
                        </div>
                        
                        {newReport.injuryDetails.currentInjuries.map((injury, index) => (
                          <div key={index} className="grid grid-cols-1 md:grid-cols-4 gap-3 p-3 border rounded-md mb-3">
                            <div>
                              <Label>Type</Label>
                              <Input
                                value={injury.type}
                                onChange={(e) => handleNestedArrayChange('injuryDetails', 'currentInjuries', index, 'type', e.target.value)}
                                placeholder="e.g. Sprain, Fracture"
                              />
                            </div>
                            
                            <div>
                              <Label>Location</Label>
                              <Input
                                value={injury.location}
                                onChange={(e) => handleNestedArrayChange('injuryDetails', 'currentInjuries', index, 'location', e.target.value)}
                                placeholder="e.g. Ankle, Shoulder"
                              />
                            </div>
                            
                            <div>
                              <Label>Severity</Label>
                              <Select
                                value={injury.severity}
                                onValueChange={(value) => handleNestedArrayChange('injuryDetails', 'currentInjuries', index, 'severity', value)}
                              >
                                <SelectTrigger>
                                  <SelectValue placeholder="Select severity" />
                                </SelectTrigger>
                                <SelectContent>
                                  <SelectItem value="Mild">Mild</SelectItem>
                                  <SelectItem value="Moderate">Moderate</SelectItem>
                                  <SelectItem value="Severe">Severe</SelectItem>
                                </SelectContent>
                              </Select>
                            </div>
                            
                            <div className="relative">
                              <Label>Notes</Label>
                              <Input
                                value={injury.notes}
                                onChange={(e) => handleNestedArrayChange('injuryDetails', 'currentInjuries', index, 'notes', e.target.value)}
                                placeholder="Any specific notes"
                              />
                              
                              {newReport.injuryDetails.currentInjuries.length > 1 && (
                                <Button
                                  type="button"
                                  variant="ghost"
                                  size="icon"
                                  className="absolute top-7 right-0"
                                  onClick={() => removeNestedArrayItem('injuryDetails', 'currentInjuries', index)}
                                >
                                  <X className="h-4 w-4 text-red-500" />
                                </Button>
                              )}
                            </div>
                          </div>
                        ))}
                      </div>
                      
                      <div>
                        <Label htmlFor="pastInjuries">Past Injuries</Label>
                        <Textarea
                          id="pastInjuries"
                          value={newReport.injuryDetails.pastInjuries}
                          onChange={(e) => handleNestedChange('injuryDetails', 'pastInjuries', e.target.value)}
                          placeholder="Describe any past injuries and their recovery status"
                        />
                      </div>
                      
                      <div>
                        <Label htmlFor="ongoingTreatment">Ongoing Treatment</Label>
                        <Textarea
                          id="ongoingTreatment"
                          value={newReport.injuryDetails.ongoingTreatment}
                          onChange={(e) => handleNestedChange('injuryDetails', 'ongoingTreatment', e.target.value)}
                          placeholder="Describe any ongoing treatments"
                        />
                      </div>
                      
                      <div>
                        <Label htmlFor="returnToPlayStatus">Return to Play Status</Label>
                        <Select
                          value={newReport.injuryDetails.returnToPlayStatus}
                          onValueChange={(value) => handleNestedChange('injuryDetails', 'returnToPlayStatus', value)}
                        >
                          <SelectTrigger>
                            <SelectValue placeholder="Select status" />
                          </SelectTrigger>
                          <SelectContent>
                            <SelectItem value="Cleared">Cleared</SelectItem>
                            <SelectItem value="Cleared with Limitations">Cleared with Limitations</SelectItem>
                            <SelectItem value="Not Cleared">Not Cleared</SelectItem>
                            <SelectItem value="Pending Evaluation">Pending Evaluation</SelectItem>
                          </SelectContent>
                        </Select>
                      </div>
                    </div>
                  </AccordionContent>
                </AccordionItem>
                
                {/* Test Results */}
                <AccordionItem value="tests">
                  <AccordionTrigger className="text-lg font-medium">
                    <Clipboard className="h-5 w-5 mr-2" />
                    Test Results
                  </AccordionTrigger>
                  <AccordionContent className="p-2">
                    <div className="grid grid-cols-1 md:grid-cols-2 gap-4">
                      <div>
                        <Label htmlFor="bloodTest">Blood Test</Label>
                        <Input
                          id="bloodTest"
                          value={newReport.testResults.bloodTest}
                          onChange={(e) => handleNestedChange('testResults', 'bloodTest', e.target.value)}
                          placeholder="Blood test results"
                        />
                      </div>
                      
                      <div>
                        <Label htmlFor="urineTest">Urine Test</Label>
                        <Input
                          id="urineTest"
                          value={newReport.testResults.urineTest}
                          onChange={(e) => handleNestedChange('testResults', 'urineTest', e.target.value)}
                          placeholder="Urine test results"
                        />
                      </div>
                      
                      <div>
                        <Label htmlFor="ecg">ECG</Label>
                        <Input
                          id="ecg"
                          value={newReport.testResults.ecg}
                          onChange={(e) => handleNestedChange('testResults', 'ecg', e.target.value)}
                          placeholder="ECG results"
                        />
                      </div>
                      
                      <div>
                        <Label htmlFor="mriScan">MRI Scan</Label>
                        <Input
                          id="mriScan"
                          value={newReport.testResults.mriScan}
                          onChange={(e) => handleNestedChange('testResults', 'mriScan', e.target.value)}
                          placeholder="MRI scan results"
                        />
                      </div>
                      
                      <div>
                        <Label htmlFor="xray">X-Ray</Label>
                        <Input
                          id="xray"
                          value={newReport.testResults.xray}
                          onChange={(e) => handleNestedChange('testResults', 'xray', e.target.value)}
                          placeholder="X-ray results"
                        />
                      </div>
                    </div>
                    
                    {/* Additional Test Results */}
                    <div className="mt-4">
                      <div className="flex items-center justify-between mb-2">
                        <Label>Additional Test Results</Label>
                        <Button 
                          type="button" 
                          variant="outline" 
                          size="sm"
                          onClick={() => addNestedArrayItem('testResults', 'additionalResults', "")}
                        >
                          <Plus className="h-4 w-4 mr-1" /> Add Test
                        </Button>
                      </div>
                      
                      {newReport.testResults.additionalResults.map((result, index) => (
                        <div key={index} className="flex items-center gap-2 mb-2">
                          <Input
                            value={result}
                            onChange={(e) => handleNestedArrayChange('testResults', 'additionalResults', index, null, e.target.value)}
                            placeholder={`Additional test ${index + 1}`}
                            className="flex-1"
                          />
                          
                          <Button
                            type="button"
                            variant="ghost"
                            size="icon"
                            onClick={() => removeNestedArrayItem('testResults', 'additionalResults', index)}
                          >
                            <X className="h-4 w-4 text-red-500" />
                          </Button>
                        </div>
                      ))}
                    </div>
                  </AccordionContent>
                </AccordionItem>
                
                {/* Nutrition */}
                <AccordionItem value="nutrition">
                  <AccordionTrigger className="text-lg font-medium">
                    <Apple className="h-5 w-5 mr-2" />
                    Nutrition
                  </AccordionTrigger>
                  <AccordionContent className="p-2">
                    <div className="grid grid-cols-1 md:grid-cols-2 gap-4">
                      <div>
                        <Label htmlFor="caloricIntake">Caloric Intake (kcal)</Label>
                        <Input
                          id="caloricIntake"
                          type="number"
                          value={newReport.nutrition.caloricIntake}
                          onChange={(e) => handleNestedChange('nutrition', 'caloricIntake', e.target.value)}
                        />
                      </div>
                      
                      <div>
                        <Label htmlFor="waterIntake">Water Intake (liters)</Label>
                        <Input
                          id="waterIntake"
                          type="number"
                          step="0.1"
                          value={newReport.nutrition.waterIntake}
                          onChange={(e) => handleNestedChange('nutrition', 'waterIntake', e.target.value)}
                        />
                      </div>
                      
                      <div className="md:col-span-2">
                        <Label htmlFor="nutrientDeficiencies">Nutrient Deficiencies</Label>
                        <Input
                          id="nutrientDeficiencies"
                          value={newReport.nutrition.nutrientDeficiencies}
                          onChange={(e) => handleNestedChange('nutrition', 'nutrientDeficiencies', e.target.value)}
                          placeholder="e.g. Iron, Vitamin D"
                        />
                      </div>
                      
                      {/* Supplements */}
                      <div className="md:col-span-2">
                        <div className="flex items-center justify-between mb-2">
                          <Label>Supplements</Label>
                          <Button 
                            type="button" 
                            variant="outline" 
                            size="sm"
                            onClick={() => addNestedArrayItem('nutrition', 'supplements', "")}
                          >
                            <Plus className="h-4 w-4 mr-1" /> Add Supplement
                          </Button>
                        </div>
                        
                        {newReport.nutrition.supplements.map((supplement, index) => (
                          <div key={index} className="flex items-center gap-2 mb-2">
                            <Input
                              value={supplement}
                              onChange={(e) => handleNestedArrayChange('nutrition', 'supplements', index, null, e.target.value)}
                              placeholder={`Supplement ${index + 1}`}
                              className="flex-1"
                            />
                            
                            {newReport.nutrition.supplements.length > 1 && (
                              <Button
                                type="button"
                                variant="ghost"
                                size="icon"
                                onClick={() => removeNestedArrayItem('nutrition', 'supplements', index)}
                              >
                                <X className="h-4 w-4 text-red-500" />
                              </Button>
                            )}
                          </div>
                        ))}
                      </div>
                      
                      {/* Dietary Restrictions */}
                      <div className="md:col-span-2">
                        <div className="flex items-center justify-between mb-2">
                          <Label>Dietary Restrictions</Label>
                          <Button 
                            type="button" 
                            variant="outline" 
                            size="sm"
                            onClick={() => addNestedArrayItem('nutrition', 'dietaryRestrictions', "")}
                          >
                            <Plus className="h-4 w-4 mr-1" /> Add Restriction
                          </Button>
                        </div>
                        
                        {newReport.nutrition.dietaryRestrictions.map((restriction, index) => (
                          <div key={index} className="flex items-center gap-2 mb-2">
                            <Input
                              value={restriction}
                              onChange={(e) => handleNestedArrayChange('nutrition', 'dietaryRestrictions', index, null, e.target.value)}
                              placeholder={`Restriction ${index + 1}`}
                              className="flex-1"
                            />
                            
                            {newReport.nutrition.dietaryRestrictions.length > 1 && (
                              <Button
                                type="button"
                                variant="ghost"
                                size="icon"
                                onClick={() => removeNestedArrayItem('nutrition', 'dietaryRestrictions', index)}
                              >
                                <X className="h-4 w-4 text-red-500" />
                              </Button>
                            )}
                          </div>
                        ))}
                      </div>
                      
                      <div className="md:col-span-2">
                        <Label htmlFor="dietaryRecommendations">Dietary Recommendations</Label>
                        <Textarea
                          id="dietaryRecommendations"
                          value={newReport.nutrition.dietaryRecommendations}
                          onChange={(e) => handleNestedChange('nutrition', 'dietaryRecommendations', e.target.value)}
                          placeholder="Recommendations for diet and nutrition"
                        />
                      </div>
                    </div>
                  </AccordionContent>
                </AccordionItem>
                
                {/* Mental Health */}
                <AccordionItem value="mental-health">
                  <AccordionTrigger className="text-lg font-medium">
                    <Brain className="h-5 w-5 mr-2" />
                    Mental Health
                  </AccordionTrigger>
                  <AccordionContent className="p-2">
                    <div className="grid grid-cols-1 md:grid-cols-2 gap-4">
                      <div>
                        <Label htmlFor="stressLevel">Stress Level (0-10)</Label>
                        <Input
                          id="stressLevel"
                          type="number"
                          min="0"
                          max="10"
                          value={newReport.mentalHealth.stressLevel}
                          onChange={(e) => handleNestedChange('mentalHealth', 'stressLevel', e.target.value)}
                        />
                      </div>
                      
                      <div>
                        <Label htmlFor="sleepQuality">Sleep Quality (0-10)</Label>
                        <Input
                          id="sleepQuality"
                          type="number"
                          min="0"
                          max="10"
                          value={newReport.mentalHealth.sleepQuality}
                          onChange={(e) => handleNestedChange('mentalHealth', 'sleepQuality', e.target.value)}
                        />
                      </div>
                      
                      <div>
                        <Label htmlFor="cognitiveScore">Cognitive Score (0-100)</Label>
                        <Input
                          id="cognitiveScore"
                          type="number"
                          min="0"
                          max="100"
                          value={newReport.mentalHealth.cognitiveScore}
                          onChange={(e) => handleNestedChange('mentalHealth', 'cognitiveScore', e.target.value)}
                        />
                      </div>
                      
                      <div className="md:col-span-2">
                        <Label htmlFor="mentalHealthNotes">Mental Health Notes</Label>
                        <Textarea
                          id="mentalHealthNotes"
                          value={newReport.mentalHealth.mentalHealthNotes}
                          onChange={(e) => handleNestedChange('mentalHealth', 'mentalHealthNotes', e.target.value)}
                          placeholder="Notes on athlete's mental health"
                        />
                      </div>
                    </div>
                  </AccordionContent>
                </AccordionItem>
                
                {/* Notes & Recommendations */}
                <AccordionItem value="notes" defaultOpen={true}>
                  <AccordionTrigger className="text-lg font-medium">
                    <FileText className="h-5 w-5 mr-2" />
                    Notes & Recommendations
                  </AccordionTrigger>
                  <AccordionContent className="p-2">
                    <div className="space-y-4">
                      <div>
                        <Label htmlFor="doctorsNotes">Doctor's Notes</Label>
                        <Textarea
                          id="doctorsNotes"
                          name="doctorsNotes"
                          value={newReport.doctorsNotes}
                          onChange={handleInputChange}
                          placeholder="Medical observations and notes..."
                          className="min-h-[100px]"
                        />
                      </div>
                      
                      <div>
                        <Label htmlFor="physicianNotes">Physician Notes</Label>
                        <Textarea
                          id="physicianNotes"
                          name="physicianNotes"
                          value={newReport.physicianNotes}
                          onChange={handleInputChange}
                          placeholder="Additional physician notes..."
                          className="min-h-[100px]"
                        />
                      </div>
                      
                      {/* Recommendations */}
                      <div>
                        <div className="flex items-center justify-between mb-2">
                          <Label>Recommendations</Label>
                          <Button 
                            type="button" 
                            variant="outline" 
                            size="sm"
                            onClick={() => addArrayItem('recommendations', "")}
                          >
                            <Plus className="h-4 w-4 mr-1" /> Add Recommendation
                          </Button>
                        </div>
                        
                        {newReport.recommendations.map((recommendation, index) => (
                          <div key={index} className="flex items-center gap-2 mb-2">
                            <Input
                              value={recommendation}
                              onChange={(e) => handleArrayChange('recommendations', index, e.target.value)}
                              placeholder={`Recommendation ${index + 1}`}
                              className="flex-1"
                            />
                            
                            {newReport.recommendations.length > 1 && (
                              <Button
                                type="button"
                                variant="ghost"
                                size="icon"
                                onClick={() => removeArrayItem('recommendations', index)}
                              >
                                <X className="h-4 w-4 text-red-500" />
                              </Button>
                            )}
                          </div>
                        ))}
                      </div>
                    </div>
                  </AccordionContent>
                </AccordionItem>
                
                {/* Files & Attachments */}
                <AccordionItem value="files" defaultOpen={true}>
                  <AccordionTrigger className="text-lg font-medium">
                    <Upload className="h-5 w-5 mr-2" />
                    Files & Attachments
                  </AccordionTrigger>
                  <AccordionContent className="p-2">
                    <div className="space-y-4">
                      <div>
                        <Label htmlFor="medicalFiles">Upload Medical Files</Label>
                        <Input
                          id="medicalFiles"
                          type="file"
                          multiple
                          onChange={handleFileChange}
                          className="mt-1"
                        />
                        <p className="text-xs text-gray-500 mt-1">
                          Upload test results, scans, or other medical documents. Max 5 files.
                        </p>
                      </div>
                      
                      {selectedFiles.length > 0 && (
                        <div className="mt-4">
                          <h4 className="text-sm font-medium mb-2">Selected Files:</h4>
                          <div className="space-y-2">
                            {selectedFiles.map((file, index) => (
                              <div key={index} className="flex items-center justify-between p-2 bg-gray-50 rounded-md">
                                <span className="text-sm truncate max-w-[300px]">{file.name}</span>
                                <Button
                                  type="button"
                                  variant="ghost"
                                  size="sm"
                                  onClick={() => removeFile(index)}
                                >
                                  <X className="h-4 w-4 text-red-500" />
                                </Button>
                              </div>
                            ))}
                          </div>
                        </div>
                      )}
                    </div>
                  </AccordionContent>
                </AccordionItem>
              </Accordion>
              
              <div className="mt-6 flex justify-end">
                <Button 
                  onClick={handleSubmitReport} 
                  disabled={submitLoading}
                  className="w-full md:w-auto"
                >
                  {submitLoading ? (
                    <>
                      <Loader2 className="h-4 w-4 mr-2 animate-spin" />
                      Saving Report...
                    </>
                  ) : 'Save Medical Report'}
                </Button>
              </div>
            </CardContent>
          </Card>
        </TabsContent>
        
        <TabsContent value="past-records" className="mt-6">
          <div className="grid grid-cols-1 md:grid-cols-3 gap-4">
            <div className="md:col-span-1 space-y-4">
              <Card>
                <CardHeader>
                  <CardTitle className="text-lg flex items-center">
                    <Calendar className="h-5 w-5 mr-2" />
                    Medical Report Dates
                  </CardTitle>
                </CardHeader>
                <CardContent>
                  {reportDates.length === 0 ? (
                    <p className="text-gray-500 text-sm">No medical reports found.</p>
                  ) : (
                    <div className="space-y-2">
                      {reportDates.map((dateItem) => (
                        <div 
                          key={dateItem._id} 
                          className={`p-3 rounded-md cursor-pointer hover:bg-gray-50 transition-colors ${selectedDate === dateItem._id ? 'bg-blue-50 border border-blue-200' : 'border'}`}
                          onClick={() => fetchReportsByDate(dateItem._id)}
                        >
                          <div className="flex items-center justify-between">
                            <span className="font-medium">{formatDate(dateItem._id)}</span>
                            <Badge variant="outline">{dateItem.count} reports</Badge>
                          </div>
                          <div className="mt-1">
                            {dateItem.tests.slice(0, 2).map((test, idx) => (
                              <div key={idx} className="text-xs text-gray-600 flex items-center">
                                <span className="w-2 h-2 bg-blue-500 rounded-full mr-1"></span>
                                {test.test || "General Examination"}
                              </div>
                            ))}
                            {dateItem.tests.length > 2 && (
                              <div className="text-xs text-gray-600">
                                + {dateItem.tests.length - 2} more
                              </div>
                            )}
                          </div>
                        </div>
                      ))}
                    </div>
                  )}
                </CardContent>
              </Card>
            </div>
            
            <div className="md:col-span-2">
              <Card>
                <CardHeader>
                  <CardTitle className="text-lg">
                    {selectedDate ? `Reports for ${formatDate(selectedDate)}` : 'Select a date to view reports'}
                  </CardTitle>
                </CardHeader>
                <CardContent>
                  {dateLoading ? (
                    <div className="flex justify-center items-center h-64">
                      <Loader2 className="h-6 w-6 animate-spin text-blue-600" />
                      <span className="ml-2">Loading reports...</span>
                    </div>
                  ) : !selectedDate ? (
                    <div className="text-center py-12 text-gray-500">
                      <Calendar className="h-12 w-12 mx-auto text-gray-300 mb-4" />
                      <p>Select a date from the list to view its reports</p>
                    </div>
                  ) : dateMedicalReports.length === 0 ? (
                    <div className="text-center py-12 text-gray-500">
                      <p>No reports found for this date.</p>
                    </div>
                  ) : (
                    <div className="space-y-4">
                      {dateMedicalReports.map((report) => (
                        <div key={report._id} className="border rounded-md p-4 hover:bg-gray-50">
                          <div className="flex items-center justify-between">
                            <div>
                              <h3 className="font-medium">{report.testName || "Medical Examination"}</h3>
                              <div className="text-sm text-gray-500">
                                <span className="flex items-center">
                                  <Stethoscope className="h-3 w-3 mr-1" />
                                  Dr. {report.medicalStaffId?.name || "Medical Staff"}
                                </span>
                              </div>
                            </div>
                            <Badge className={
                              report.medicalStatus === "Active" ? "bg-green-100 text-green-800" :
                              report.medicalStatus === "Injured" ? "bg-red-100 text-red-800" :
                              "bg-yellow-100 text-yellow-800"
                            }>
                              {report.medicalStatus}
                            </Badge>
                          </div>
                          
                          <div className="mt-2 grid grid-cols-2 gap-2 text-sm">
                            <div>
                              <span className="text-gray-500">Medical Clearance:</span>{' '}
                              {report.medicalClearance}
                            </div>
                            {report.nextCheckupDate && (
                              <div>
                                <span className="text-gray-500">Next Checkup:</span>{' '}
                                {formatDate(report.nextCheckupDate)}
                              </div>
                            )}
                          </div>
                          
                          <div className="mt-3 flex justify-end">
                            <Button 
                              variant="outline" 
                              size="sm"
                              onClick={() => fetchReportById(report._id)}
                            >
                              <FileText className="h-4 w-4 mr-2" />
                              View Full Report
                            </Button>
                          </div>
                        </div>
                      ))}
                    </div>
                  )}
                </CardContent>
              </Card>
            </div>
          </div>
        </TabsContent>
      </Tabs>
      
      {/* Detailed Report Modal */}
      <Dialog open={reportModalOpen} onOpenChange={setReportModalOpen}>
        <DialogContent className="max-w-4xl p-0 max-h-[90vh] overflow-y-auto">
          <DialogHeader className="p-6 pb-2">
            <DialogTitle className="text-xl font-bold flex items-center justify-between">
              <span>Medical Report Details</span>
              <Badge className={
                selectedReport?.medicalStatus === "Active" ? "bg-green-100 text-green-800" :
                selectedReport?.medicalStatus === "Injured" ? "bg-red-100 text-red-800" :
                "bg-yellow-100 text-yellow-800"
              }>
                {selectedReport?.medicalStatus}
              </Badge>
            </DialogTitle>
          </DialogHeader>
          
          {selectedReport ? (
            <div className="p-6 pt-2">
              <div className="grid grid-cols-1 md:grid-cols-2 gap-x-6 gap-y-4 mb-4">
                <div>
                  <p className="text-sm text-gray-500">Test/Examination</p>
                  <p className="font-medium">{selectedReport.testName || "General Medical Examination"}</p>
                </div>
                
                <div>
                  <p className="text-sm text-gray-500">Date</p>
                  <p className="font-medium">{formatDate(selectedReport.reportDate)}</p>
                </div>
                
                <div>
                  <p className="text-sm text-gray-500">Medical Clearance</p>
                  <p className="font-medium">{selectedReport.medicalClearance}</p>
                </div>
                
                <div>
                  <p className="text-sm text-gray-500">Next Checkup</p>
                  <p className="font-medium">{formatDate(selectedReport.nextCheckupDate)}</p>
                </div>
                
                <div>
                  <p className="text-sm text-gray-500">Medical Staff</p>
                  <p className="font-medium">{selectedReport.medicalStaffId?.name}</p>
                </div>
                
                {selectedReport.chronicMedicalCondition && (
                  <div>
                    <p className="text-sm text-gray-500">Chronic Condition</p>
                    <p className="font-medium">{selectedReport.chronicMedicalCondition}</p>
                  </div>
                )}
              </div>
              
              <Accordion type="multiple" className="w-full mt-4">
                {/* Vitals Section */}
                {selectedReport.vitals && Object.values(selectedReport.vitals).some(val => val) && (
                  <AccordionItem value="vitals">
                    <AccordionTrigger className="text-base font-medium">
                      <HeartPulse className="h-4 w-4 mr-2" />
                      Vitals
                    </AccordionTrigger>
                    <AccordionContent className="p-2">
                      <div className="grid grid-cols-2 md:grid-cols-3 gap-4">
                        {selectedReport.vitals.height && (
                          <div>
                            <p className="text-sm text-gray-500">Height</p>
                            <p className="font-medium">{selectedReport.vitals.height} cm</p>
                          </div>
                        )}
                        
                        {selectedReport.vitals.weight && (
                          <div>
                            <p className="text-sm text-gray-500">Weight</p>
                            <p className="font-medium">{selectedReport.vitals.weight} kg</p>
                          </div>
                        )}
                        
                        {selectedReport.vitals.bmi && (
                          <div>
                            <p className="text-sm text-gray-500">BMI</p>
                            <p className="font-medium">{selectedReport.vitals.bmi}</p>
                          </div>
                        )}
                        
                        {selectedReport.vitals.bloodPressure && (
                          <div>
                            <p className="text-sm text-gray-500">Blood Pressure</p>
                            <p className="font-medium">{selectedReport.vitals.bloodPressure}</p>
                          </div>
                        )}
                        
                        {selectedReport.vitals.restingHeartRate && (
                          <div>
                            <p className="text-sm text-gray-500">Resting Heart Rate</p>
                            <p className="font-medium">{selectedReport.vitals.restingHeartRate} bpm</p>
                          </div>
                        )}
                        
                        {selectedReport.vitals.oxygenSaturation && (
                          <div>
                            <p className="text-sm text-gray-500">Oxygen Saturation</p>
                            <p className="font-medium">{selectedReport.vitals.oxygenSaturation}%</p>
                          </div>
                        )}
                        
                        {selectedReport.vitals.respiratoryRate && (
                          <div>
                            <p className="text-sm text-gray-500">Respiratory Rate</p>
                            <p className="font-medium">{selectedReport.vitals.respiratoryRate} breaths/min</p>
                          </div>
                        )}
                        
                        {selectedReport.vitals.bodyTemperature && (
                          <div>
                            <p className="text-sm text-gray-500">Body Temperature</p>
                            <p className="font-medium">{selectedReport.vitals.bodyTemperature}°C</p>
                          </div>
                        )}
                      </div>
                    </AccordionContent>
                  </AccordionItem>
                )}
                
                {/* Performance Metrics Section */}
                {selectedReport.performanceMetrics && Object.values(selectedReport.performanceMetrics).some(val => val) && (
                  <AccordionItem value="performance">
                    <AccordionTrigger className="text-base font-medium">
                      <BarChart className="h-4 w-4 mr-2" />
                      Performance Metrics
                    </AccordionTrigger>
                    <AccordionContent className="p-2">
                      <div className="grid grid-cols-2 md:grid-cols-3 gap-4">
                        {selectedReport.performanceMetrics.vo2Max && (
                          <div>
                            <p className="text-sm text-gray-500">VO2 Max</p>
                            <p className="font-medium">{selectedReport.performanceMetrics.vo2Max}</p>
                          </div>
                        )}
                        
                        {selectedReport.performanceMetrics.sprintSpeed && (
                          <div>
                            <p className="text-sm text-gray-500">Sprint Speed</p>
                            <p className="font-medium">{selectedReport.performanceMetrics.sprintSpeed} m/s</p>
                          </div>
                        )}
                        
                        {selectedReport.performanceMetrics.agilityScore && (
                          <div>
                            <p className="text-sm text-gray-500">Agility Score</p>
                            <p className="font-medium">{selectedReport.performanceMetrics.agilityScore}</p>
                          </div>
                        )}
                        
                        {selectedReport.performanceMetrics.strength && (
                          <div>
                            <p className="text-sm text-gray-500">Strength Score</p>
                            <p className="font-medium">{selectedReport.performanceMetrics.strength}</p>
                          </div>
                        )}
                        
                        {selectedReport.performanceMetrics.flexibilityTest && (
                          <div>
                            <p className="text-sm text-gray-500">Flexibility Test</p>
                            <p className="font-medium">{selectedReport.performanceMetrics.flexibilityTest}</p>
                          </div>
                        )}
                        
                        {selectedReport.performanceMetrics.reactionTime && (
                          <div>
                            <p className="text-sm text-gray-500">Reaction Time</p>
                            <p className="font-medium">{selectedReport.performanceMetrics.reactionTime} ms</p>
                          </div>
                        )}
                        
                        {selectedReport.performanceMetrics.enduranceLevel && (
                          <div>
                            <p className="text-sm text-gray-500">Endurance Level</p>
                            <p className="font-medium">{selectedReport.performanceMetrics.enduranceLevel}</p>
                          </div>
                        )}
                        
                        {selectedReport.performanceMetrics.verticalJump && (
                          <div>
                            <p className="text-sm text-gray-500">Vertical Jump</p>
                            <p className="font-medium">{selectedReport.performanceMetrics.verticalJump} cm</p>
                          </div>
                        )}
                        
                        {selectedReport.performanceMetrics.balanceTest && (
                          <div>
                            <p className="text-sm text-gray-500">Balance Test</p>
                            <p className="font-medium">{selectedReport.performanceMetrics.balanceTest}</p>
                          </div>
                        )}
                      </div>
                    </AccordionContent>
                  </AccordionItem>
                )}
                
                {/* Injury Details Section */}
                {selectedReport.injuryDetails && (
                  <AccordionItem value="injuries">
                    <AccordionTrigger className="text-base font-medium">
                      <Activity className="h-4 w-4 mr-2" />
                      Injury Details
                    </AccordionTrigger>
                    <AccordionContent className="p-2">
                      {selectedReport.injuryDetails.currentInjuries && selectedReport.injuryDetails.currentInjuries.length > 0 && (
                        <div className="mb-4">
                          <h4 className="font-medium mb-2">Current Injuries</h4>
                          <div className="space-y-3">
                            {selectedReport.injuryDetails.currentInjuries.map((injury, idx) => (
                              <div key={idx} className="border rounded-md p-3">
                                <div className="grid grid-cols-2 gap-2">
                                  <div>
                                    <p className="text-sm text-gray-500">Type</p>
                                    <p className="font-medium">{injury.type || "N/A"}</p>
                                  </div>
                                  <div>
                                    <p className="text-sm text-gray-500">Location</p>
                                    <p className="font-medium">{injury.location || "N/A"}</p>
                                  </div>
                                  <div>
                                    <p className="text-sm text-gray-500">Severity</p>
                                    <p className="font-medium">{injury.severity || "N/A"}</p>
                                  </div>
                                  {injury.startDate && (
                                    <div>
                                      <p className="text-sm text-gray-500">Start Date</p>
                                      <p className="font-medium">{formatDate(injury.startDate)}</p>
                                    </div>
                                  )}
                                  {injury.expectedRecovery && (
                                    <div>
                                      <p className="text-sm text-gray-500">Expected Recovery</p>
                                      <p className="font-medium">{formatDate(injury.expectedRecovery)}</p>
                                    </div>
                                  )}
                                </div>
                                {injury.notes && (
                                  <div className="mt-2">
                                    <p className="text-sm text-gray-500">Notes</p>
                                    <p className="font-medium">{injury.notes}</p>
                                  </div>
                                )}
                              </div>
                            ))}
                          </div>
                        </div>
                      )}
                      
                      {selectedReport.injuryDetails.pastInjuries && (
                        <div className="mb-3">
                          <p className="text-sm text-gray-500">Past Injuries</p>
                          <p className="font-medium">{selectedReport.injuryDetails.pastInjuries}</p>
                        </div>
                      )}
                      
                      {selectedReport.injuryDetails.ongoingTreatment && (
                        <div className="mb-3">
                          <p className="text-sm text-gray-500">Ongoing Treatment</p>
                          <p className="font-medium">{selectedReport.injuryDetails.ongoingTreatment}</p>
                        </div>
                      )}
                      
                      {selectedReport.injuryDetails.returnToPlayStatus && (
                        <div>
                          <p className="text-sm text-gray-500">Return to Play Status</p>
                          <p className="font-medium">{selectedReport.injuryDetails.returnToPlayStatus}</p>
                        </div>
                      )}
                    </AccordionContent>
                  </AccordionItem>
                )}
                
                {/* Test Results Section */}
                {selectedReport.testResults && (
                  <AccordionItem value="test-results">
                    <AccordionTrigger className="text-base font-medium">
                      <Clipboard className="h-4 w-4 mr-2" />
                      Test Results
                    </AccordionTrigger>
                    <AccordionContent className="p-2">
                      <div className="grid grid-cols-1 md:grid-cols-2 gap-4">
                        {selectedReport.testResults.bloodTest && (
                          <div>
                            <p className="text-sm text-gray-500">Blood Test</p>
                            <p className="font-medium">{selectedReport.testResults.bloodTest}</p>
                          </div>
                        )}
                        
                        {selectedReport.testResults.urineTest && (
                          <div>
                            <p className="text-sm text-gray-500">Urine Test</p>
                            <p className="font-medium">{selectedReport.testResults.urineTest}</p>
                          </div>
                        )}
                        
                        {selectedReport.testResults.ecg && (
                          <div>
                            <p className="text-sm text-gray-500">ECG</p>
                            <p className="font-medium">{selectedReport.testResults.ecg}</p>
                          </div>
                        )}
                        
                        {selectedReport.testResults.eeg && (
                          <div>
                            <p className="text-sm text-gray-500">EEG</p>
                            <p className="font-medium">{selectedReport.testResults.eeg}</p>
                          </div>
                        )}
                        
                        {selectedReport.testResults.mriScan && (
                          <div>
                            <p className="text-sm text-gray-500">MRI Scan</p>
                            <p className="font-medium">{selectedReport.testResults.mriScan}</p>
                          </div>
                        )}
                        
                        {selectedReport.testResults.xray && (
                          <div>
                            <p className="text-sm text-gray-500">X-Ray</p>
                            <p className="font-medium">{selectedReport.testResults.xray}</p>
                          </div>
                        )}
                        
                        {selectedReport.testResults.ctScan && (
                          <div>
                            <p className="text-sm text-gray-500">CT Scan</p>
                            <p className="font-medium">{selectedReport.testResults.ctScan}</p>
                          </div>
                        )}
                      </div>
                      
                      {selectedReport.testResults.additionalResults && selectedReport.testResults.additionalResults.length > 0 && (
                        <div className="mt-4">
                          <h4 className="font-medium mb-2">Additional Test Results</h4>
                          <ul className="list-disc pl-5 space-y-1">
                            {selectedReport.testResults.additionalResults.map((result, idx) => (
                              <li key={idx}>{result}</li>
                            ))}
                          </ul>
                        </div>
                      )}
                    </AccordionContent>
                  </AccordionItem>
                )}
                
                {/* Nutrition Section */}
                {selectedReport.nutrition && (
                  <AccordionItem value="nutrition">
                    <AccordionTrigger className="text-base font-medium">
                      <Apple className="h-4 w-4 mr-2" />
                      Nutrition
                    </AccordionTrigger>
                    <AccordionContent className="p-2">
                      <div className="grid grid-cols-1 md:grid-cols-2 gap-4">
                        {selectedReport.nutrition.caloricIntake && (
                          <div>
                            <p className="text-sm text-gray-500">Caloric Intake</p>
                            <p className="font-medium">{selectedReport.nutrition.caloricIntake} kcal</p>
                          </div>
                        )}
                        
                        {selectedReport.nutrition.waterIntake && (
                          <div>
                            <p className="text-sm text-gray-500">Water Intake</p>
                            <p className="font-medium">{selectedReport.nutrition.waterIntake} liters</p>
                          </div>
                        )}
                        
                        {selectedReport.nutrition.nutrientDeficiencies && (
                          <div className="md:col-span-2">
                            <p className="text-sm text-gray-500">Nutrient Deficiencies</p>
                            <p className="font-medium">{selectedReport.nutrition.nutrientDeficiencies}</p>
                          </div>
                        )}
                      </div>
                      
                      {selectedReport.nutrition.supplements && selectedReport.nutrition.supplements.length > 0 && (
                        <div className="mt-4">
                          <h4 className="font-medium mb-2">Supplements</h4>
                          <div className="flex flex-wrap gap-2">
                            {selectedReport.nutrition.supplements.map((supplement, idx) => (
                              <Badge key={idx} variant="outline">{supplement}</Badge>
                            ))}
                          </div>
                        </div>
                      )}
                      
                      {selectedReport.nutrition.dietaryRestrictions && selectedReport.nutrition.dietaryRestrictions.length > 0 && (
                        <div className="mt-4">
                          <h4 className="font-medium mb-2">Dietary Restrictions</h4>
                          <div className="flex flex-wrap gap-2">
                            {selectedReport.nutrition.dietaryRestrictions.map((restriction, idx) => (
                              <Badge key={idx} variant="outline" className="bg-red-50">{restriction}</Badge>
                            ))}
                          </div>
                        </div>
                      )}
                      
                      {selectedReport.nutrition.dietaryRecommendations && (
                        <div className="mt-4">
                          <p className="text-sm text-gray-500">Dietary Recommendations</p>
                          <p className="font-medium">{selectedReport.nutrition.dietaryRecommendations}</p>
                        </div>
                      )}
                    </AccordionContent>
                  </AccordionItem>
                )}
                
                {/* Mental Health Section */}
                {selectedReport.mentalHealth && (
                  <AccordionItem value="mental-health">
                    <AccordionTrigger className="text-base font-medium">
                      <Brain className="h-4 w-4 mr-2" />
                      Mental Health
                    </AccordionTrigger>
                    <AccordionContent className="p-2">
                      <div className="grid grid-cols-1 md:grid-cols-3 gap-4">
                        {selectedReport.mentalHealth.stressLevel !== undefined && (
                          <div>
                            <p className="text-sm text-gray-500">Stress Level (0-10)</p>
                            <p className="font-medium">{selectedReport.mentalHealth.stressLevel}</p>
                          </div>
                        )}
                        
                        {selectedReport.mentalHealth.sleepQuality !== undefined && (
                          <div>
                            <p className="text-sm text-gray-500">Sleep Quality (0-10)</p>
                            <p className="font-medium">{selectedReport.mentalHealth.sleepQuality}</p>
                          </div>
                        )}
                        
                        {selectedReport.mentalHealth.cognitiveScore !== undefined && (
                          <div>
                            <p className="text-sm text-gray-500">Cognitive Score (0-100)</p>
                            <p className="font-medium">{selectedReport.mentalHealth.cognitiveScore}</p>
                          </div>
                        )}
                      </div>
                      
                      {selectedReport.mentalHealth.mentalHealthNotes && (
                        <div className="mt-4">
                          <p className="text-sm text-gray-500">Mental Health Notes</p>
                          <p className="font-medium">{selectedReport.mentalHealth.mentalHealthNotes}</p>
                        </div>
                      )}
                    </AccordionContent>
                  </AccordionItem>
                )}
                
                {/* Notes & Recommendations Section */}
                <AccordionItem value="notes" defaultOpen>
                  <AccordionTrigger className="text-base font-medium">
                    <FileText className="h-4 w-4 mr-2" />
                    Notes & Recommendations
                  </AccordionTrigger>
                  <AccordionContent className="p-2">
                    {selectedReport.doctorsNotes && (
                      <div className="mb-4">
                        <p className="text-sm text-gray-500">Doctor's Notes</p>
                        <p className="font-medium">{selectedReport.doctorsNotes}</p>
                      </div>
                    )}
                    
                    {selectedReport.physicianNotes && (
                      <div className="mb-4">
                        <p className="text-sm text-gray-500">Physician Notes</p>
                        <p className="font-medium">{selectedReport.physicianNotes}</p>
                      </div>
                    )}
                    
                    {selectedReport.recommendations && selectedReport.recommendations.length > 0 && (
                      <div>
                        <p className="text-sm text-gray-500 mb-1">Recommendations</p>
                        <ul className="list-disc pl-5 space-y-1">
                          {selectedReport.recommendations.map((recommendation, idx) => (
                            <li key={idx} className="font-medium">{recommendation}</li>
                          ))}
                        </ul>
                      </div>
                    )}
                  </AccordionContent>
                </AccordionItem>
                
                {/* Attachments Section */}
                {((selectedReport.attachments && selectedReport.attachments.length > 0) || 
                  (selectedReport.reportFileUrl && selectedReport.reportFileUrl.length > 0)) && (
                  <AccordionItem value="attachments">
                    <AccordionTrigger className="text-base font-medium">
                      <Upload className="h-4 w-4 mr-2" />
                      Attachments
                    </AccordionTrigger>
                    <AccordionContent className="p-2">
                      <div className="space-y-2">
                        {selectedReport.attachments && selectedReport.attachments.map((attachment, idx) => (
                          <div key={idx} className="flex items-center justify-between p-2 bg-gray-50 rounded-md">
                            <div className="flex items-center">
                              <FileText className="h-4 w-4 mr-2 text-blue-500" />
                              <span>{attachment.name || `Attachment ${idx + 1}`}</span>
                            </div>
                            <a href={attachment.fileUrl} target="_blank" rel="noopener noreferrer">
                              <Button variant="outline" size="sm">Download</Button>
                            </a>
                          </div>
                        ))}
                        
                        {selectedReport.reportFileUrl && selectedReport.reportFileUrl.map((fileUrl, idx) => (
                          <div key={idx} className="flex items-center justify-between p-2 bg-gray-50 rounded-md">
                            <div className="flex items-center">
                              <FileText className="h-4 w-4 mr-2 text-blue-500" />
                              <span>Report File {idx + 1}</span>
                            </div>
                            <a href={fileUrl} target="_blank" rel="noopener noreferrer">
                              <Button variant="outline" size="sm">Download</Button>
                            </a>
                          </div>
                        ))}
                      </div>
                    </AccordionContent>
                  </AccordionItem>
                )}
              </Accordion>
              
              <DialogFooter className="mt-6 px-6 pb-6">
                <Button variant="outline" onClick={() => setReportModalOpen(false)}>
                  Close
                </Button>
                <Button 
                  variant="outline" 
                  onClick={() => {
                    // Print function for report
                    window.print();
                  }}>
                  <Printer className="h-4 w-4 mr-2" />
                  Print
                </Button>
              </DialogFooter>
            </div>
          ) : (
            <div className="p-6 flex justify-center items-center">
              <Loader2 className="h-6 w-6 animate-spin text-blue-600" />
              <span className="ml-2">Loading report details...</span>
            </div>
          )}
        </DialogContent>
      </Dialog>
    </div>
  );
}

export default AthleteMedicalRecords;
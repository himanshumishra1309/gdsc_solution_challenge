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
import { Badge } from "@/components/ui/badge";
import {
  Card,
  CardContent,
  CardDescription,
  CardHeader,
  CardTitle,
} from "@/components/ui/card";
import {
  Dialog,
  DialogContent,
  DialogDescription,
  DialogFooter,
  DialogHeader,
  DialogTitle,
} from "@/components/ui/dialog";
import { ScrollArea } from "@/components/ui/scroll-area";
import { toast, ToastContainer } from "react-toastify";
import "react-toastify/dist/ReactToastify.css";
import axios from "axios";

// API URLs for medical reports
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

// Medical report endpoint definitions
const MEDICAL_REPORT_ENDPOINTS = {
  getMyReports: "/medical-reports/me",
  getReportDetails: (id) => `/medical-reports/me/${id}`
};

function ViewMedicalReports() {
  // State for medical records
  const [records, setRecords] = useState([]);
  const [selectedRecord, setSelectedRecord] = useState(null);
  const [recordDialogOpen, setRecordDialogOpen] = useState(false);
  const [recordSearchTerm, setRecordSearchTerm] = useState("");
  
  // State for loading and errors
  const [loading, setLoading] = useState({
    records: false,
    recordDetails: false
  });

  const [error, setError] = useState({
    records: null,
    recordDetails: null
  });

  // Fetch athlete's medical reports on component mount
  useEffect(() => {
    fetchMyMedicalReports();
  }, []);

  // Check if user is logged in
  useEffect(() => {
    const token = sessionStorage.getItem("athleteAccessToken");
    if (!token) {
      toast.error("Please log in to access your medical reports");
    }
  }, []);

  // Function to fetch all medical reports for the logged-in athlete
  const fetchMyMedicalReports = async () => {
    setLoading((prev) => ({ ...prev, records: true }));
    setError((prev) => ({ ...prev, records: null }));
  
    try {
      const response = await api.get(MEDICAL_REPORT_ENDPOINTS.getMyReports);
      console.log("Medical reports response:", response.data);
      
      // Debug the actual structure of the reports
      console.log("Reports structure:", response.data?.data?.reports?.[0]);
      
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
  if (!reportId) {
    console.error("Report ID is undefined or null");
    toast.error("Cannot view details: Report ID is missing");
    return;
  }

  setLoading((prev) => ({ ...prev, recordDetails: true }));
  setError((prev) => ({ ...prev, recordDetails: null }));

  // Log the ID for debugging
  console.log("Requesting report with ID:", reportId);
  
  try {
    const response = await api.get(MEDICAL_REPORT_ENDPOINTS.getReportDetails(reportId));
    console.log("Medical report details response:", response.data);
    
    if (response.data?.data) {
      setSelectedRecord(response.data.data);
      setRecordDialogOpen(true);
    }
  } catch (err) {
    console.error("Failed to fetch medical report details:", err);
    console.error("Error details:", err.response?.data);
    setError((prev) => ({
      ...prev,
      recordDetails: err.response?.data?.message || "Failed to load report details"
    }));
    toast.error(err.response?.data?.message || "Failed to load medical report details");
  } finally {
    setLoading((prev) => ({ ...prev, recordDetails: false }));
  }
};

  // Filter records based on search term
  const filteredRecords = records.filter((record) =>
    (record.testName || "").toLowerCase().includes(recordSearchTerm.toLowerCase()) ||
    (record.doctorInfo?.name || "").toLowerCase().includes(recordSearchTerm.toLowerCase())
  );

  return (
    <div className="container mx-auto p-6">
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
                    <TableRow key={record._id || record.id}>
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
                          // Use the ID that's actually available
                          onClick={() => {
                            console.log("Clicking on record:", record);
                            fetchMedicalReportDetails(record._id || record.id);
                          }}
                          className="text-lg"
                          disabled={loading.recordDetails}
                        >
                          View Details
                        </Button>
                      </TableCell>
                    </TableRow>
                  ))
                )  : (
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

      {/* Medical Record Details Dialog */}
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

export default ViewMedicalReports;
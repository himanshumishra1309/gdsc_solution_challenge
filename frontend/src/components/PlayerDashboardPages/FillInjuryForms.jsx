import React, { useState } from "react";
import { Select, SelectTrigger, SelectValue, SelectContent, SelectItem } from "@/components/ui/select";
import { Button } from "@/components/ui/button";
import { Card, CardHeader, CardTitle, CardContent } from "@/components/ui/card";


const formTypes = ["Injury Report", "Training Feedback", "Diet Plan"];

const FillInjuryForms = () => {
  const [selectedFormType, setSelectedFormType] = useState(formTypes[0]);
  const [formData, setFormData] = useState({
    injuryDetails: {
      injuryDetails: "",
      dateOfInjury: "",
      timeOfInjury: "",
      typeOfInjury: "",
      affectedBodyPart: "",
      injurySeverity: "",
      canPlay: "",
      causeOfInjury: "",
      firstAidProvided: "",
      externalFactors: "",
    },
    painAndSymptoms: {
      painLevel: "",
      symptoms: {
        swelling: false,
        bruising: false,
        numbness: false,
        weakness: false,
        dizziness: false,
        lossOfBalance: false,
        difficultyMoving: false,
      },
      injuryHistory: "",
    },
    trainingFeedback: "",
    dietPlan: "",
  });
  const [submittedForms, setSubmittedForms] = useState([]);
  const [message, setMessage] = useState("");

  const handleSubmit = () => {
    if (selectedFormType === "Injury Report") {
      // Validate required fields
      if (!formData.injuryDetails.injuryDetails.trim()) {
        setMessage("⚠️ Injury details cannot be empty.");
        return;
      }
      // Save form data
      const newForm = {
        type: selectedFormType,
        content: formData,
        id: Date.now(),
      };
      setSubmittedForms([newForm, ...submittedForms]);
      setFormData({
        injuryDetails: {
          injuryDetails: "",
          dateOfInjury: "",
          timeOfInjury: "",
          typeOfInjury: "",
          affectedBodyPart: "",
          injurySeverity: "",
          canPlay: "",
          causeOfInjury: "",
          firstAidProvided: "",
          externalFactors: "",
        },
        painAndSymptoms: {
          painLevel: "",
          symptoms: {
            swelling: false,
            bruising: false,
            numbness: false,
            weakness: false,
            dizziness: false,
            lossOfBalance: false,
            difficultyMoving: false,
          },
          injuryHistory: "",
        },
        trainingFeedback: "",
        dietPlan: "",
      });
      setMessage(`✅ Injury Report submitted successfully!`);
    }
    if (selectedFormType === "Training Feedback" || selectedFormType === "Diet Plan") {
      if (!formData[selectedFormType.toLowerCase()].trim()) {
        setMessage(`⚠️ ${selectedFormType} details cannot be empty.`);
        return;
      }
      // Save form data
      const newForm = {
        type: selectedFormType,
        content: formData,
        id: Date.now(),
      };
      setSubmittedForms([newForm, ...submittedForms]);
      setFormData({
        injuryDetails: {
          injuryDetails: "",
          dateOfInjury: "",
          timeOfInjury: "",
          typeOfInjury: "",
          affectedBodyPart: "",
          injurySeverity: "",
          canPlay: "",
          causeOfInjury: "",
          firstAidProvided: "",
          externalFactors: "",
        },
        painAndSymptoms: {
          painLevel: "",
          symptoms: {
            swelling: false,
            bruising: false,
            numbness: false,
            weakness: false,
            dizziness: false,
            lossOfBalance: false,
            difficultyMoving: false,
          },
          injuryHistory: "",
        },
        trainingFeedback: "",
        dietPlan: "",
      });
      setMessage(`✅ ${selectedFormType} submitted successfully!`);
    }
  };

  const handleFormChange = (field, value, section) => {
    if (section === "painAndSymptoms" && field === "symptoms") {
      setFormData((prevData) => ({
        ...prevData,
        painAndSymptoms: {
          ...prevData.painAndSymptoms,
          symptoms: {
            ...prevData.painAndSymptoms.symptoms,
            [value]: !prevData.painAndSymptoms.symptoms[value],
          },
        },
      }));
    } else {
      setFormData((prevData) => ({
        ...prevData,
        [section]: {
          ...prevData[section],
          [field]: value,
        },
      }));
    }
  };

  const handleShare = (formId) => {
    setMessage(`📤 The ${selectedFormType} has been shared successfully!`);
  };

  return (
    <div className="p-6 space-y-6">
      <h1 className="text-2xl font-semibold text-center">Forms Management</h1>

      {/* Show Message */}
      {message && <div className="p-3 text-white bg-blue-500 rounded text-center">{message}</div>}

      {/* Select Form Type */}
      <div className="w-full flex justify-center">
        <Select value={selectedFormType} onValueChange={setSelectedFormType} className="w-1/3">
          <SelectTrigger className="w-full">
            <SelectValue>{selectedFormType}</SelectValue>
          </SelectTrigger>
          <SelectContent>
            {formTypes.map((form) => (
              <SelectItem key={form} value={form}>
                {form}
              </SelectItem>
            ))}
          </SelectContent>
        </Select>
      </div>

      {/* Conditional Form Fields */}
      {selectedFormType === "Injury Report" && (
        <div className="space-y-6">
          {/* Injury Details Section */}
          <div className="border p-4 rounded-lg shadow-sm space-y-4 bg-gray-100">
            <h3 className="text-xl font-semibold">Injury Details</h3>
            <input
              type="text"
              placeholder="Injury Details"
              className="input p-4 text-lg w-full bg-white rounded-md shadow-md"
              value={formData.injuryDetails.injuryDetails}
              onChange={(e) => handleFormChange("injuryDetails", e.target.value, "injuryDetails")}
            />
            <div className="grid grid-cols-2 gap-4">
              <input
                type="date"
                className="input p-4 text-lg w-full bg-white rounded-md shadow-md"
                value={formData.injuryDetails.dateOfInjury}
                onChange={(e) => handleFormChange("dateOfInjury", e.target.value, "injuryDetails")}
              />
              <input
                type="time"
                className="input p-4 text-lg w-full bg-white rounded-md shadow-md"
                value={formData.injuryDetails.timeOfInjury}
                onChange={(e) => handleFormChange("timeOfInjury", e.target.value, "injuryDetails")}
              />
            </div>
            <input
              type="text"
              placeholder="Type of Injury"
              className="input p-4 text-lg w-full bg-white rounded-md shadow-md"
              value={formData.injuryDetails.typeOfInjury}
              onChange={(e) => handleFormChange("typeOfInjury", e.target.value, "injuryDetails")}
            />
            <input
              type="text"
              placeholder="Affected Body Part"
              className="input p-4 text-lg w-full bg-white rounded-md shadow-md"
              value={formData.injuryDetails.affectedBodyPart}
              onChange={(e) => handleFormChange("affectedBodyPart", e.target.value, "injuryDetails")}
            />
            <input
              type="text"
              placeholder="Injury Severity"
              className="input p-4 text-lg w-full bg-white rounded-md shadow-md"
              value={formData.injuryDetails.injurySeverity}
              onChange={(e) => handleFormChange("injurySeverity", e.target.value, "injuryDetails")}
            />
            <select
              className="input p-4 text-lg w-full bg-white rounded-md shadow-md"
              value={formData.injuryDetails.canPlay}
              onChange={(e) => handleFormChange("canPlay", e.target.value, "injuryDetails")}
            >
              <option value="">Can the athlete play?</option>
              <option value="yes">Yes</option>
              <option value="no">No</option>
            </select>
            <input
              type="text"
              placeholder="Cause of Injury"
              className="input p-4 text-lg w-full bg-white rounded-md shadow-md"
              value={formData.injuryDetails.causeOfInjury}
              onChange={(e) => handleFormChange("causeOfInjury", e.target.value, "injuryDetails")}
            />
            <select
              className="input p-4 text-lg w-full bg-white rounded-md shadow-md"
              value={formData.injuryDetails.firstAidProvided}
              onChange={(e) => handleFormChange("firstAidProvided", e.target.value, "injuryDetails")}
            >
              <option value="">Was first aid provided?</option>
              <option value="yes">Yes</option>
              <option value="no">No</option>
            </select>
            <input
              type="text"
              placeholder="External Factors"
              className="input p-4 text-lg w-full bg-white rounded-md shadow-md"
              value={formData.injuryDetails.externalFactors}
              onChange={(e) => handleFormChange("externalFactors", e.target.value, "injuryDetails")}
            />
          </div>

          {/* Pain and Symptoms Assessment Section */}
          <div className="border p-4 rounded-lg shadow-sm space-y-4 bg-gray-100">
            <h3 className="text-xl font-semibold">Pain and Symptoms Assessment</h3>
            <div className="flex items-center space-x-4">
              <label>Pain Level:</label>
              <input
                type="number"
                min="1"
                max="10"
                className="input p-4 text-lg w-16 bg-white rounded-md shadow-md"
                value={formData.painAndSymptoms.painLevel}
                onChange={(e) => handleFormChange("painLevel", e.target.value, "painAndSymptoms")}
              />
            </div>

            {/* Symptoms */}
            <div className="space-y-2">
              <label className="flex items-center">
                <input
                  type="checkbox"
                  checked={formData.painAndSymptoms.symptoms.swelling}
                  onChange={() => handleFormChange("symptoms", "swelling", "painAndSymptoms")}
                />
                Swelling
              </label>
              <label className="flex items-center">
                <input
                  type="checkbox"
                  checked={formData.painAndSymptoms.symptoms.bruising}
                  onChange={() => handleFormChange("symptoms", "bruising", "painAndSymptoms")}
                />
                Bruising
              </label>
              <label className="flex items-center">
                <input
                  type="checkbox"
                  checked={formData.painAndSymptoms.symptoms.numbness}
                  onChange={() => handleFormChange("symptoms", "numbness", "painAndSymptoms")}
                />
                Numbness
              </label>
              <label className="flex items-center">
                <input
                  type="checkbox"
                  checked={formData.painAndSymptoms.symptoms.weakness}
                  onChange={() => handleFormChange("symptoms", "weakness", "painAndSymptoms")}
                />
                Weakness
              </label>
              <label className="flex items-center">
                <input
                  type="checkbox"
                  checked={formData.painAndSymptoms.symptoms.dizziness}
                  onChange={() => handleFormChange("symptoms", "dizziness", "painAndSymptoms")}
                />
                Dizziness
              </label>
              <label className="flex items-center">
                <input
                  type="checkbox"
                  checked={formData.painAndSymptoms.symptoms.lossOfBalance}
                  onChange={() => handleFormChange("symptoms", "lossOfBalance", "painAndSymptoms")}
                />
                Loss of Balance
              </label>
              <label className="flex items-center">
                <input
                  type="checkbox"
                  checked={formData.painAndSymptoms.symptoms.difficultyMoving}
                  onChange={() => handleFormChange("symptoms", "difficultyMoving", "painAndSymptoms")}
                />
                Difficulty Moving
              </label>
            </div>

            {/* Injury History */}
            <label className="flex items-center">
              <span>Has this injury happened before?</span>
              <select
                className="input p-4 text-lg w-32 ml-2 bg-white rounded-md shadow-md"
                value={formData.painAndSymptoms.injuryHistory}
                onChange={(e) => handleFormChange("injuryHistory", e.target.value, "painAndSymptoms")}
              >
                <option value="">Select</option>
                <option value="yes">Yes</option>
                <option value="no">No</option>
              </select>
            </label>
          </div>
        </div>
      )}

      {/* Training Feedback */}
      {selectedFormType === "Training Feedback" && (
        <div className="border p-4 rounded-lg shadow-sm space-y-4 bg-gray-100">
          <h3 className="text-xl font-semibold">Training Feedback</h3>
          <textarea
            className="input p-4 text-lg w-full bg-white rounded-md shadow-md"
            placeholder="Provide your feedback..."
            rows="6"
            value={formData.trainingFeedback}
            onChange={(e) => handleFormChange("trainingFeedback", e.target.value, "trainingFeedback")}
          />
        </div>
      )}

      {/* Diet Plan */}
      {selectedFormType === "Diet Plan" && (
        <div className="border p-4 rounded-lg shadow-sm space-y-4 bg-gray-100">
          <h3 className="text-xl font-semibold">Diet Plan</h3>
          <textarea
            className="input p-4 text-lg w-full bg-white rounded-md shadow-md"
            placeholder="Enter the diet plan..."
            rows="6"
            value={formData.dietPlan}
            onChange={(e) => handleFormChange("dietPlan", e.target.value, "dietPlan")}
          />
        </div>
      )}

      {/* Submit Button */}
      <div className="flex justify-center">
        <Button onClick={handleSubmit}>Submit</Button>
      </div>

      {/* Display Submitted Forms */}
      <div className="mt-6">
        <h2 className="text-2xl font-semibold">Submitted Forms</h2>
        <ul className="space-y-4">
          {submittedForms.map((form) => (
            <li key={form.id} className="bg-gray-50 p-4 rounded-md shadow-sm">
              <Card>
                <CardHeader>
                  <CardTitle>{form.type}</CardTitle>
                </CardHeader>
                <CardContent>
                  <Button onClick={() => handleShare(form.id)}>Share</Button>
                </CardContent>
              </Card>
            </li>
          ))}
        </ul>
      </div>
    </div>
  );
};

export default FillInjuryForms;

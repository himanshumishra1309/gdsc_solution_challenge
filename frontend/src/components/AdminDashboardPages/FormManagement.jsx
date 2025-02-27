import React, { useState } from "react";
import { Select, SelectTrigger, SelectValue, SelectContent, SelectItem } from "@/components/ui/select";
import { Textarea } from "@/components/ui/textarea";
import { Button } from "@/components/ui/button";
import { Card, CardHeader, CardTitle, CardContent } from "@/components/ui/card";

const formTypes = ["Injury Report", "Training Feedback", "Diet Plan"];

const FormManagement = () => {
  const [selectedFormType, setSelectedFormType] = useState(formTypes[0]);
  const [formContent, setFormContent] = useState("");
  const [submittedForms, setSubmittedForms] = useState([]);
  const [message, setMessage] = useState("");

  const handleSubmit = () => {
    if (!formContent.trim()) {
      setMessage("⚠️ Form content cannot be empty.");
      return;
    }

    const newForm = {
      type: selectedFormType,
      content: formContent,
      id: Date.now(),
    };

    setSubmittedForms([newForm, ...submittedForms]);
    setFormContent("");
    setMessage(`✅ ${selectedFormType} submitted successfully!`);
  };

  const handleShare = (formId) => {
    setMessage(`📤 The ${selectedFormType} has been shared successfully!`);
  };

  return (
    <div className="p-6 space-y-6">
      <h1 className="text-2xl font-bold">Forms Management</h1>

      {/* Show Message */}
      {message && <div className="p-3 text-white bg-blue-500 rounded">{message}</div>}

      {/* Select Form Type */}
      <Select value={selectedFormType} onValueChange={setSelectedFormType}>
        <SelectTrigger className="w-full">
          <SelectValue>{selectedFormType}</SelectValue>
        </SelectTrigger>
        <SelectContent>
          {formTypes.map((form) => (
            <SelectItem key={form} value={form}>{form}</SelectItem>
          ))}
        </SelectContent>
      </Select>

      {/* Form Input */}
      <Textarea
        value={formContent}
        onChange={(e) => setFormContent(e.target.value)}
        placeholder={`Enter details for ${selectedFormType}...`}
        className="w-full h-32"
      />

      <Button onClick={handleSubmit} className="w-full">Submit Form</Button>

      {/* Submitted Forms */}
      <div className="space-y-4">
        {submittedForms.length > 0 && <h2 className="text-xl font-semibold">Submitted Forms</h2>}
        {submittedForms.map((form) => (
          <Card key={form.id}>
            <CardHeader>
              <CardTitle>{form.type}</CardTitle>
            </CardHeader>
            <CardContent>
              <p>{form.content}</p>
              <Button variant="secondary" className="mt-2" onClick={() => handleShare(form.id)}>
                Share Form
              </Button>
            </CardContent>
          </Card>
        ))}
      </div>
    </div>
  );
};

export default FormManagement;

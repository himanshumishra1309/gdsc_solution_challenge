'use client'

import { useState } from "react"
import { Check, ChevronsUpDown, Upload, ArrowRight, ArrowLeft } from "lucide-react"
import { Button } from "@/components/ui/button"
import { Card, CardContent, CardDescription, CardFooter, CardHeader, CardTitle } from "@/components/ui/card"
import { Input } from "@/components/ui/input"
import { Label } from "@/components/ui/label"
import { Textarea } from "@/components/ui/textarea"
import { Command, CommandEmpty, CommandGroup, CommandInput, CommandItem, CommandList } from "@/components/ui/command"
import { Popover, PopoverContent, PopoverTrigger } from "@/components/ui/popover"
import { Dialog, DialogContent, DialogHeader, DialogTitle, DialogDescription } from "@/components/ui/dialog"
import { Separator } from "@/components/ui/separator"
import { Alert, AlertTitle, AlertDescription } from "@/components/ui/alert"
import { useNavigate } from "react-router-dom"
import axios from "axios" // Import axios

export default function OrganizationSignup() {
  const navigate = useNavigate()
  
  // Registration step state
  const [currentStep, setCurrentStep] = useState(1)
  const [organizationId, setOrganizationId] = useState(null)
  const [registrationComplete, setRegistrationComplete] = useState(false)
  const [isLoading, setIsLoading] = useState(false)
  const [error, setError] = useState("")
  
  // Organization states
  const [orgName, setOrgName] = useState("")
  const [orgEmail, setOrgEmail] = useState("")
  const [orgLogo, setOrgLogo] = useState(null)
  const [orgType, setOrgType] = useState("")
  const [certificates, setCertificates] = useState(null)
  const [address, setAddress] = useState("")
  const [country, setCountry] = useState("")
  const [state, setState] = useState("")
  
  // Admin states
  const [adminName, setAdminName] = useState("")
  const [adminEmail, setAdminEmail] = useState("")
  const [adminAvatar, setAdminAvatar] = useState(null)
  const [adminPassword, setAdminPassword] = useState("")
  const [confirmPassword, setConfirmPassword] = useState("")
  
  const [isSuccessDialogOpen, setIsSuccessDialogOpen] = useState(false)

  const countries = [
    { label: "India", value: "in" }, 
    { label: "United States", value: "us" },
  ]

  const states = {
    in: [
      { label: "Andhra Pradesh", value: "ap" },
      { label: "Bihar", value: "br" },
      { label: "Gujarat", value: "gj" },
      { label: "Karnataka", value: "ka" },
      { label: "Maharashtra", value: "mh" },
      { label: "Tamil Nadu", value: "tn" },
      { label: "Uttar Pradesh", value: "up" },
      { label: "West Bengal", value: "wb" },
    ],
    us: [
      { label: "California", value: "ca" },
      { label: "New York", value: "ny" },
      { label: "Texas", value: "tx" },
      { label: "Florida", value: "fl" },
      { label: "Illinois", value: "il" },
    ],
  }

  const organizationTypes = [
    { label: "Sports Club", value: "sports_club" },
    { label: "School/University", value: "education" },
    { label: "Professional Team", value: "pro_team" },
    { label: "Youth Development", value: "youth" },
    { label: "Sports Association", value: "association" },
    { label: "Government Body", value: "government" },
    { label: "Non-profit", value: "nonprofit" },
    { label: "Private Company", value: "company" },
  ]

// Step 1: Handle first step (organization details)
const handleNextStep = async (e) => {
  e.preventDefault()
  setError("")
  
  // Validate organization details
  if (!orgName || !orgEmail || !orgType || !address || !country || !state) {
    setError("Please fill all required organization fields")
    return
  }
  
  // Just move to admin step without API call yet
  setCurrentStep(2)
}

// Step 2: Handle complete registration (submit everything)
const handleCompleteRegistration = async (e) => {
  e.preventDefault()
  setError("")
  
  // Validate admin details
  if (!adminName || !adminEmail || !adminPassword || !confirmPassword) {
    setError("Please fill all required admin fields")
    return
  }
  
  if (adminPassword !== confirmPassword) {
    setError("Passwords don't match")
    return
  }
  
  setIsLoading(true)
  
  try {
    // Create form data for the complete registration
    const formData = new FormData()
    
    // Organization data
    formData.append("orgName", orgName)
    formData.append("orgEmail", orgEmail)
    formData.append("organizationType", orgType)
    formData.append("address", address)
    formData.append("country", country)
    formData.append("state", state)
    
    // Admin data
    formData.append("adminName", adminName)
    formData.append("adminEmail", adminEmail)
    formData.append("adminPassword", adminPassword)
    
    // Files
    if (orgLogo) formData.append("logo", orgLogo)
    if (certificates) formData.append("certificates", certificates)
    if (adminAvatar) formData.append("adminAvatar", adminAvatar)
    
    console.log("Sending registration data:", {
      organization: {
        orgName,
        orgEmail,
        organizationType: orgType,
        address,
        country,
        state
      },
      admin: {
        adminName,
        adminEmail
      },
      files: {
        logo: orgLogo ? orgLogo.name : null,
        certificates: certificates ? certificates.name : null,
        adminAvatar: adminAvatar ? adminAvatar.name : null
      }
    })
    
    // Send complete registration data
    const response = await axios.post(
      'http://localhost:8000/api/v1/organizations/register', 
      formData,
      {
        headers: {
          'Content-Type': 'multipart/form-data'
        }
      }
    )
    
    console.log("Registration response:", response.data)
    
    // Store organization ID in case needed later
    if (response.data?.data?.organization?._id) {
      setOrganizationId(response.data.data.organization._id)
    }
    
    // Show success dialog
    setRegistrationComplete(true)
    setIsSuccessDialogOpen(true)
  } catch (err) {
    console.error("Registration error:", err)
    if (err.response) {
      console.error("Error data:", err.response.data)
      setError(err.response.data.message || "Registration failed")
    } else if (err.request) {
      setError("No response from server. Please check your network connection.")
    } else {
      setError("Failed to send request: " + err.message)
    }
  } finally {
    setIsLoading(false)
  }
}
  
  // Go back to the previous step
  const handlePreviousStep = () => {
    setCurrentStep(1)
    setError("")
  }
  
  const handleCancel = () => {
    navigate("/")
  }
  
  // Return to home page after successful registration
  const handleReturnHome = () => {
    navigate("/")
  }

  return (
    <div className="min-h-screen bg-gradient-to-b from-blue-50 to-white flex items-center justify-center p-4">
      <Card className="w-full max-w-4xl shadow-lg">
        <CardHeader className="space-y-1 bg-primary text-primary-foreground rounded-t-lg">
          <CardTitle className="text-2xl font-bold">Organization Sign-up</CardTitle>
          <CardDescription className="text-primary-foreground/80">
            {currentStep === 1 
              ? "Step 1: Register your organization"
              : "Step 2: Create administrator account"}
          </CardDescription>
        </CardHeader>
        
        {/* Error message */}
        {error && (
          <div className="px-6 pt-4">
            <Alert variant="destructive">
              <AlertTitle>Error</AlertTitle>
              <AlertDescription>{error}</AlertDescription>
            </Alert>
          </div>
        )}
        
        {/* Step 1: Organization Registration */}
        {currentStep === 1 && (
          <form onSubmit={handleNextStep}>
            <CardContent className="grid gap-6 pt-6">
              <div className="space-y-2">
                <h3 className="text-lg font-semibold">Organization Information</h3>
              </div>

              <div className="grid md:grid-cols-2 gap-4">
                <div className="space-y-2">
                  <Label htmlFor="organization-name">Organization Name</Label>
                  <Input 
                    id="organization-name" 
                    placeholder="Enter organization name" 
                    value={orgName}
                    onChange={(e) => setOrgName(e.target.value)}
                    required 
                  />
                </div>

                <div className="space-y-2">
                  <Label htmlFor="organization-email">Organization Email</Label>
                  <Input 
                    id="organization-email" 
                    type="email"
                    placeholder="organization@example.com" 
                    value={orgEmail}
                    onChange={(e) => setOrgEmail(e.target.value)}
                    required 
                  />
                </div>
              </div>
              
              <div className="grid md:grid-cols-2 gap-4">
                <div className="space-y-2">
                  <Label htmlFor="organization-logo">Organization Logo</Label>
                  <div className="flex items-center gap-4">
                    <Input
                      id="organization-logo"
                      type="file"
                      accept="image/*"
                      onChange={(e) => setOrgLogo(e.target.files[0])}
                      className="flex-1"
                    />
                    {orgLogo && (
                      <div className="h-10 w-10 rounded-md bg-muted flex items-center justify-center">
                        <img 
                          src={URL.createObjectURL(orgLogo)} 
                          alt="Logo preview" 
                          className="max-h-full max-w-full object-contain"
                        />
                      </div>
                    )}
                  </div>
                </div>

                <div className="space-y-2">
                  <Label htmlFor="organization-type">Organization Type</Label>
                  <Popover>
                    <PopoverTrigger asChild>
                      <Button variant="outline" role="combobox" className="w-full justify-between">
                        {organizationTypes.find((type) => type.value === orgType)?.label || "Select organization type"}
                        <ChevronsUpDown className="ml-2 h-4 w-4 shrink-0 opacity-50" />
                      </Button>
                    </PopoverTrigger>
                    <PopoverContent className="w-full p-0">
                      <Command>
                        <CommandInput placeholder="Search organization type..." />
                        <CommandList>
                          <CommandEmpty>No type found.</CommandEmpty>
                          <CommandGroup>
                            {organizationTypes.map((type) => (
                              <CommandItem
                                key={type.value}
                                value={type.value}
                                onSelect={(currentValue) => {
                                  setOrgType(currentValue === orgType ? "" : currentValue)
                                }}
                              >
                                <Check
                                  className={`mr-2 h-4 w-4 ${orgType === type.value ? "opacity-100" : "opacity-0"}`}
                                />
                                {type.label}
                              </CommandItem>
                            ))}
                          </CommandGroup>
                        </CommandList>
                      </Command>
                    </PopoverContent>
                  </Popover>
                </div>
              </div>

              <div className="space-y-2">
                <Label htmlFor="certificates">Upload Certificates/Licenses</Label>
                <Input
                  id="certificates"
                  type="file"
                  accept=".pdf,.doc,.docx,.jpg,.jpeg,.png"
                  onChange={(e) => setCertificates(e.target.files[0])}
                  className="w-full"
                />
                <p className="text-xs text-muted-foreground">
                  Upload any relevant certificates or licenses your organization holds (PDF, DOC, or image formats)
                </p>
              </div>

              <div className="space-y-2">
                <Label htmlFor="address">Address</Label>
                <Textarea 
                  id="address" 
                  placeholder="Enter your organization's address" 
                  className="min-h-[80px]"
                  value={address}
                  onChange={(e) => setAddress(e.target.value)}
                  required
                />
              </div>

              <div className="grid md:grid-cols-2 gap-4">
                <div className="space-y-2">
                  <Label htmlFor="country">Country</Label>
                  <Popover>
                    <PopoverTrigger asChild>
                      <Button
                        variant="outline"
                        role="combobox"
                        className="w-full justify-between"
                      >
                        {country ? countries.find((c) => c.value === country)?.label : "Select country"}
                        <ChevronsUpDown className="ml-2 h-4 w-4 shrink-0 opacity-50" />
                      </Button>
                    </PopoverTrigger>
                    <PopoverContent className="w-full p-0">
                      <Command>
                        <CommandInput placeholder="Search country..." />
                        <CommandList>
                          <CommandEmpty>No country found.</CommandEmpty>
                          <CommandGroup>
                            {countries.map((c) => (
                              <CommandItem
                                key={c.value}
                                value={c.value}
                                onSelect={(currentValue) => {
                                  setCountry(currentValue === country ? "" : currentValue)
                                  setState("")
                                }}
                              >
                                <Check className={`mr-2 h-4 w-4 ${country === c.value ? "opacity-100" : "opacity-0"}`} />
                                {c.label}
                              </CommandItem>
                            ))}
                          </CommandGroup>
                        </CommandList>
                      </Command>
                    </PopoverContent>
                  </Popover>
                </div>

                <div className="space-y-2">
                  <Label htmlFor="state">State/Province</Label>
                  <Popover>
                    <PopoverTrigger asChild>
                      <Button
                        variant="outline"
                        role="combobox"
                        className="w-full justify-between"
                        disabled={!country || !states[country]}
                      >
                        {state && states[country]
                          ? states[country].find((s) => s.value === state)?.label
                          : "Select state"}
                        <ChevronsUpDown className="ml-2 h-4 w-4 shrink-0 opacity-50" />
                      </Button>
                    </PopoverTrigger>
                    <PopoverContent className="w-full p-0">
                      <Command>
                        <CommandInput placeholder="Search state..." />
                        <CommandList>
                          <CommandEmpty>No state found.</CommandEmpty>
                          <CommandGroup>
                            {country && states[country] ? (
                              states[country].map((s) => (
                                <CommandItem
                                  key={s.value}
                                  value={s.value}
                                  onSelect={(currentValue) => {
                                    setState(currentValue === state ? "" : currentValue)
                                  }}
                                >
                                  <Check className={`mr-2 h-4 w-4 ${state === s.value ? "opacity-100" : "opacity-0"}`} />
                                  {s.label}
                                </CommandItem>
                              ))
                            ) : (
                              <CommandItem disabled>Select a country first</CommandItem>
                            )}
                          </CommandGroup>
                        </CommandList>
                      </Command>
                    </PopoverContent>
                  </Popover>
                </div>
              </div>
            </CardContent>
            <CardFooter className="flex flex-col space-y-4 sm:flex-row sm:space-x-4 sm:space-y-0 bg-muted/50 p-6 rounded-b-lg">
              <Button type="button" variant="outline" className="w-full sm:w-auto" onClick={handleCancel}>
                Cancel
              </Button>
              <Button type="submit" className="w-full sm:w-auto" disabled={isLoading}>
                {isLoading ? "Processing..." : (
                  <>
                    Next Step <ArrowRight className="ml-2 h-4 w-4" />
                  </>
                )}
              </Button>
            </CardFooter>
          </form>
        )}
        
        {/* Step 2: Admin Registration */}
        {currentStep === 2 && (
          <form onSubmit={handleCompleteRegistration}>
            <CardContent className="grid gap-6 pt-6">
              <div className="space-y-2">
                <h3 className="text-lg font-semibold">Administrator Registration</h3>
                <p className="text-sm text-muted-foreground">
                  Create the first administrator account for your organization
                </p>
              </div>

              <div className="grid md:grid-cols-2 gap-4">
                <div className="space-y-2">
                  <Label htmlFor="admin-name">Admin Name</Label>
                  <Input 
                    id="admin-name" 
                    placeholder="Enter admin name"
                    value={adminName}
                    onChange={(e) => setAdminName(e.target.value)}
                    required 
                  />
                </div>

                <div className="space-y-2">
                  <Label htmlFor="admin-email">Admin Email</Label>
                  <Input 
                    id="admin-email" 
                    type="email"
                    placeholder="admin@example.com" 
                    value={adminEmail}
                    onChange={(e) => setAdminEmail(e.target.value)}
                    required 
                  />
                </div>
              </div>
              
              <div className="space-y-2">
                <Label htmlFor="admin-avatar">Admin Avatar (Optional)</Label>
                <div className="flex items-center gap-4">
                  <Input
                    id="admin-avatar"
                    type="file"
                    accept="image/*"
                    onChange={(e) => setAdminAvatar(e.target.files[0])}
                    className="flex-1"
                  />
                  {adminAvatar && (
                    <div className="h-10 w-10 rounded-full bg-muted flex items-center justify-center overflow-hidden">
                      <img 
                        src={URL.createObjectURL(adminAvatar)} 
                        alt="Avatar preview" 
                        className="h-full w-full object-cover"
                      />
                    </div>
                  )}
                </div>
              </div>
              
              <div className="grid md:grid-cols-2 gap-4">
                <div className="space-y-2">
                  <Label htmlFor="admin-password">Password</Label>
                  <Input 
                    id="admin-password" 
                    type="password"
                    placeholder="Create a strong password"
                    value={adminPassword}
                    onChange={(e) => setAdminPassword(e.target.value)}
                    required 
                  />
                </div>

                <div className="space-y-2">
                  <Label htmlFor="confirm-password">Confirm Password</Label>
                  <Input 
                    id="confirm-password" 
                    type="password"
                    placeholder="Confirm your password"
                    value={confirmPassword}
                    onChange={(e) => setConfirmPassword(e.target.value)}
                    required 
                  />
                </div>
              </div>
            </CardContent>
            <CardFooter className="flex flex-col space-y-4 sm:flex-row sm:space-x-4 sm:space-y-0 bg-muted/50 p-6 rounded-b-lg">
              <Button type="button" variant="outline" className="w-full sm:w-auto" onClick={handlePreviousStep}>
                <ArrowLeft className="mr-2 h-4 w-4" /> Back
              </Button>
              <Button type="submit" className="w-full sm:w-auto" disabled={isLoading}>
                {isLoading ? "Processing..." : "Complete Registration"}
              </Button>
            </CardFooter>
          </form>
        )}
        
        {/* Success Dialog */}
        <Dialog open={isSuccessDialogOpen} onOpenChange={setIsSuccessDialogOpen}>
          <DialogContent className="sm:max-w-md">
            <DialogHeader>
              <DialogTitle className="text-center">Registration Successful</DialogTitle>
              <DialogDescription className="text-center">
                Organization and admin account created successfully
              </DialogDescription>
            </DialogHeader>
            <div className="flex flex-col items-center justify-center space-y-4 py-4">
              <div className="rounded-full bg-green-100 p-3">
                <Check className="h-8 w-8 text-green-600" />
              </div>
              <div className="text-center space-y-2">
                <h3 className="font-medium text-lg">Thank you for registering!</h3>
                <p className="text-muted-foreground">
                  Your organization "{orgName}" has been registered successfully.
                </p>
                <p className="text-muted-foreground">
                  The administrator account for {adminEmail} has been created.
                </p>
                <p className="text-sm font-medium mt-4">
                  Please log in using your admin credentials to access the dashboard.
                </p>
              </div>
            </div>
            <div className="flex justify-center">
              <Button onClick={handleReturnHome} className="w-full sm:w-auto">
                Return to Home
              </Button>
            </div>
          </DialogContent>
        </Dialog>
      </Card>
    </div>
  )
}
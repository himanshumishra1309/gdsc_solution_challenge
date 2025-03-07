'use client'

import { useState } from "react"
import { Check, ChevronsUpDown } from "lucide-react"
import { Button } from "@/components/ui/button"
import { Card, CardContent, CardDescription, CardFooter, CardHeader, CardTitle } from "@/components/ui/card"
import { Input } from "@/components/ui/input"
import { Label } from "@/components/ui/label"
import { Textarea } from "@/components/ui/textarea"
import { Command, CommandEmpty, CommandGroup, CommandInput, CommandItem, CommandList } from "@/components/ui/command"
import { Popover, PopoverContent, PopoverTrigger } from "@/components/ui/popover"
import { Dialog, DialogContent, DialogHeader, DialogTitle, DialogDescription } from "@/components/ui/dialog"

export default function OrganizationSignup() {
  const [country, setCountry] = useState("")
  const [state, setState] = useState("")
  const [selectedCategories, setSelectedCategories] = useState([])
  const [email, setEmail] = useState("")
  const [password, setPassword] = useState("")
  const [isSignInDialogOpen, setIsSignInDialogOpen] = useState(false)

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

  const handleSignUp = (e) => {
    e.preventDefault()
    setIsSignInDialogOpen(true) // Show the sign-in dialog after signup
  }

  const handleSignIn = () => {
    console.log(`Signing in as Admin with email: ${email}`)
    
    setIsSignInDialogOpen(false)
    window.location.href = "/admin-dashboard" 
  }

  const handleCancel = () => {
    window.location.href = "/" 
  }

  return (
    <div className="min-h-screen bg-gradient-to-b from-blue-50 to-white flex items-center justify-center p-4">
      <Card className="w-full max-w-4xl shadow-lg">
        <CardHeader className="space-y-1 bg-primary text-primary-foreground rounded-t-lg">
          <CardTitle className="text-2xl font-bold">Organization Sign-up</CardTitle>
          <CardDescription className="text-primary-foreground/80">
            Register your organization to manage athletes and sports activities
          </CardDescription>
        </CardHeader>
        <form onSubmit={handleSignUp}>
          <CardContent className="grid gap-6 pt-6">
            <div className="grid md:grid-cols-2 gap-4">
              <div className="space-y-2">
                <Label htmlFor="organization-name">Organization Name</Label>
                <Input id="organization-name" placeholder="Enter organization name" required />
              </div>

              <div className="space-y-2">
                <Label htmlFor="organization-type">Organization Type</Label>
                <Popover>
                  <PopoverTrigger asChild>
                    <Button variant="outline" role="combobox" className="w-full justify-between">
                      {organizationTypes.find((type) => type.value === country)?.label || "Select organization type"}
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
                                setCountry(currentValue === country ? "" : currentValue)
                              }}
                            >
                              <Check
                                className={`mr-2 h-4 w-4 ${country === type.value ? "opacity-100" : "opacity-0"}`}
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
              <Label htmlFor="admin-email">Admin Email</Label>
              <Input id="admin-email" type="email" placeholder="admin@organization.com" required />
            </div>

            <div className="space-y-2">
              <Label>Sports/Athlete Categories Managed</Label>
              <Input
                id="athlete-categories"
                placeholder="Enter athlete categories managed"
                required
              />
            </div>

            <div className="space-y-2">
              <Label htmlFor="certificates">Certificates/Licenses</Label>
              <Textarea
                id="certificates"
                placeholder="List any relevant certificates or licenses your organization holds"
                className="min-h-[80px]"
              />
            </div>

            <div className="space-y-2">
              <Label htmlFor="address">Address</Label>
              <Textarea id="address" placeholder="Enter your organization's address" className="min-h-[80px]" />
            </div>

            <div className="grid md:grid-cols-2 gap-4">
              <div className="space-y-2">
                <Label htmlFor="country">Country</Label>
                <Popover>
                  <PopoverTrigger asChild>
                    <Button
                      variant="outline"
                      role="combobox"
                      aria-expanded={true}
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
            <Button type="submit" className="w-full sm:w-auto">
              Sign Up
            </Button>
          </CardFooter>
        </form>
      </Card>

      {/* Sign-In Dialog */}
      <Dialog open={isSignInDialogOpen} onOpenChange={setIsSignInDialogOpen}>
        <DialogContent className="p-4 sm:p-5 max-w-lg rounded-2xl bg-white shadow-lg border border-gray-200 transform transition-all scale-95">
          <DialogHeader>
            <DialogTitle className="text-lg sm:text-xl font-bold text-center text-gray-900">
              Admin Sign In
            </DialogTitle>
            <DialogDescription className="text-gray-600 text-center text-xs sm:text-sm">
              Enter your admin email and password to sign in.
            </DialogDescription>
          </DialogHeader>
          <div className="space-y-4">
            <Input
              type="email"
              placeholder="Admin Email"
              className="p-2 w-full bg-gray-200 rounded-md outline-none focus:ring-2 focus:ring-blue-500"
              value={email}
              onChange={(e) => setEmail(e.target.value)}
            />
            <Input
              type="password"
              placeholder="Password"
              className="p-2 w-full bg-gray-200 rounded-md outline-none focus:ring-2 focus:ring-blue-500"
              value={password}
              onChange={(e) => setPassword(e.target.value)}
            />
          </div>
          <div className="mt-4 flex justify-center">
            <Button onClick={handleSignIn} className="w-full sm:w-auto">
              Sign In
            </Button>
          </div>
        </DialogContent>
      </Dialog>
    </div>
  )
}

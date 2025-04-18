import React, { useState, useEffect } from "react";
import axios from "axios";
import { Card, CardHeader, CardTitle, CardContent } from "@/components/ui/card";
import {
  Select,
  SelectTrigger,
  SelectValue,
  SelectContent,
  SelectItem,
} from "@/components/ui/select";
import { Button } from "@/components/ui/button";
import { Tabs, TabsList, TabsTrigger, TabsContent } from "@/components/ui/tabs";
import {
  Dialog,
  DialogTrigger,
  DialogContent,
  DialogTitle,
  DialogDescription,
  DialogFooter,
  DialogHeader,
} from "@/components/ui/dialog";
import { Input } from "@/components/ui/input";
import { Textarea } from "@/components/ui/textarea";
import { Badge } from "@/components/ui/badge";
import { Avatar, AvatarImage, AvatarFallback } from "@/components/ui/avatar";
import { Loader, AlertCircle, X, Check, Search } from "lucide-react";
import { Alert, AlertDescription } from "@/components/ui/alert";
// import { Pagination } from "@/components/ui/pagination";

// Performance badge color mapping
const performanceColors = {
  Platinum: "bg-purple-100 text-purple-800 border-purple-200",
  Gold: "bg-amber-100 text-amber-800 border-amber-200",
  Silver: "bg-gray-100 text-gray-800 border-gray-200",
  Bronze: "bg-orange-100 text-orange-800 border-orange-200",
  High: "bg-green-100 text-green-800 border-green-200",
  Medium: "bg-blue-100 text-blue-800 border-blue-200",
  Low: "bg-red-100 text-red-800 border-red-200",
};

// Sport badge colors
const sportColors = {
  Cricket: "bg-green-100 text-green-800",
  Football: "bg-blue-100 text-blue-800",
  Basketball: "bg-orange-100 text-orange-800",
  Tennis: "bg-yellow-100 text-yellow-800",
  Hockey: "bg-red-100 text-red-800",
  Swimming: "bg-cyan-100 text-cyan-800",
  Athletics: "bg-purple-100 text-purple-800",
  Badminton: "bg-indigo-100 text-indigo-800",
  "Table Tennis": "bg-pink-100 text-pink-800",
  Volleyball: "bg-teal-100 text-teal-800",
};

// Generate avatar fallback initials from name
const getInitials = (name) => {
  if (!name) return "?"; // Return a question mark or any default for missing names

  return name
    .split(" ")
    .map((word) => word[0])
    .join("")
    .toUpperCase();
};

const SponsorManagement = () => {
  // State for sponsors data
  const [sponsors, setSponsors] = useState([]);
  const [potentialSponsors, setPotentialSponsors] = useState([]);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState(null);

  // State for pagination
  const [pagination, setPagination] = useState({
    currentPage: 1,
    totalPages: 1,
    totalSponsors: 0,
    limit: 10,
  });

  // State for filters
  const [selectedSport, setSelectedSport] = useState("All");
  const [tab, setTab] = useState("all");
  const [search, setSearch] = useState("");
  const [searchInput, setSearchInput] = useState("");

  // Dialog state
  const [selectedSponsor, setSelectedSponsor] = useState(null);
  const [showContactDialog, setShowContactDialog] = useState(false);
  const [subject, setSubject] = useState("");
  const [message, setMessage] = useState("");

  // Action states
  const [actionLoading, setActionLoading] = useState(false);
  const [actionError, setActionError] = useState(null);
  const [actionSuccess, setActionSuccess] = useState(null);

  // List of sports for filtering
  const [sportsList, setSportsList] = useState([
    "All",
    "Cricket",
    "Football",
    "Basketball",
    "Tennis",
    "Hockey",
    "Swimming",
    "Athletics",
    "Badminton",
    "Table Tennis",
    "Volleyball",
  ]);

  // Fetch sponsors on component mount and when filters change
  useEffect(() => {
    fetchSponsors();
  }, [tab, selectedSport, search, pagination.currentPage, pagination.limit]);

  // Update fetchSponsors to transform the data
  const fetchSponsors = async () => {
    setLoading(true);
    setError(null);

    try {
      // Status and params setup remains the same
      const status =
        tab === "current" ? "active" : tab === "potential" ? "potential" : "";

      const params = {
        page: pagination.currentPage,
        limit: pagination.limit,
        sort: "companyName",
        order: "asc",
        status,
        search,
      };

      const response = await axios.get(
        "http://localhost:8000/api/v1/admins/sponsors",
        {
          params,
          headers: {
            Authorization: `Bearer ${localStorage.getItem("token")}`,
          },
          withCredentials: true,
        }
      );

      console.log("API Response:", response.data);

      if (response.data && response.data.data) {
        // Transform the sponsor data to ensure all expected fields exist
        const transformedSponsors = (response.data.data.sponsors || []).map(
          (sponsor) => ({
            _id: sponsor._id,
            companyName:
              sponsor.companyName || `Sponsor ${sponsor._id.slice(-5)}`, // Create a default name if missing
            email: sponsor.email || "No email available",
            logo: sponsor.logo || null,
            contactPerson: sponsor.contactPerson || "Not specified",
            phone: sponsor.phone || "Not available",
            industry: sponsor.industry || "Unspecified",
            interestLevel: sponsor.interestLevel || "Medium",
            address: sponsor.address || "Not provided",
            sponsorshipAmount: sponsor.sponsorshipAmount || null,
            sponsorshipStartDate: sponsor.sponsorshipStartDate || null,
            notes: sponsor.notes || null,
            isCurrentSponsor:
              sponsor.isCurrentSponsor ||
              (sponsor.sponsoredOrganizations &&
                sponsor.sponsoredOrganizations.length > 0),
          })
        );

        setSponsors(transformedSponsors);
        setPagination({
          currentPage: response.data.data.pagination.currentPage,
          totalPages: response.data.data.pagination.totalPages,
          totalSponsors: response.data.data.pagination.totalSponsors,
          limit: response.data.data.pagination.limit,
        });
      }
    } catch (err) {
      console.error("Error fetching sponsors:", err);
      setError(err.response?.data?.message || "Failed to load sponsors");
    } finally {
      setLoading(false);
    }
  };

  // Function to handle search
  const handleSearch = (e) => {
    e.preventDefault();
    setSearch(searchInput);
    setPagination((prev) => ({ ...prev, currentPage: 1 })); // Reset to first page on new search
  };

  // Function to handle sport filter change
  const handleSportChange = (sport) => {
    setSelectedSport(sport);
    setPagination((prev) => ({ ...prev, currentPage: 1 })); // Reset to first page on filter change
  };

  // Function to handle tab change
  const handleTabChange = (value) => {
    setTab(value);
    setPagination((prev) => ({ ...prev, currentPage: 1 })); // Reset to first page on tab change
  };

  // Function to handle page change
  const handlePageChange = (page) => {
    setPagination((prev) => ({ ...prev, currentPage: page }));
  };

  // Function to add sponsor to potential list
  const handleAddToPotential = async (sponsor) => {
    setActionLoading(true);
    setActionError(null);
    setActionSuccess(null);

    try {
      // API call to add sponsor to potential list
      await axios.post(
        `http://localhost:8000/api/v1/admins/sponsors/${sponsor._id}/potential`,
        {},
        {
          headers: {
            Authorization: `Bearer ${localStorage.getItem("token")}`,
          },
          withCredentials: true,
        }
      );

      // Update local state
      setActionSuccess(`${sponsor.companyName} added to potential sponsors`);
      fetchSponsors(); // Refresh data
    } catch (err) {
      console.error("Error adding to potential sponsors:", err);
      setActionError(
        err.response?.data?.message || "Failed to add to potential sponsors"
      );
    } finally {
      setActionLoading(false);
      setSelectedSponsor(null);
    }
  };

  // Function to add as active sponsor
  const handleAddAsSponsor = async (sponsor) => {
    setActionLoading(true);
    setActionError(null);
    setActionSuccess(null);

    try {
      // API call to add as active sponsor
      await axios.post(
        `http://localhost:8000/api/v1/admins/sponsors/${sponsor._id}/activate`,
        {},
        {
          headers: {
            Authorization: `Bearer ${localStorage.getItem("token")}`,
          },
          withCredentials: true,
        }
      );

      // Update local state
      setActionSuccess(`${sponsor.companyName} added as active sponsor`);
      fetchSponsors(); // Refresh data
    } catch (err) {
      console.error("Error adding as sponsor:", err);
      setActionError(err.response?.data?.message || "Failed to add as sponsor");
    } finally {
      setActionLoading(false);
      setSelectedSponsor(null);
    }
  };

  // Function to remove from potential sponsors
  const handleRemoveFromPotential = async (sponsor) => {
    setActionLoading(true);
    setActionError(null);
    setActionSuccess(null);

    try {
      // API call to remove from potential
      await axios.delete(
        `http://localhost:8000/api/v1/admins/sponsors/${sponsor._id}/potential`,
        {
          headers: {
            Authorization: `Bearer ${localStorage.getItem("token")}`,
          },
          withCredentials: true,
        }
      );

      // Update local state
      setActionSuccess(
        `${sponsor.companyName} removed from potential sponsors`
      );
      fetchSponsors(); // Refresh data
    } catch (err) {
      console.error("Error removing potential sponsor:", err);
      setActionError(
        err.response?.data?.message || "Failed to remove potential sponsor"
      );
    } finally {
      setActionLoading(false);
      setSelectedSponsor(null);
    }
  };

  // Function to send message to sponsor
  const handleSendMessage = async () => {
    setActionLoading(true);
    setActionError(null);
    setActionSuccess(null);

    if (!subject || !message) {
      setActionError("Subject and message are required");
      setActionLoading(false);
      return;
    }

    try {
      // API call to send message
      await axios.post(
        `http://localhost:8000/api/v1/admins/sponsors/${selectedSponsor._id}/contact`,
        {
          subject,
          message,
        },
        {
          headers: {
            Authorization: `Bearer ${localStorage.getItem("token")}`,
          },
          withCredentials: true,
        }
      );

      // Update local state
      setActionSuccess(`Message sent to ${selectedSponsor.companyName}`);
      setShowContactDialog(false);
      setSubject("");
      setMessage("");
    } catch (err) {
      console.error("Error sending message:", err);
      setActionError(err.response?.data?.message || "Failed to send message");
    } finally {
      setActionLoading(false);
    }
  };

  return (
    <div className="p-6 space-y-6">
      <h1 className="text-2xl font-bold">Sponsorship Management</h1>

      {/* Display errors if any */}
      {error && (
        <Alert variant="destructive">
          <AlertCircle className="h-4 w-4" />
          <AlertDescription>{error}</AlertDescription>
        </Alert>
      )}

      {/* Display action success/error messages */}
      {actionSuccess && (
        <Alert
          variant="success"
          className="bg-green-50 text-green-800 border-green-200"
        >
          <Check className="h-4 w-4" />
          <AlertDescription>{actionSuccess}</AlertDescription>
          <Button
            variant="ghost"
            size="sm"
            className="ml-auto"
            onClick={() => setActionSuccess(null)}
          >
            <X className="h-4 w-4" />
          </Button>
        </Alert>
      )}

      {actionError && (
        <Alert variant="destructive">
          <AlertCircle className="h-4 w-4" />
          <AlertDescription>{actionError}</AlertDescription>
          <Button
            variant="ghost"
            size="sm"
            className="ml-auto"
            onClick={() => setActionError(null)}
          >
            <X className="h-4 w-4" />
          </Button>
        </Alert>
      )}

      {/* Tabs */}
      <Tabs value={tab} onValueChange={handleTabChange} className="w-full">
        <TabsList className="mb-4 grid w-full grid-cols-3">
          <TabsTrigger value="current">Current</TabsTrigger>
          <TabsTrigger value="potential">Potential</TabsTrigger>
          <TabsTrigger value="all">All</TabsTrigger>
        </TabsList>
      </Tabs>

      {/* Search and Filter Toolbar */}
      <div className="flex flex-col sm:flex-row gap-4 items-start">
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

        {/* Search form */}
        <form onSubmit={handleSearch} className="flex w-full md:w-auto flex-1">
          <div className="relative w-full">
            <Input
              type="text"
              placeholder="Search sponsors..."
              value={searchInput}
              onChange={(e) => setSearchInput(e.target.value)}
              className="pr-10 w-full"
            />
            <Button
              type="submit"
              variant="ghost"
              size="sm"
              className="absolute right-0 top-0 h-full"
            >
              <Search className="h-4 w-4" />
            </Button>
          </div>
        </form>
      </div>

      {/* Loading state */}
      {loading ? (
        <div className="flex justify-center items-center py-12">
          <Loader className="h-8 w-8 animate-spin text-blue-600" />
          <span className="ml-3 text-gray-600">Loading sponsors...</span>
        </div>
      ) : sponsors.length === 0 ? (
        <div className="text-center py-12 text-gray-500">
          No sponsors found. Try adjusting your filters.
        </div>
      ) : (
        <>
          {/* Sponsor List */}
          <div className="grid grid-cols-1 md:grid-cols-2 gap-6">
            {sponsors.map((sponsor) => (
              <Card
                key={sponsor._id}
                className="relative hover:shadow-md transition-shadow"
              >
                {/* Current/Potential Badge */}
                <Badge
                  className={`absolute top-2 right-2 ${
                    sponsor.isCurrentSponsor
                      ? "bg-green-100 text-green-800"
                      : "bg-blue-100 text-blue-800"
                  }`}
                >
                  {sponsor.isCurrentSponsor ? "Current" : "Potential"}
                </Badge>

                <CardHeader className="flex flex-row items-center gap-4">
                  <Avatar className="h-12 w-12">
                    {sponsor.logo ? (
                      <AvatarImage
                        src={sponsor.logo}
                        alt={sponsor.companyName}
                      />
                    ) : (
                      <AvatarFallback className="bg-blue-100 text-blue-800">
                        {sponsor?.companyName
                          ? getInitials(sponsor.companyName)
                          : sponsor?.email
                          ? sponsor.email.charAt(0).toUpperCase()
                          : "?"}
                      </AvatarFallback>
                    )}
                  </Avatar>
                  <CardTitle>
                    {sponsor.companyName || `Sponsor (${sponsor.email})`}
                  </CardTitle>
                </CardHeader>
                <CardContent>
                  <p className="flex items-center gap-2 text-sm text-gray-600">
                    <span className="text-blue-600">📧</span> {sponsor.email}
                  </p>
                  <p className="flex items-center gap-2 text-sm text-gray-600 mt-1">
                    <span className="text-green-600">🏆</span>{" "}
                    {sponsor.industry || "Various Industries"}
                  </p>

                  {/* Interest Level */}
                  {sponsor.interestLevel && (
                    <div className="mt-2">
                      <Badge
                        className={
                          performanceColors[sponsor.interestLevel] ||
                          "bg-gray-100 text-gray-800"
                        }
                      >
                        {sponsor.interestLevel} Interest
                      </Badge>
                    </div>
                  )}

                  <Dialog>
                    <DialogTrigger asChild>
                      <Button
                        className="mt-4"
                        variant="outline"
                        onClick={() => setSelectedSponsor(sponsor)}
                      >
                        View Details
                      </Button>
                    </DialogTrigger>
                    {selectedSponsor?._id === sponsor._id && (
                      <DialogContent className="sm:max-w-3xl w-11/12">
                        <DialogHeader className="flex sm:flex-row justify-between items-start">
                          <div className="flex items-center gap-4">
                            <Avatar className="h-16 w-16">
                              {sponsor.logo ? (
                                <AvatarImage
                                  src={sponsor.logo}
                                  alt={sponsor.companyName}
                                />
                              ) : (
                                <AvatarFallback className="text-lg bg-blue-100 text-blue-800">
                                  {sponsor?.companyName
                                    ? getInitials(sponsor.companyName)
                                    : "?"}
                                </AvatarFallback>
                              )}
                            </Avatar>
                            <div>
                              <DialogTitle className="text-2xl">
                                {sponsor.companyName ||
                                  `Sponsor (${sponsor.email})`}
                              </DialogTitle>
                              <DialogDescription className="mt-1">
                                {sponsor.industry
                                  ? `${sponsor.industry} Sponsor`
                                  : "Potential Sponsor"}
                              </DialogDescription>
                            </div>
                          </div>
                          <Badge
                            className={`mt-2 sm:mt-0 ${
                              sponsor.isCurrentSponsor
                                ? "bg-green-100 text-green-800"
                                : "bg-blue-100 text-blue-800"
                            }`}
                          >
                            {sponsor.isCurrentSponsor ? "Current" : "Potential"}
                          </Badge>
                        </DialogHeader>

                        <div className="grid grid-cols-1 md:grid-cols-2 gap-6 py-6">
                          <div className="space-y-4">
                            <h3 className="text-lg font-medium">
                              Contact Information
                            </h3>
                            <div className="space-y-3">
                              <div className="flex items-center gap-2">
                                <span className="text-gray-500 w-24">
                                  Contact:
                                </span>
                                <span className="font-medium">
                                  {sponsor.contactPerson || "Not specified"}
                                </span>
                              </div>
                              <div className="flex items-center gap-2">
                                <span className="text-gray-500 w-24">
                                  Email:
                                </span>
                                <span className="font-medium">
                                  {sponsor.email}
                                </span>
                              </div>
                              <div className="flex items-center gap-2">
                                <span className="text-gray-500 w-24">
                                  Phone:
                                </span>
                                <span className="font-medium">
                                  {sponsor.phone || "Not specified"}
                                </span>
                              </div>
                              <div className="flex items-start gap-2">
                                <span className="text-gray-500 w-24">
                                  Address:
                                </span>
                                <span className="font-medium">
                                  {sponsor.address || "Not specified"}
                                </span>
                              </div>
                            </div>
                          </div>

                          <div className="space-y-4">
                            <h3 className="text-lg font-medium">
                              Sponsorship Details
                            </h3>
                            <div className="space-y-3">
                              <div className="flex items-center gap-2">
                                <span className="text-gray-500 w-24">
                                  Industry:
                                </span>
                                <span className="font-medium">
                                  {sponsor.industry || "Not specified"}
                                </span>
                              </div>
                              <div className="flex items-center gap-2">
                                <span className="text-gray-500 w-24">
                                  Interest:
                                </span>
                                <span className="font-medium">
                                  {sponsor.interestLevel || "Medium"}
                                </span>
                              </div>
                              {sponsor.sponsorshipAmount && (
                                <div className="flex items-center gap-2">
                                  <span className="text-gray-500 w-24">
                                    Contribution:
                                  </span>
                                  <span className="font-medium">
                                    ₹{sponsor.sponsorshipAmount}
                                  </span>
                                </div>
                              )}
                              {sponsor.sponsorshipStartDate && (
                                <div className="flex items-center gap-2">
                                  <span className="text-gray-500 w-24">
                                    Since:
                                  </span>
                                  <span className="font-medium">
                                    {new Date(
                                      sponsor.sponsorshipStartDate
                                    ).toLocaleDateString()}
                                  </span>
                                </div>
                              )}
                            </div>
                          </div>
                        </div>

                        {sponsor.notes && (
                          <div className="py-4">
                            <h3 className="text-lg font-medium mb-4">Notes</h3>
                            <div className="bg-gray-50 p-4 rounded-md">
                              <p className="text-gray-600">{sponsor.notes}</p>
                            </div>
                          </div>
                        )}

                        <DialogFooter className="flex sm:justify-between flex-col sm:flex-row gap-4 items-center">
                          <div className="flex gap-2">
                            {/* Show correct action buttons based on sponsor status */}
                            {!sponsor.isCurrentSponsor &&
                              tab !== "potential" && (
                                <Button
                                  onClick={() => handleAddToPotential(sponsor)}
                                  disabled={actionLoading}
                                >
                                  {actionLoading ? (
                                    <Loader className="h-4 w-4 animate-spin mr-2" />
                                  ) : null}
                                  Add to Potential
                                </Button>
                              )}

                            {!sponsor.isCurrentSponsor &&
                              (tab === "potential" ||
                                sponsor.potentialSponsor) && (
                                <>
                                  <Button
                                    onClick={() => handleAddAsSponsor(sponsor)}
                                    disabled={actionLoading}
                                  >
                                    {actionLoading ? (
                                      <Loader className="h-4 w-4 animate-spin mr-2" />
                                    ) : null}
                                    Add as Sponsor
                                  </Button>
                                  <Button
                                    variant="outline"
                                    onClick={() =>
                                      handleRemoveFromPotential(sponsor)
                                    }
                                    disabled={actionLoading}
                                  >
                                    {actionLoading ? (
                                      <Loader className="h-4 w-4 animate-spin mr-2" />
                                    ) : null}
                                    Remove
                                  </Button>
                                </>
                              )}
                          </div>

                          <div className="flex gap-2">
                            <Button
                              variant="outline"
                              onClick={() => {
                                setSelectedSponsor(sponsor);
                                setShowContactDialog(true);
                              }}
                            >
                              Contact
                            </Button>
                            <Button
                              variant="outline"
                              onClick={() => setSelectedSponsor(null)}
                            >
                              Close
                            </Button>
                          </div>
                        </DialogFooter>
                      </DialogContent>
                    )}
                  </Dialog>

                  {/* Contact Dialog */}
                  {showContactDialog &&
                    selectedSponsor?._id === sponsor._id && (
                      <Dialog
                        open={showContactDialog}
                        onOpenChange={setShowContactDialog}
                      >
                        <DialogContent className="sm:max-w-2xl w-11/12">
                          <DialogHeader>
                            <div className="flex items-center gap-4">
                              <Avatar className="h-12 w-12">
                                {sponsor.logo ? (
                                  <AvatarImage
                                    src={sponsor.logo}
                                    alt={sponsor.companyName}
                                  />
                                ) : (
                                  <AvatarFallback className="bg-blue-100 text-blue-800">
                                    {getInitials(selectedSponsor.companyName)}
                                  </AvatarFallback>
                                )}
                              </Avatar>
                              <div>
                                <DialogTitle className="text-xl">
                                  Contact {selectedSponsor.companyName}
                                </DialogTitle>
                                <DialogDescription>
                                  Send a message directly to the sponsor
                                  representative
                                </DialogDescription>
                              </div>
                            </div>
                          </DialogHeader>

                          <div className="space-y-4 py-4">
                            <div className="flex items-center">
                              <span className="font-medium text-gray-500 w-16">
                                To:
                              </span>
                              <span className="text-gray-900">
                                {selectedSponsor.email}
                              </span>
                            </div>

                            <div className="space-y-2">
                              <label
                                className="text-sm font-medium text-gray-500"
                                htmlFor="subject"
                              >
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
                              <label
                                className="text-sm font-medium text-gray-500"
                                htmlFor="message"
                              >
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
                            <Button
                              variant="outline"
                              onClick={() => setShowContactDialog(false)}
                              disabled={actionLoading}
                            >
                              Cancel
                            </Button>
                            <Button
                              onClick={handleSendMessage}
                              disabled={actionLoading}
                            >
                              {actionLoading ? (
                                <Loader className="h-4 w-4 animate-spin mr-2" />
                              ) : null}
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

          {/* Pagination Controls */}
          {pagination.totalPages > 1 && (
            <div className="flex justify-center mt-6">
              <div className="flex items-center gap-2">
                <Button
                  variant="outline"
                  size="sm"
                  onClick={() => handlePageChange(pagination.currentPage - 1)}
                  disabled={pagination.currentPage === 1}
                >
                  Previous
                </Button>

                <span className="text-sm text-gray-600">
                  Page {pagination.currentPage} of {pagination.totalPages}
                </span>

                <Button
                  variant="outline"
                  size="sm"
                  onClick={() => handlePageChange(pagination.currentPage + 1)}
                  disabled={pagination.currentPage === pagination.totalPages}
                >
                  Next
                </Button>
              </div>
            </div>
          )}
        </>
      )}
    </div>
  );
};

export default SponsorManagement;

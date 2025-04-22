import { useState, useEffect } from "react";
import { Card, CardContent, CardHeader, CardTitle, CardDescription } from "@/components/ui/card";
import { Button } from "@/components/ui/button";
import { Input } from "@/components/ui/input";
import { Textarea } from "@/components/ui/textarea";
import { Label } from "@/components/ui/label";
import { Select, SelectContent, SelectItem, SelectTrigger, SelectValue } from "@/components/ui/select";
import { Badge } from "@/components/ui/badge";
import { Dialog, DialogContent, DialogDescription, DialogFooter, DialogHeader, DialogTitle } from "@/components/ui/dialog";
import { ScrollArea } from "@/components/ui/scroll-area";
import { MoreHorizontal, Edit, Trash2, PlusCircle, CheckCircle, Search, Shield } from "lucide-react";
import { DropdownMenu, DropdownMenuContent, DropdownMenuItem, DropdownMenuTrigger } from "@/components/ui/dropdown-menu";
import axios from "axios";
import { toast, ToastContainer } from "react-toastify";
import "react-toastify/dist/ReactToastify.css";

// Create an axios instance with the base URL and request interceptor for auth
const api = axios.create({
  baseURL: "http://localhost:8000/api/v1",
});

// Add auth token to requests
api.interceptors.request.use(
  (config) => {
    config.withCredentials = true;
    const token = sessionStorage.getItem("coachAccessToken");
    if (token) {
      config.headers.Authorization = `Bearer ${token}`;
    }
    return config;
  },
  (error) => {
    return Promise.reject(error);
  }
);

const Communication = () => {
  // Announcements state
  const [announcements, setAnnouncements] = useState([]);
  const [loading, setLoading] = useState(false);
  const [error, setError] = useState(null);
  const [currentPage, setCurrentPage] = useState(1);
  const [totalPages, setTotalPages] = useState(1);
  const [isCreating, setIsCreating] = useState(false);
  const [isEditing, setIsEditing] = useState(false);
  const [currentAnnouncement, setCurrentAnnouncement] = useState(null);
  const [searchQuery, setSearchQuery] = useState("");
  const [viewMode, setViewMode] = useState("all"); // "all", "mine", "team"
  
  // Form state for new/edit announcement
  const [formData, setFormData] = useState({
    title: "",
    content: "",
    sports: []
  });
  
  // Fixed sportsList - let backend handle the matching
  const sportsList = ["Cricket", "Football", "Badminton", "Basketball", "Tennis", "Hockey", "Other"];
  
  // Fetch announcements when filters change
  useEffect(() => {
    fetchAnnouncements();
  }, [currentPage, viewMode, searchQuery]);

  // API Functions for Announcements
  const fetchAnnouncements = async () => {
    try {
      setLoading(true);
      
      let endpoint;
      
      // Different endpoints based on view mode
      if (viewMode === "mine") {
        endpoint = "/announcements/coach/me";
      } else if (viewMode === "team" || viewMode === "all") {
        endpoint = "/announcements/coach-get-announcements/sports"; // Use the correct endpoint path
      }
      
      let queryParams = new URLSearchParams({
        page: currentPage,
        limit: 10
      });
      
      if (searchQuery) {
        queryParams.append("search", searchQuery);
      }
      
      const response = await api.get(`${endpoint}?${queryParams}`);
      
      if (response.data?.data) {
        let returnedAnnouncements = response.data.data.announcements || [];
        
        // For team view, filter out own announcements
        if (viewMode === "team") {
          returnedAnnouncements = returnedAnnouncements.filter(
            announcement => !announcement.isOwnAnnouncement
          );
        }
        
        setAnnouncements(returnedAnnouncements);
        setTotalPages(response.data.data.pagination.totalPages || 1);
      }
      
      setError(null);
    } catch (err) {
      console.error("Failed to fetch announcements:", err);
      setError(err.response?.data?.message || "Failed to load announcements");
      toast.error("Failed to load announcements");
    } finally {
      setLoading(false);
    }
  };

  const createAnnouncement = async () => {
    try {
      if (!formData.title || !formData.content) {
        toast.error("Title and content are required");
        return;
      }
      
      setLoading(true);
      const response = await api.post("/announcements/make-announcement", formData);
      
      if (response.data?.data) {
        toast.success("Announcement created successfully");
        setIsCreating(false);
        resetForm();
        
        // Refresh the list to include the new announcement
        fetchAnnouncements();
      }
    } catch (err) {
      console.error("Failed to create announcement:", err);
      toast.error(err.response?.data?.message || "Failed to create announcement");
    } finally {
      setLoading(false);
    }
  };

  const updateAnnouncement = async () => {
    try {
      if (!formData.title || !formData.content) {
        toast.error("Title and content are required");
        return;
      }
      
      // Verify ownership before attempting update
      if (!currentAnnouncement || !isMyAnnouncement(currentAnnouncement)) {
        toast.error("You can only edit your own announcements");
        setIsEditing(false);
        return;
      }
      
      setLoading(true);
      const response = await api.patch(`/announcements/${currentAnnouncement._id}`, formData);
      
      if (response.data?.data) {
        // Update the announcement in state
        setAnnouncements(prev => 
          prev.map(ann => ann._id === currentAnnouncement._id ? response.data.data : ann)
        );
        toast.success("Announcement updated successfully");
        setIsEditing(false);
        resetForm();
      }
    } catch (err) {
      console.error("Failed to update announcement:", err);
      toast.error(err.response?.data?.message || "Failed to update announcement");
    } finally {
      setLoading(false);
    }
  };
  
  // Update the deleteAnnouncement function to include ownership verification
  const deleteAnnouncement = async (id) => {
    try {
      // Find the announcement to verify ownership
      const announcementToDelete = announcements.find(a => a._id === id);
      
      if (!announcementToDelete || !isMyAnnouncement(announcementToDelete)) {
        toast.error("You can only delete your own announcements");
        return;
      }
      
      setLoading(true);
      await api.delete(`/announcements/${id}`);
      
      // Remove the announcement from state
      setAnnouncements(prev => prev.filter(ann => ann._id !== id));
      toast.success("Announcement deleted successfully");
    } catch (err) {
      console.error("Failed to delete announcement:", err);
      toast.error(err.response?.data?.message || "Failed to delete announcement");
    } finally {
      setLoading(false);
    }
  };

  // Helper functions
  const resetForm = () => {
    setFormData({
      title: "",
      content: "",
      sports: []
    });
    setCurrentAnnouncement(null);
  };

  const handleEditClick = (announcement) => {
    setCurrentAnnouncement(announcement);
    setFormData({
      title: announcement.title,
      content: announcement.content,
      sports: announcement.sports || []
    });
    setIsEditing(true);
  };

  const toggleSportSelection = (sport) => {
    if (formData.sports.includes(sport)) {
      setFormData({
        ...formData,
        sports: formData.sports.filter(s => s !== sport)
      });
    } else {
      setFormData({
        ...formData,
        sports: [...formData.sports, sport]
      });
    }
  };

  // Format date for display
  const formatDate = (dateString) => {
    const options = { year: 'numeric', month: 'short', day: 'numeric' };
    return new Date(dateString).toLocaleDateString(undefined, options);
  };

  // Check if the current coach is the author of an announcement
  const isMyAnnouncement = (announcement) => {
    // Primary check - backend should send this flag
    if (announcement.isOwnAnnouncement === true) {
      return true;
    }
    
    // Fallback check - compare createddBy ID with the logged-in user
    // Get coach data from sessionStorage
    const userData = JSON.parse(sessionStorage.getItem("userData") || "{}");
    const coachId = userData._id;
    
    return announcement.createddBy && 
      (announcement.createddBy._id === coachId || 
       announcement.createddBy._id?.toString() === coachId);
  };

  // Handle search input changes
  const handleSearchChange = (e) => {
    setSearchQuery(e.target.value);
    setCurrentPage(1); // Reset to first page when search changes
  };

  // Handle view mode changes
  const handleViewModeChange = (value) => {
    setViewMode(value);
    setCurrentPage(1); // Reset to first page when view changes
  };

  return (
    <div className="space-y-6">
      <ToastContainer position="top-right" autoClose={3000} />
      
      <Card>
        <CardHeader>
          <CardTitle className="flex items-center justify-between">
            <span>Team Announcements</span>
            <Button onClick={() => setIsCreating(true)} className="flex items-center gap-1">
              <PlusCircle size={18} /> New Announcement
            </Button>
          </CardTitle>
          <CardDescription>
            Create and view announcements for your team based on sports
          </CardDescription>
        </CardHeader>
        
        <CardContent>
          {/* Search and Filter Controls */}
          <div className="flex flex-col sm:flex-row gap-4 mb-6">
            <div className="relative flex-1">
              <Search className="absolute left-3 top-1/2 transform -translate-y-1/2 text-gray-400" size={18} />
              <Input 
                placeholder="Search announcements..." 
                value={searchQuery}
                onChange={handleSearchChange}
                className="pl-10"
              />
            </div>
            
            <Select value={viewMode} onValueChange={handleViewModeChange}>
              <SelectTrigger className="w-[200px]">
                <SelectValue placeholder="View" />
              </SelectTrigger>
              <SelectContent>
                <SelectItem value="all">All Related Sports Announcements</SelectItem>
                <SelectItem value="mine">My Announcements</SelectItem>
                <SelectItem value="team">Team Sports Announcements</SelectItem>
              </SelectContent>
            </Select>
          </div>
          
          {/* Announcements List */}
          {loading && <div className="text-center py-8">Loading announcements...</div>}
          
          {error && <div className="text-red-500 text-center py-4">{error}</div>}
          
          {!loading && announcements.length === 0 && (
            <div className="text-center py-8 text-gray-500">
              {viewMode === "mine" 
                ? "You haven't created any announcements yet" 
                : viewMode === "team" 
                  ? "No announcements from coaches in your sports" 
                  : "No announcements available for your sports"}
            </div>
          )}
          
          <ScrollArea className="h-[500px] pr-4">
            {announcements.map((announcement) => (
              <div key={announcement._id} className="mb-4 p-4 border rounded-lg hover:bg-gray-50 transition-colors">
                <div className="flex justify-between items-start mb-2">
                  <div>
                    <div className="flex items-center gap-2">
                      <h4 className="font-semibold text-lg">{announcement.title}</h4>
                      {isMyAnnouncement(announcement) && (
                        <Badge variant="outline" className="text-blue-500 border-blue-500">You</Badge>
                      )}
                    </div>
                    <p className="text-sm text-gray-500">
                      By {announcement.createddBy?.name || "Unknown"} • {formatDate(announcement.createdAt)}
                    </p>
                  </div>
                  
                  {/* Only show edit/delete options for my announcements */}
                  {isMyAnnouncement(announcement) && (
                    <DropdownMenu>
                      <DropdownMenuTrigger asChild>
                        <Button variant="ghost" size="icon">
                          <MoreHorizontal size={18} />
                        </Button>
                      </DropdownMenuTrigger>
                      <DropdownMenuContent align="end">
                        <DropdownMenuItem onClick={() => handleEditClick(announcement)}>
                          <Edit size={16} className="mr-2" /> Edit
                        </DropdownMenuItem>
                        <DropdownMenuItem 
                          className="text-red-500" 
                          onClick={() => deleteAnnouncement(announcement._id)}
                        >
                          <Trash2 size={16} className="mr-2" /> Delete
                        </DropdownMenuItem>
                      </DropdownMenuContent>
                    </DropdownMenu>
                  )}
                </div>
                
                <p className="mb-2">{announcement.content}</p>
                
                {announcement.sports && announcement.sports.length > 0 && (
                  <div className="flex flex-wrap gap-1 mt-2">
                    {announcement.sports.map((sport, idx) => (
                      <Badge key={idx} variant="default">
                        {sport}
                      </Badge>
                    ))}
                  </div>
                )}
              </div>
            ))}
          </ScrollArea>
          
          {/* Pagination */}
          {totalPages > 1 && (
            <div className="flex justify-center gap-2 mt-6">
              <Button 
                variant="outline" 
                size="sm" 
                onClick={() => setCurrentPage(prev => Math.max(prev - 1, 1))}
                disabled={currentPage === 1}
              >
                Previous
              </Button>
              <span className="flex items-center px-3">
                Page {currentPage} of {totalPages}
              </span>
              <Button 
                variant="outline" 
                size="sm" 
                onClick={() => setCurrentPage(prev => Math.min(prev + 1, totalPages))}
                disabled={currentPage === totalPages}
              >
                Next
              </Button>
            </div>
          )}
        </CardContent>
      </Card>
      
      {/* Create Announcement Dialog */}
      <Dialog open={isCreating} onOpenChange={setIsCreating}>
        <DialogContent className="sm:max-w-[525px]">
          <DialogHeader>
            <DialogTitle>Create New Announcement</DialogTitle>
            <DialogDescription>
              This announcement will be visible to coaches who share your selected sports.
            </DialogDescription>
          </DialogHeader>
          <div className="grid gap-4 py-4">
            <div className="grid w-full gap-2">
              <Label htmlFor="title">Title</Label>
              <Input 
                id="title" 
                placeholder="Enter announcement title" 
                value={formData.title}
                onChange={(e) => setFormData({...formData, title: e.target.value})}
              />
            </div>
            <div className="grid w-full gap-2">
              <Label htmlFor="content">Content</Label>
              <Textarea 
                id="content" 
                placeholder="Enter announcement details" 
                className="min-h-[120px]"
                value={formData.content}
                onChange={(e) => setFormData({...formData, content: e.target.value})}
              />
            </div>
            <div className="grid w-full gap-2">
              <Label>Select Sports (Optional)</Label>
              <div className="flex flex-wrap gap-2">
                {sportsList.map((sport) => (
                  <Badge 
                    key={sport}
                    variant={formData.sports.includes(sport) ? "default" : "outline"}
                    className="cursor-pointer"
                    onClick={() => toggleSportSelection(sport)}
                  >
                    {sport}
                    {formData.sports.includes(sport) && <CheckCircle className="ml-1" size={14} />}
                  </Badge>
                ))}
              </div>
            </div>
            
            {/* Visibility Information */}
            <div className="mt-2 p-3 bg-blue-50 border border-blue-100 rounded-md text-sm text-blue-700">
              <div className="flex items-start gap-2">
                <Shield size={18} className="mt-0.5" />
                <div>
                  <p className="font-medium">Announcement Visibility</p>
                  <p className="mt-1">Your announcement will be visible to:</p>
                  <ul className="list-disc pl-5 mt-1 space-y-1">
                    {formData.sports.length > 0 ? (
                      <>
                        <li>All coaches who work with {formData.sports.join(", ")}</li>
                        <li>Athletes in these sports will also see this announcement</li>
                      </>
                    ) : (
                      <li>All coaches and athletes if no sports are selected</li>
                    )}
                  </ul>
                </div>
              </div>
            </div>
          </div>
          <DialogFooter>
            <Button variant="outline" onClick={() => {setIsCreating(false); resetForm();}}>
              Cancel
            </Button>
            <Button type="submit" onClick={createAnnouncement} disabled={loading}>
              {loading ? "Creating..." : "Create Announcement"}
            </Button>
          </DialogFooter>
        </DialogContent>
      </Dialog>
      
      {/* Edit Announcement Dialog */}
      <Dialog open={isEditing} onOpenChange={setIsEditing}>
        <DialogContent className="sm:max-w-[525px]">
          <DialogHeader>
            <DialogTitle>Edit Announcement</DialogTitle>
            <DialogDescription>
              Update your announcement details. Changing sports will affect who can see this announcement.
            </DialogDescription>
          </DialogHeader>
          <div className="grid gap-4 py-4">
            <div className="grid w-full gap-2">
              <Label htmlFor="edit-title">Title</Label>
              <Input 
                id="edit-title" 
                placeholder="Enter announcement title" 
                value={formData.title}
                onChange={(e) => setFormData({...formData, title: e.target.value})}
              />
            </div>
            <div className="grid w-full gap-2">
              <Label htmlFor="edit-content">Content</Label>
              <Textarea 
                id="edit-content" 
                placeholder="Enter announcement details" 
                className="min-h-[120px]"
                value={formData.content}
                onChange={(e) => setFormData({...formData, content: e.target.value})}
              />
            </div>
            <div className="grid w-full gap-2">
              <Label>Select Sports (Optional)</Label>
              <div className="flex flex-wrap gap-2">
                {sportsList.map((sport) => (
                  <Badge 
                    key={sport}
                    variant={formData.sports.includes(sport) ? "default" : "outline"}
                    className="cursor-pointer"
                    onClick={() => toggleSportSelection(sport)}
                  >
                    {sport}
                    {formData.sports.includes(sport) && <CheckCircle className="ml-1" size={14} />}
                  </Badge>
                ))}
              </div>
            </div>
          </div>
          <DialogFooter>
            <Button variant="outline" onClick={() => {setIsEditing(false); resetForm();}}>
              Cancel
            </Button>
            <Button type="submit" onClick={updateAnnouncement} disabled={loading}>
              {loading ? "Updating..." : "Update Announcement"}
            </Button>
          </DialogFooter>
        </DialogContent>
      </Dialog>
    </div>
  );
};

export default Communication;
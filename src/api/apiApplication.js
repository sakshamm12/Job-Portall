import supabaseClient, { supabaseUrl } from "@/utils/supabase";

// Apply to job (candidate)
export async function applyToJob(token, _, jobData) {
  try {
    const supabase = await supabaseClient(token);

    // Validate input
    if (!jobData.resume || !jobData.candidate_id || !jobData.job_id) {
      throw new Error("Resume, candidate ID, and job ID are required");
    }

    // Generate unique filename for resume
    const timestamp = Date.now();
    const random = Math.floor(Math.random() * 90000);
    const fileExtension = jobData.resume.name.split('.').pop();
    const fileName = `resume-${timestamp}-${random}-${jobData.candidate_id}.${fileExtension}`;

    // Upload resume to storage
    const { data: uploadData, error: storageError } = await supabase.storage
      .from("resumes")
      .upload(fileName, jobData.resume, {
        cacheControl: '3600',
        upsert: false
      });

    if (storageError) {
      console.error("Storage error:", storageError);
      throw new Error(`Error uploading resume: ${storageError.message}`);
    }

    // Get public URL for the uploaded resume
    const { data: { publicUrl } } = supabase.storage
      .from("resumes")
      .getPublicUrl(fileName);

    // Insert application record
    const { data, error } = await supabase
      .from("applications")
      .insert([
        {
          job_id: jobData.job_id,
          candidate_id: jobData.candidate_id,
          name: jobData.name,
          experience: jobData.experience,
          skills: jobData.skills,
          education: jobData.education,
          resume: publicUrl,
          status: jobData.status || 'applied',
        },
      ])
      .select();

    if (error) {
      // If application insert fails, try to clean up the uploaded file
      try {
        await supabase.storage
          .from("resumes")
          .remove([fileName]);
      } catch (cleanupError) {
        console.warn("Failed to cleanup uploaded resume:", cleanupError);
      }
      
      console.error("Database error:", error);
      throw new Error(`Error submitting application: ${error.message}`);
    }

    return data;
  } catch (error) {
    console.error("Error in applyToJob:", error);
    throw error;
  }
}

// Edit Application Status (recruiter)
export async function updateApplicationStatus(token, { job_id }, status) {
  try {
    const supabase = await supabaseClient(token);
    
    const { data, error } = await supabase
      .from("applications")
      .update({ status })
      .eq("job_id", job_id)
      .select();

    if (error) {
      console.error("Error updating application status:", error);
      throw new Error(`Error updating application status: ${error.message}`);
    }

    if (data.length === 0) {
      throw new Error("No applications found to update");
    }

    return data;
  } catch (error) {
    console.error("Error in updateApplicationStatus:", error);
    throw error;
  }
}

// Get Applications for a user
export async function getApplications(token, { user_id }) {
  try {
    const supabase = await supabaseClient(token);
    
    const { data, error } = await supabase
      .from("applications")
      .select(`
        *,
        job:jobs(
          title,
          company:companies(name)
        )
      `)
      .eq("candidate_id", user_id)
      .order("created_at", { ascending: false });

    if (error) {
      console.error("Error fetching applications:", error);
      throw new Error(`Error fetching applications: ${error.message}`);
    }

    return data;
  } catch (error) {
    console.error("Error in getApplications:", error);
    throw error;
  }
}
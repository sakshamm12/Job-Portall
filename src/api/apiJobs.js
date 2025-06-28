import supabaseClient from "@/utils/supabase";

// Fetch Jobs
export async function getJobs(token, { location, company_id, searchQuery }) {
  try {
    const supabase = await supabaseClient(token);
    let query = supabase
      .from("jobs")
      .select(`
        *, 
        saved: saved_job(id), 
        company: companies(name, logo_url)
      `);

    if (location) {
      query = query.eq("location", location);
    }

    if (company_id) {
      query = query.eq("company_id", company_id);
    }

    if (searchQuery) {
      query = query.ilike("title", `%${searchQuery}%`);
    }

    const { data, error } = await query.order("created_at", { ascending: false });

    if (error) {
      console.error("Error fetching Jobs:", error);
      throw new Error(`Error fetching jobs: ${error.message}`);
    }

    return data;
  } catch (error) {
    console.error("Error in getJobs:", error);
    throw error;
  }
}

// Read Saved Jobs
export async function getSavedJobs(token) {
  try {
    const supabase = await supabaseClient(token);
    const { data, error } = await supabase
      .from("saved_job")
      .select(`
        *, 
        job: jobs(
          *, 
          company: companies(name, logo_url)
        )
      `)
      .order("created_at", { ascending: false });

    if (error) {
      console.error("Error fetching Saved Jobs:", error);
      throw new Error(`Error fetching saved jobs: ${error.message}`);
    }

    return data;
  } catch (error) {
    console.error("Error in getSavedJobs:", error);
    throw error;
  }
}

// Read single job
export async function getSingleJob(token, { job_id }) {
  try {
    const supabase = await supabaseClient(token);
    const { data, error } = await supabase
      .from("jobs")
      .select(`
        *, 
        company: companies(name, logo_url), 
        applications: applications(*)
      `)
      .eq("id", job_id)
      .single();

    if (error) {
      console.error("Error fetching Job:", error);
      throw new Error(`Error fetching job: ${error.message}`);
    }

    return data;
  } catch (error) {
    console.error("Error in getSingleJob:", error);
    throw error;
  }
}

// Add / Remove Saved Job
export async function saveJob(token, { alreadySaved }, saveData) {
  try {
    const supabase = await supabaseClient(token);

    if (alreadySaved) {
      // If the job is already saved, remove it
      const { data, error: deleteError } = await supabase
        .from("saved_job")
        .delete()
        .eq("job_id", saveData.job_id)
        .eq("user_id", saveData.user_id);

      if (deleteError) {
        console.error("Error removing saved job:", deleteError);
        throw new Error(`Error removing saved job: ${deleteError.message}`);
      }

      return data;
    } else {
      // If the job is not saved, add it to saved jobs
      const { data, error: insertError } = await supabase
        .from("saved_job")
        .insert([saveData])
        .select();

      if (insertError) {
        console.error("Error saving job:", insertError);
        throw new Error(`Error saving job: ${insertError.message}`);
      }

      return data;
    }
  } catch (error) {
    console.error("Error in saveJob:", error);
    throw error;
  }
}

// Job isOpen toggle (recruiter_id = auth.uid())
export async function updateHiringStatus(token, { job_id }, isOpen) {
  try {
    const supabase = await supabaseClient(token);
    const { data, error } = await supabase
      .from("jobs")
      .update({ isOpen })
      .eq("id", job_id)
      .select();

    if (error) {
      console.error("Error updating hiring status:", error);
      throw new Error(`Error updating hiring status: ${error.message}`);
    }

    return data;
  } catch (error) {
    console.error("Error in updateHiringStatus:", error);
    throw error;
  }
}

// Get my created jobs
export async function getMyJobs(token, { recruiter_id }) {
  try {
    const supabase = await supabaseClient(token);

    const { data, error } = await supabase
      .from("jobs")
      .select(`
        *, 
        company: companies(name, logo_url)
      `)
      .eq("recruiter_id", recruiter_id)
      .order("created_at", { ascending: false });

    if (error) {
      console.error("Error fetching Jobs:", error);
      throw new Error(`Error fetching your jobs: ${error.message}`);
    }

    return data;
  } catch (error) {
    console.error("Error in getMyJobs:", error);
    throw error;
  }
}

// Delete job
export async function deleteJob(token, { job_id }) {
  try {
    const supabase = await supabaseClient(token);

    const { data, error: deleteError } = await supabase
      .from("jobs")
      .delete()
      .eq("id", job_id)
      .select();

    if (deleteError) {
      console.error("Error deleting job:", deleteError);
      throw new Error(`Error deleting job: ${deleteError.message}`);
    }

    return data;
  } catch (error) {
    console.error("Error in deleteJob:", error);
    throw error;
  }
}

// Post job
export async function addNewJob(token, _, jobData) {
  try {
    const supabase = await supabaseClient(token);

    // Validate input
    if (!jobData.title || !jobData.description || !jobData.company_id) {
      throw new Error("Title, description, and company are required");
    }

    const { data, error } = await supabase
      .from("jobs")
      .insert([{
        title: jobData.title,
        description: jobData.description,
        location: jobData.location,
        company_id: parseInt(jobData.company_id),
        recruiter_id: jobData.recruiter_id,
        requirements: jobData.requirements,
        isOpen: jobData.isOpen !== undefined ? jobData.isOpen : true
      }])
      .select();

    if (error) {
      console.error("Error creating job:", error);
      throw new Error(`Error creating job: ${error.message}`);
    }

    return data;
  } catch (error) {
    console.error("Error in addNewJob:", error);
    throw error;
  }
}
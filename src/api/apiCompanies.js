import supabaseClient, { supabaseUrl } from "@/utils/supabase";

// Fetch Companies
export async function getCompanies(token) {
  try {
    const supabase = await supabaseClient(token);
    const { data, error } = await supabase
      .from("companies")
      .select("*")
      .order("created_at", { ascending: false });

    if (error) {
      console.error("Error fetching Companies:", error);
      throw new Error(`Failed to fetch companies: ${error.message}`);
    }

    return data;
  } catch (error) {
    console.error("Error in getCompanies:", error);
    throw error;
  }
}

// Add Company
export async function addNewCompany(token, _, companyData) {
  try {
    const supabase = await supabaseClient(token);

    // Validate input
    if (!companyData.name || !companyData.logo) {
      throw new Error("Company name and logo are required");
    }

    // Generate unique filename
    const timestamp = Date.now();
    const random = Math.floor(Math.random() * 90000);
    const fileExtension = companyData.logo.name.split('.').pop();
    const fileName = `logo-${timestamp}-${random}-${companyData.name.replace(/[^a-zA-Z0-9]/g, '_')}.${fileExtension}`;

    // Upload logo to storage
    const { data: uploadData, error: storageError } = await supabase.storage
      .from("company-logos")
      .upload(fileName, companyData.logo, {
        cacheControl: '3600',
        upsert: false
      });

    if (storageError) {
      console.error("Storage error:", storageError);
      throw new Error(`Error uploading company logo: ${storageError.message}`);
    }

    // Get public URL for the uploaded file
    const { data: { publicUrl } } = supabase.storage
      .from("company-logos")
      .getPublicUrl(fileName);

    // Insert company record
    const { data, error } = await supabase
      .from("companies")
      .insert([
        {
          name: companyData.name.trim(),
          logo_url: publicUrl,
        },
      ])
      .select();

    if (error) {
      // If company insert fails, try to clean up the uploaded file
      try {
        await supabase.storage
          .from("company-logos")
          .remove([fileName]);
      } catch (cleanupError) {
        console.warn("Failed to cleanup uploaded file:", cleanupError);
      }
      
      console.error("Database error:", error);
      throw new Error(`Error creating company: ${error.message}`);
    }

    return data;
  } catch (error) {
    console.error("Error in addNewCompany:", error);
    throw error;
  }
}
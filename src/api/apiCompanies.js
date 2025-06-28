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
      return null;
    }

    return data;
  } catch (error) {
    console.error("Error in getCompanies:", error);
    return null;
  }
}

// Add Company
export async function addNewCompany(token, _, companyData) {
  try {
    const supabase = await supabaseClient(token);

    // Generate unique filename
    const timestamp = Date.now();
    const random = Math.floor(Math.random() * 90000);
    const fileExtension = companyData.logo.name.split('.').pop();
    const fileName = `logo-${timestamp}-${random}-${companyData.name.replace(/[^a-zA-Z0-9]/g, '_')}.${fileExtension}`;

    // Upload logo to storage
    const { error: storageError } = await supabase.storage
      .from("company-logos")
      .upload(fileName, companyData.logo);

    if (storageError) {
      console.error("Storage error:", storageError);
      throw new Error("Error uploading Company Logo");
    }

    // Get public URL for the uploaded file
    const logo_url = `${supabaseUrl}/storage/v1/object/public/company-logos/${fileName}`;

    // Insert company record
    const { data, error } = await supabase
      .from("companies")
      .insert([
        {
          name: companyData.name,
          logo_url: logo_url,
        },
      ])
      .select();

    if (error) {
      console.error("Database error:", error);
      throw new Error("Error submitting Company");
    }

    return data;
  } catch (error) {
    console.error("Error in addNewCompany:", error);
    throw error;
  }
}
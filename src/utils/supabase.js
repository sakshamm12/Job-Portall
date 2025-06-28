import { createClient } from "@supabase/supabase-js";

export const supabaseUrl = import.meta.env.VITE_SUPABASE_URL;
const supabaseKey = import.meta.env.VITE_SUPABASE_ANON_KEY;

// Validate environment variables
if (!supabaseUrl || !supabaseKey) {
  console.error("Missing Supabase environment variables. Please check your .env file.");
}

const supabaseClient = async (supabaseAccessToken) => {
  try {
    const supabase = createClient(supabaseUrl, supabaseKey, {
      global: { 
        headers: { 
          Authorization: `Bearer ${supabaseAccessToken}` 
        } 
      }
    });
    
    return supabase;
  } catch (error) {
    console.error("Error creating Supabase client:", error);
    throw new Error("Failed to initialize Supabase client");
  }
};

export default supabaseClient;
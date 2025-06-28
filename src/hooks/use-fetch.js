import { useSession } from "@clerk/clerk-react";
import { useState } from "react";

const useFetch = (cb, options = {}) => {
  const [data, setData] = useState(undefined);
  const [loading, setLoading] = useState(null);
  const [error, setError] = useState(null);

  const { session } = useSession();

  const fn = async (...args) => {
    setLoading(true);
    setError(null);

    try {
      if (!session) {
        throw new Error("No active session found. Please sign in.");
      }

      const supabaseAccessToken = await session.getToken({
        template: "supabase",
      });

      if (!supabaseAccessToken) {
        throw new Error("Failed to get Supabase access token");
      }

      const response = await cb(supabaseAccessToken, options, ...args);
      setData(response);
      setError(null);
    } catch (error) {
      console.error("useFetch error:", error);
      setError(error);
      setData(null);
    } finally {
      setLoading(false);
    }
  };

  return { data, loading, error, fn };
};

export default useFetch;
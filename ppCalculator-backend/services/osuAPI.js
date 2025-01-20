const axios = require("axios");

const OSU_API_BASE_URL = "https://osu.ppy.sh/api/v2";

let accessToken = null;

async function authenticate() {
  try {
    const response = await axios.post("https://osu.ppy.sh/oauth/token", {
      grant_type: "client_credentials",
      client_id: process.env.CLIENT_ID,
      client_secret: process.env.CLIENT_SECRET,
      scope: "public",
    });

    accessToken = response.data.access_token;
  } catch (error) {
    console.error("Auth with osuAPI failed:", error.message);
    throw new Error("Authentication failed");
  }
}

async function searchBeatmaps(query) {
  if (!accessToken) {
    await authenticate();
  }

  try {
    const response = await axios.get(`${OSU_API_BASE_URL}/beatmapsets/search`, {
      headers: {
        Authorization: `Bearer ${accessToken}`,
      },
      params: { q: query },
    });

    console.log("Osu! API Response:", response.data.beatmapsets);
    return response.data;
  } catch (error) {
    if (error.response && error.response.status === 401) {
      await authenticate();
      return searchBeatmaps(query);
    }

    console.error("Search failed:", error.message);
    throw error;
  }
}

module.exports = { searchBeatmaps };

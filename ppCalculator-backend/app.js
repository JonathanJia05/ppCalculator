require("dotenv").config();
const express = require("express");
const osuService = require("./services/osuAPI");
const PORT = process.env.PORT;
const app = express();

const logger = (req, res, next) => {
  console.log(`${req.method} ${req.url}`);
  next();
};

app.use(logger);

app.get("/api/search", async (req, res) => {
  const query = req.query.q;
  try {
    const beatmaps = await osuService.searchBeatmaps(query);
    res.json(beatmaps);
  } catch (error) {
    console.log(error);
    res.status(500).json({ error: "Failed to search beatmaps" });
  }
});

app.listen(PORT, () => console.log(`Server is now running on port ${PORT}`));

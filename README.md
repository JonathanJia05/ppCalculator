# Osu! PP Calculator

![Swift](https://img.shields.io/badge/Language-Swift-orange)
![FastAPI](https://img.shields.io/badge/Backend-FastAPI-009688)
![iOS](https://img.shields.io/badge/Platform-iOS-blue)

ppCalculator is an iOS application designed to help Osu! players accurately calculate performance point (pp) scores on maps for their personal goals.

## How It Works

1. Search for your desired beatmap from the Osu! database.
   
2. Choose a beatmap, input your selected mods, accuracy percentage, and combo.
   
3. App will send a POST request to the backend, processes the data, and return an accurate PP calculation.

4. Use the calculated PP to farm or set new goals.

## Tech Stack

- **Frontend:** Swift with SwiftUI
- **Backend:** Python with FastAPI
- **Libraries and APIs:**
  - [rosu-pp-py](https://github.com/MaxOhn/rosu-pp-py) for PP calculations
  - [Osu! API v2](https://osu.ppy.sh/docs/index.html) for beatmap search and data retrieval

## Getting Started

### Prereqs

- Xcode installed on your Mac
- An Osu! account and API key

### Installation

1. **Clone repo**
   ```bash
   git clone https://github.com/yourusername/osu-pp-calculator.git
   ```
   
2. **Navigate to Backend**
   ```bash
   cd osu-pp-calculator/backend
   ```
   
3. **Install Dependencies**
   ```bash
   pip install -r requirements.txt
   ```
   
4. **Run Backend Server**
   ```bash
   uvicorn app.main:app --reload
   ```
   
5. **Open the iOS App**
   - Open the project in Xcode and run it in simulator.

## Acknowledgements

- **[rosu-pp-py](https://github.com/RosuAPI/rosu-pp-py):** For PP calculations.
- **[Osu! API v2](https://osu.ppy.sh/docs/index.html):** For beatmap search and data access.

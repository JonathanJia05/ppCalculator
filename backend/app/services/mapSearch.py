import os
import httpx
from fastapi import FastAPI, HTTPException
from dotenv import load_dotenv

load_dotenv(override=True)
print("CLIENT_ID:", os.getenv("CLIENT_ID"))
print("CLIENT_SECRET:", os.getenv("CLIENT_SECRET"))

OSU_BASE_URL = "https://osu.ppy.sh/api/v2"
OSU_AUTH_URL = "https://osu.ppy.sh/oauth/token"
CLIENT_ID = os.getenv("CLIENT_ID")
CLIENT_SECRET = os.getenv("CLIENT_SECRET")
accessToken = None


async def authenticate():
    """
    Authenticate with the osu! API and store the access token globally.
    """
    global accessToken
    try:
        async with httpx.AsyncClient() as client:
            payload = {
                "grant_type": "client_credentials",
                "client_id": CLIENT_ID,
                "client_secret": CLIENT_SECRET,
                "scope": "public",
            }
            response = await client.post(OSU_AUTH_URL, json=payload)
            response.raise_for_status()
            accessToken = response.json()["access_token"]
            print("Authentication successful")
    except httpx.HTTPStatusError as error:
        print(f"Authentication with osu! API failed: {error}")
        raise HTTPException(
            status_code=500, detail=f"Authentication with osu! API failed: {error}"
        )


async def getBeatmapDetails(map_id: int):
    results = []
    global accessToken
    if not accessToken:
        await authenticate()
    try:
        async with httpx.AsyncClient() as client:
            headers = {"Authorization": f"Bearer {accessToken}"}
            url = f"{OSU_BASE_URL}/beatmaps/{map_id}"
            response = await client.get(url, headers=headers)
            response.raise_for_status()
            data = response.json()
            info = {
                "playcount": data["playcount"],
                "maxCombo": data["max_combo"],
                "creator": data["beatmapset"]["creator"],
            }
            return info
    except httpx.HTTPStatusError as error:
        print(f"Error fetching beatmap details: {error}")
        raise

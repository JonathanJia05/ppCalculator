import os
import httpx
from fastapi import HTTPException
from dotenv import load_dotenv

load_dotenv(override=True)
print(os.getenv("CLIENT_ID"))
print(os.getenv("CLIENT_SECRET"))

OSU_BASE_URL = "https://osu.ppy.sh/api/v2"
OSU_AUTH_URL = "https://osu.ppy.sh/oauth/token"
CLIENT_ID = os.getenv("CLIENT_ID")
CLIENT_SECRET = os.getenv("CLIENT_SECRET")
accessToken = None


async def authenticate():
    global accessToken
    try:

        async with httpx.AsyncClient() as client:
            json = {
                "grant_type": "client_credentials",
                "client_id": CLIENT_ID,
                "client_secret": CLIENT_SECRET,
                "scope": "public",
            }
            response = await client.post(OSU_AUTH_URL, json=json)
            response.raise_for_status()
            accessToken = response.json()["access_token"]
            print("Authentication successful")

    except httpx.HTTPStatusError as error:
        print(f"Auth with osu! API failed: {error}")
        raise HTTPException(
            status_code=500, detail="Authentication with osu! API failed"
        )


async def searchMaps(query: str, maxPages: int):
    global accessToken
    if not accessToken:
        await authenticate()

    results = []

    async with httpx.AsyncClient() as client:
        headers = {"Authorization": f"Bearer {accessToken}"}

        for page in range(maxPages):
            try:
                params = {
                    "q": query,
                    "p": page,
                }
                response = await client.get(
                    f"{OSU_BASE_URL}/beatmapsets/search", headers=headers, params=params
                )
                response.raise_for_status()

                data = response.json()

                if not data.get("beatmapsets"):
                    raise HTTPException(status_code=500, detail="No beatmaps found")

                for beatmapset in data["beatmapsets"]:
                    for beatmap in beatmapset.get("beatmaps", []):
                        info = {
                            "title": beatmapset["title"],
                            "version": beatmap["version"],
                            "mapper": beatmapset["creator"],
                            "star_rating": beatmap["difficulty_rating"],
                            "map_id": beatmap["id"],
                            "map_image": beatmapset["covers"]["card"],
                        }
                        results.append(info)

            except httpx.HTTPStatusError as error:
                if error.response.status_code == 401:
                    await authenticate()
                    return await searchMaps(query, maxPages=maxPages)
                else:
                    print(f"Search failed: {error}")
                    raise HTTPException(
                        status_code=500, detail="Failed to search beatmaps"
                    )
    return results

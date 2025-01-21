import os
import httpx
from fastapi import FastAPI, HTTPException

OSU_BASE_URL = "https://osu.ppy.sh/api/v2"
OSU_AUTH_URL = "https://osu.ppy.sh/oauth/token"
CLIENT_ID = 37506
CLIENT_SECRET = "OkCHJnP00ptj9Dlw0EvROxpDnTRpJBJ9gFyJjzpE"
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


async def searchMap(query):
    global accessToken

    if not accessToken:
        await authenticate()

    try:
        async with httpx.AsyncClient() as client:

            headers = {
                "Authorization": f"Bearer {accessToken}",
            }
            params = {"q": query}
            response = await client.get(
                f"{OSU_BASE_URL}/beatmapsets/search", params=params, headers=headers
            )

            return response.json()

    except httpx.HTTPStatusError as error:

        if error.response.status_code == 401:  # the token is expired
            await authenticate()
            return await searchMap(query)

        print(f"Search failed: {error}")
        raise HTTPException(status_code=500, detail="Failed to search beatmaps")

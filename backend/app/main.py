from fastapi import FastAPI
from app.services.search import searchMaps
from app.services.calculation import calculatepp
from app.services.dbSearch import searchDB
from pydantic import BaseModel
from typing import List, Optional

app = FastAPI()


class PPRequest(BaseModel):
    beatmap_id: int
    accuracy: float
    misses: int = 0
    combo: Optional[int] = None
    mods: str = ""


@app.get("/search")
async def search(query: str, pages: int):
    try:
        results = await searchMaps(query, maxPages=pages)
        return results
    except Exception as error:
        return {"error": str(error)}


@app.post("/calculate")
async def post_calculate_pp(data: PPRequest):
    try:
        print(f"Received data: {data}")
        result = calculatepp(
            beatmap_id=data.beatmap_id,
            accuracy=data.accuracy,
            misses=data.misses,
            combo=data.combo,
            mods=data.mods,
        )
        return result
    except Exception as error:
        return {"error": str(error)}


@app.get("/searchdb")
def search(query: str, page: int = 1):
    try:
        results = searchDB(query, page)
        return results
    except Exception as error:
        return {"error": str(error)}

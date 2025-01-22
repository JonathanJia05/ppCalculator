from fastapi import FastAPI
from app.services.search import searchMaps

app = FastAPI()


@app.get("/search")
async def search(query: str, pages: int):
    try:
        results = await searchMaps(query, maxPages=pages)
        return results
    except Exception as error:
        return {"error": str(error)}


@app.post("/calculate")
async def calculate(id: int):
    try:
        results = await calculatepp()
        return results
    except Exception as error:
        return {"error": str(error)}

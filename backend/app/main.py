from fastapi import FastAPI
from app.services.search import searchMap

app = FastAPI()


@app.get("/search")
async def search(query: str):
    try:
        results = await searchMap(query)
        return results
    except Exception as error:
        return {"error": str(error)}

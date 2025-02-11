from fastapi import FastAPI, BackgroundTasks, HTTPException, Header, status, Depends
from app.services.search import searchMaps
from app.services.calculation import calculatepp
from app.services.dbSearch import searchDB
from app.services.mapSearch import getBeatmapDetails
from app.models.PPRequest import PPRequest
from app.services.feedback import send_feedback_email
from app.models.feedback import Feedback
from app.models.auth import authModel
from app.services.authorization import (
    createAccessToken,
    authenticateClient,
    verifyToken,
)
from app.models.token import token
from app.dependencies.dependencies import getCurrentToken

app = FastAPI()


@app.get("/search")
async def search(query: str, pages: int, token_data: dict = Depends(getCurrentToken)):
    try:
        results = await searchMaps(query, maxPages=pages)
        return results
    except Exception as error:
        return {"error": str(error)}


@app.post("/calculate")
async def post_calculate_pp(
    data: PPRequest, token_data: dict = Depends(getCurrentToken)
):
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
def search(
    mode: int,
    query: str = "",
    page: int = 1,
    token_data: dict = Depends(getCurrentToken),
):
    results = searchDB(query=query, page=page, mode=mode)
    return results


@app.get("/beatmap")
async def beatmap_endpoint(map_id: int, token_data: dict = Depends(getCurrentToken)):
    try:
        result = await getBeatmapDetails(map_id)
        return result
    except Exception as error:
        return {"error": str(error)}


@app.post("/feedback")
async def receive_feedback(
    feedback: Feedback,
    background_tasks: BackgroundTasks,
    token_data: dict = Depends(getCurrentToken),
):
    background_tasks.add_task(send_feedback_email, feedback)
    return {"message": "Thank you for your feedback!"}


@app.post("/auth")
async def authenticate(credentials: authModel):
    if authenticateClient(credentials.client_id, credentials.client_secret) == False:
        raise HTTPException(
            status_code=status.HTTP_401_UNAUTHORIZED,
            detail="Invalid client credentials",
        )
    tokenCreate = createAccessToken(data={"sub": credentials.client_id})
    tokenResult = token(access_token=tokenCreate, token_type="Bearer ")
    return tokenResult

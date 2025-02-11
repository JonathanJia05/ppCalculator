from datetime import datetime, timedelta, timezone
import jwt
from fastapi import HTTPException, status
import os
from dotenv import load_dotenv

load_dotenv(override=True)

SECRET_KEY = os.getenv("SECRET_KEY")
ALGORITHM = os.getenv("ALGORITHM")
ACCESS_TOKEN_EXPIRE_MINUTES = int(os.getenv("ACCESS_TOKEN_EXPIRE_MINUTES"))
VALID_CLIENT_ID = os.getenv("VALID_CLIENT_ID")
VALID_CLIENT_SECRET = os.getenv("VALID_CLIENT_SECRET")


def createAccessToken(data: dict):
    encodeTarget = data.copy()
    expire = datetime.now(timezone.utc) + timedelta(minutes=ACCESS_TOKEN_EXPIRE_MINUTES)
    encodeTarget.update({"exp": expire})
    encodedJwt = jwt.encode(encodeTarget, SECRET_KEY, algorithm=ALGORITHM)
    return encodedJwt


def authenticateClient(client_id: str, client_secret: str) -> bool:
    return client_id == VALID_CLIENT_ID and client_secret == VALID_CLIENT_SECRET


def verifyToken(token: str) -> dict:
    try:
        payload = jwt.decode(token, SECRET_KEY, algorithms=[ALGORITHM])
        return payload
    except jwt.PyJWTError:
        raise HTTPException(
            status_code=status.HTTP_401_UNAUTHORIZED, detail="Invalid or expired token"
        )

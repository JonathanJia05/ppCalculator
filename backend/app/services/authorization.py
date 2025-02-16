from datetime import datetime, timedelta, timezone
import jwt
from fastapi import HTTPException, status
import os
from dotenv import load_dotenv
from app.redis.redis_client import redisClient
from app.models.auth import authModel, token, generatedToken
import secrets
import json
import hashlib
import base64

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


def authenticateClient(client_id: str) -> bool:
    return client_id == VALID_CLIENT_ID


def verifyToken(token: str) -> dict:
    try:
        payload = jwt.decode(token, SECRET_KEY, algorithms=[ALGORITHM])
        return payload
    except jwt.PyJWTError:
        raise HTTPException(
            status_code=status.HTTP_401_UNAUTHORIZED, detail="Invalid or expired token"
        )


def computeCodeChallenge(codeVerifier: str, challengeMethod: str) -> str:
    if challengeMethod == "S256":
        encoded = hashlib.sha256(codeVerifier.encode("utf-8")).digest()
        return base64.urlsafe_b64encode(encoded).decode("utf-8").rstrip("=")
    elif challengeMethod == "plain":
        return codeVerifier
    else:
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail="Unsupported code challenge method",
        )


def generateAndStoreAuthCode(credentials: authModel) -> str:
    auth_code = secrets.token_hex(16)
    value = {
        "client_id": credentials.client_id,
        "code_challenge": credentials.code_challenge,
        "code_challenge_method": credentials.challenge_method,
    }
    redisClient.set(auth_code, json.dumps(value), ex=600)
    return auth_code


def generateToken(tokenRequest: token) -> generatedToken:
    storedDataStr = redisClient.get(tokenRequest.auth_code)
    if storedDataStr is None:
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail="Expired or invalid auth code",
        )

    storedData = json.loads(storedDataStr)

    computed_challenge = computeCodeChallenge(
        codeVerifier=tokenRequest.code_verifier,
        challengeMethod=storedData["code_challenge_method"],
    )

    if computed_challenge != storedData["code_challenge"]:
        raise HTTPException(
            status_code=status.HTTP_401_UNAUTHORIZED, detail="Verification failed"
        )

    accessToken = createAccessToken(data={"client_id": tokenRequest.client_id})
    redisClient.delete(tokenRequest.auth_code)

    return generatedToken(access_token=accessToken, token_type="Bearer")

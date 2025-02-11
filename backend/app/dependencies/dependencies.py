from fastapi import Depends, HTTPException, Header, status
from app.services.authorization import verifyToken


def getCurrentToken(authorization: str = Header(...)):
    if not authorization.startswith("Bearer "):
        raise HTTPException(
            status_code=status.HTTP_401_UNAUTHORIZED,
            detail="Invalid authorization header format",
        )
    token = authorization.split(" ")[1]
    return verifyToken(token)

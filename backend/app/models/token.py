from pydantic import BaseModel


class token(BaseModel):
    access_token: str
    token_type: str

from pydantic import BaseModel


class authModel(BaseModel):
    client_id: str
    code_challenge: str
    challenge_method: str


class token(BaseModel):
    client_id: str
    auth_code: str
    code_verifier: str


class generatedToken(BaseModel):
    access_token: str
    token_type: str

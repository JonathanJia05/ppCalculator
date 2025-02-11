from pydantic import BaseModel


class authModel(BaseModel):
    client_id: str
    clint_secret: str

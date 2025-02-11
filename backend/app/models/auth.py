from pydantic import BaseModel


class authModel(BaseModel):
    client_id: str
    client_secret: str

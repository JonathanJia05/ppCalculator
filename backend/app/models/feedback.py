from pydantic import BaseModel


class Feedback(BaseModel):
    message: str

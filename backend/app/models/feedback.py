from pydantic import BaseModel, EmailStr


class Feedback(BaseModel):
    message: str

from pydantic import BaseModel, EmailStr


class Feedback(BaseModel):
    name: str
    email: EmailStr
    subject: str
    message: str

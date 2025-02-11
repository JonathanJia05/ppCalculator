from pydantic import BaseModel
from typing import Optional


class PPRequest(BaseModel):
    beatmap_id: int
    accuracy: float
    misses: int = 0
    combo: Optional[int] = None
    mods: str = ""

import os
import redis
from dotenv import load_dotenv

load_dotenv()

redisClient = redis.Redis(
    host=os.getenv("REDIS_HOST"),
    port=int(os.getenv("REDIS_PORT")),
    decode_responses=True,
)

import psycopg2
from psycopg2.extras import RealDictCursor
from app.database.config import load_config


def searchDB(query: str):
    sql = """
        SELECT 
            title,
            difficulty AS version,
            artist AS mapper,
            stars AS star_rating,
            mapid AS map_id,
            imgurl AS map_image
        FROM beatmaps
        WHERE search_vector @@ plainto_tsquery('english', %s)
    """
    results = []
    try:
        config = load_config()
        with psycopg2.connect(**config) as conn:
            with conn.cursor(cursor_factory=RealDictCursor) as curr:
                curr.execute(sql, (query,))
                results = curr.fetchall()
        print(f"{query} fetched")
    except Exception as error:
        print("Error retrieving beatmap:", error)
    return results

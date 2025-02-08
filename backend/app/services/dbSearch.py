import psycopg2
from psycopg2.extras import RealDictCursor
from app.database.config import load_config


def searchDB(query: str, page: int = 1):
    pageSize = 100
    offset = (page - 1) * pageSize
    sql = """
        SELECT 
            title, 
            difficulty AS version, 
            artist AS artist, 
            stars AS star_rating, 
            mapid AS map_id, 
            imgurl AS map_image,
            max_combo AS max_combo,
            mapper AS mapper,
            playcount AS plays
        FROM beatmaps
        WHERE search_vector @@ plainto_tsquery('english', %s)
        ORDER BY playcount DESC
        LIMIT %s OFFSET %s
    """
    results = []
    try:
        config = load_config()
        with psycopg2.connect(**config) as conn:
            with conn.cursor(cursor_factory=RealDictCursor) as cur:
                cur.execute(sql, (query, pageSize, offset))
                results = cur.fetchall()
        print(f"{query} fetched for page {page}")
    except Exception as error:
        print("Error retrieving beatmap:", error)
    return results

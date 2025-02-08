import psycopg2
from psycopg2.extras import RealDictCursor
from app.database.config import load_config


def searchDB(query: str, page: int = 1):
    pageSize = 50
    offset = (page - 1) * pageSize

    if query.strip() == "":
        sql = """
            SELECT 
                title, 
                difficulty AS version, 
                artist, 
                stars AS star_rating, 
                mapid AS map_id, 
                imgurl AS map_image,
                max_combo,
                mapper,
                playcount AS plays
            FROM beatmaps
            ORDER BY playcount DESC
            LIMIT %s OFFSET %s;
        """
        params = (pageSize, offset)
    else:
        sql = """
            SELECT 
                title, 
                difficulty AS version, 
                artist, 
                stars AS star_rating, 
                mapid AS map_id, 
                imgurl AS map_image,
                max_combo,
                mapper,
                playcount AS plays
            FROM beatmaps
            WHERE search_vector @@ plainto_tsquery('english', %s)
            ORDER BY playcount DESC
            LIMIT %s OFFSET %s;
        """
        params = (query, pageSize, offset)

    results = []
    try:
        config = load_config()
        with psycopg2.connect(**config) as conn:
            with conn.cursor(cursor_factory=RealDictCursor) as cur:
                cur.execute(sql, params)
                results = cur.fetchall()
        if query.strip() != "":
            print(f"'{query}' results fetched")
        else:
            print(f"Default results")
    except Exception as error:
        print("Error retrieving beatmap:", error)
    return results

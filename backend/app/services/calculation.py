import requests
import rosu_pp_py as rosu


def fetchOsuFile(beatmap_id: int) -> bytes:
    url = f"https://osu.ppy.sh/osu/{beatmap_id}"
    response = requests.get(url)
    response.raise_for_status()
    return response.content


def calculatepp(
    beatmap_id: int,
    accuracy: float,
    misses: int = 0,
    combo: int = None,
    mods: int = 0,
):
    content = fetchOsuFile(beatmap_id)
    beatmap = rosu.Beatmap(content=content)
    perf = rosu.Performance(
        accuracy=accuracy,
        misses=misses,
        combo=combo,
        mods=mods,
        hitresult_priority=rosu.HitResultPriority.WorstCase,
    )
    attrs = perf.calculate(beatmap)

    return {
        "pp": attrs.pp,
    }

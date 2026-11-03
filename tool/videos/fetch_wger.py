"""Builds the bundled exercise videos from wger.de (CC-BY-SA 4.0).

For each wger exercise that has a video and matches a library lift, takes one
clip (the main one, else the shortest), trims it to 10 s, scales it to 480p,
drops the audio and writes `assets/exercises/videos/wger_<id>.mp4`, plus
`videos.json` with the credit for every clip. Needs ffmpeg.

    python3 tool/videos/fetch_wger.py
"""

import json
import pathlib
import subprocess
import urllib.request
from concurrent.futures import ThreadPoolExecutor

OUT = pathlib.Path(__file__).resolve().parents[2] / 'assets/exercises/videos'

# wger exercise id -> library ids it demonstrates. Checked by eye against a
# frame of each video, not just by name.
MATCHES = {
    12: ['Thigh_Adductor'],
    46: ['Barbell_Lunge'],
    73: ['Barbell_Bench_Press_-_Medium_Grip'],
    75: ['Dumbbell_Bench_Press'],
    82: ['Reverse_Flyes'],
    91: ['Barbell_Curl'],
    92: ['Dumbbell_Bicep_Curl'],
    95: ['Standing_Biceps_Cable_Curl'],
    194: ['Dips_-_Triceps_Version'],
    205: ['Dumbbell_Lunges'],
    211: ['Seated_Triceps_Press'],
    222: ['Face_Pull'],
    245: ['Lying_Dumbbell_Tricep_Extension'],
    246: ['EZ-Bar_Skullcrusher'],
    257: ['Front_Barbell_Squat', 'Front_Squat_Clean_Grip'],
    272: ['Hammer_Curls'],
    275: ['Cable_Hammer_Curls_-_Rope_Attachment'],
    294: ['Barbell_Hip_Thrust'],
    341: ['Smith_Machine_Squat'],
    348: ['Side_Lateral_Raise'],
    349: ['Cable_Seated_Lateral_Raise'],
    365: ['Lying_Leg_Curls'],
    366: ['Seated_Leg_Curl'],
    367: ['Standing_Leg_Curl'],
    371: ['Leg_Press'],
    375: ['Hack_Squat'],
    465: ['Preacher_Curl'],
    475: ['Pullups'],
    507: ['Stiff-Legged_Dumbbell_Deadlift'],
    512: ['Seated_Cable_Rows'],
    537: ['Incline_Dumbbell_Press'],
    538: ['Barbell_Incline_Bench_Press_-_Medium_Grip'],
    543: ['Machine_Shoulder_Military_Press'],
    567: ['Dumbbell_Shoulder_Press'],
    570: ['Barbell_Shrug'],
    584: ['One_Arm_Dumbbell_Preacher_Curl'],
    590: ['Seated_Calf_Raise'],
    622: ['Standing_Calf_Raises'],
    655: ['Tricep_Dumbbell_Kickback'],
    659: ['Cable_Rope_Overhead_Triceps_Extension'],
    802: ['Barbell_Walking_Lunge'],
    803: ['Cable_One_Arm_Tricep_Extension'],
}


def get(url):
    with urllib.request.urlopen(url, timeout=30) as r:
        return json.load(r)


def pick(videos):
    best = {}
    for v in videos:
        cur = best.get(v['exercise'])
        key = (not v['is_main'], float(v['duration']))
        if cur is None or key < (not cur['is_main'], float(cur['duration'])):
            best[v['exercise']] = v
    return best


def encode(video, dest):
    if dest.exists():
        return
    subprocess.run(
        ['ffmpeg', '-loglevel', 'error', '-y', '-i', video['video'], '-t', '10', '-an',
         '-vf', 'scale=854:-2,fps=30', '-c:v', 'libx264', '-profile:v', 'main',
         '-pix_fmt', 'yuv420p', '-crf', '30', '-preset', 'slow', '-movflags', '+faststart',
         str(dest)],
        check=True,
    )


def main():
    library = json.loads((OUT.parent / 'library.json').read_text())
    known = {e['id'] for e in library['exercises']}
    missing = [i for ids in MATCHES.values() for i in ids if i not in known]
    assert not missing, f'not in the library: {missing}'

    best = pick(get('https://wger.de/api/v2/video/?limit=500')['results'])
    OUT.mkdir(parents=True, exist_ok=True)
    jobs = [(best[w], OUT / f'wger_{w}.mp4') for w in MATCHES if w in best]
    with ThreadPoolExecutor(4) as pool:
        list(pool.map(lambda j: encode(*j), jobs))

    clips = []
    for w, ids in MATCHES.items():
        v = best.get(w)
        if v is None:
            continue
        name = next(
            (t['name'] for t in get(f'https://wger.de/api/v2/exerciseinfo/{w}/')['translations']
             if t['language'] == 2),
            '',
        )
        clips.append({
            'file': f'wger_{w}.mp4',
            'ids': ids,
            'title': name,
            'author': v['license_author'] or 'wger.de contributors',
            'license': 'CC BY-SA 4.0',
            'licenseUrl': 'https://creativecommons.org/licenses/by-sa/4.0/',
            'source': f'https://wger.de/exercise/{w}/view/',
            'changes': 'Trimmed to 10 s, scaled to 480p, audio removed.',
        })
    (OUT / 'videos.json').write_text(json.dumps({
        'source': 'wger.de exercise videos, CC BY-SA 4.0',
        'clips': clips,
    }, indent=1) + '\n')
    total = sum((OUT / c['file']).stat().st_size for c in clips)
    print(f'{len(clips)} clips, {total / 1e6:.1f} MB')


if __name__ == '__main__':
    main()

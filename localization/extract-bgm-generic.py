import struct, subprocess, pathlib, sys

game = sys.argv[1] if len(sys.argv) > 1 else "th07"
ver = {"th06": 6, "th07": 7, "th08": 8}[game]
dat = {"th07": "/home/cbx/games/th07/th07.dat", "th08": "/home/cbx/games/th08/th08.dat", "th06": None}[game]
work = pathlib.Path("/tmp/thdat-" + game); work.mkdir(exist_ok=True)
subprocess.run(["/home/cbx/thtk/build/thdat/thdat", "-x", str(ver), dat, "thbgm.fmt"], cwd=work, check=True)
fmt = (work / "thbgm.fmt").read_bytes()
src = open("/home/cbx/games/" + game + "/thbgm.dat", "rb", buffering=0)
out = pathlib.Path("/home/cbx/games/" + game + "/bgm-ogg"); out.mkdir(parents=True, exist_ok=True)
tracks = []
for p in range(0, len(fmt) - 51, 52):
    if not fmt[p]: break
    name, offset, preload, intro, length = struct.unpack_from("<16sIIII", fmt, p)
    tracks.append((name.split(b"\0")[0].decode("ascii"), offset, length))
print(len(tracks), "tracks")
for i, (name, offset, length) in enumerate(tracks):
    stem = name.rsplit(".", 1)[0]
    target = out / (stem + ".ogg")
    if target.exists() and target.stat().st_size > 10000:
        print(i, stem, "skip"); continue
    src.seek(offset)
    pcm = src.read(length)
    assert len(pcm) == length
    proc = subprocess.run(["ffmpeg", "-y", "-loglevel", "error", "-f", "s16le", "-ar", "44100", "-ac", "2",
                           "-i", "pipe:0", "-c:a", "libvorbis", "-q:a", "4", str(target)], input=pcm)
    print(i, stem, "rc=", proc.returncode)
print("DONE")

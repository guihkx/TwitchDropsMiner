### Building

Run the following in the root of the project (and *not* inside the directory of this README):

Alpine 3.22 (first edit `Containerfile-alpine` and use `python:3.13-alpine3.22' as the base image):

```
podman build -t localhost/tdm-alpine-3.22:latest -f container/Containerfile-alpine .
```

Alpine 3.21:

```
podman build -t localhost/tdm-alpine-3.21:latest -f container/Containerfile-alpine .
```

Debian 12 Bookworm:

```
podman build -t localhost/tdm-debian-12:latest -f container/Containerfile .
```

To run:

Alpine 3.22:

```
cd ~/dev/TwitchDropsMiner/; podman run --name tdm-alpine-3.22 --rm -it --net host -e TZ=America/Sao_Paulo -e DISPLAY=:1 -e VNC_PORT=5900 -v ./container/entrypoint.sh:/TDM/entrypoint.sh --entrypoint '' localhost/tdm-alpine-3.22:latest sh entrypoint.sh python main.py -vvv
```

Alpine 3.21:

```
cd ~/dev/TwitchDropsMiner/
mkdir -p cache && touch settings.json cookies.jar
podman run --name tdm --detach --replace --restart always --log-driver journald -it -p 127.0.0.1:5900:5900 -e VNC_PORT=5900 -e TZ=America/Sao_Paulo -v ./cookies.jar:/TDM/cookies.jar -v ./cache:/TDM/cache localhost/tdm-alpine-3.21:latest

podman run --name tdm-alpine-3.21 --rm -it --net host -e TZ=America/Sao_Paulo -e DISPLAY=:2 -e VNC_PORT=5901 -v ./container/entrypoint.sh:/TDM/entrypoint.sh --entrypoint '' localhost/tdm-alpine-3.21:latest sh entrypoint.sh python main.py -vvv
```

Debian 12 Bookworm:

```
cd ~/dev/TwitchDropsMiner/; podman run --name tdm-debian-12 --rm -it --net host -e TZ=America/Sao_Paulo -e DISPLAY=:3 -e VNC_PORT=5902 -v ./container/entrypoint.sh:/TDM/entrypoint.sh --entrypoint '' localhost/tdm-debian-12:latest sh entrypoint.sh python main.py -vvv
```

Image size comparison:

```
$ podman images
REPOSITORY                 TAG                 IMAGE ID      CREATED         SIZE
localhost/tdm-alpine-3.21  latest              8b38589e5169  13 minutes ago  504 MB
localhost/tdm-alpine-3.22  latest              13e78264aa38  41 minutes ago  545 MB
localhost/tdm-debian-12    latest              d100eb6aca4b  51 minutes ago  530 MB
```

Resource usage comparison (not logged in to Twitch):

```
$ podman stats
ID            NAME             CPU %       MEM USAGE / LIMIT  MEM %       NET IO      BLOCK IO    PIDS        CPU TIME    AVG CPU %
c238c9e51761  tdm-alpine-3.22  1.06%       58MB / 16.71GB     0.35%       0B / 0B     0B / 0B     7           2.245085s   3.66%
2e19fd61710f  tdm-alpine-3.21  1.06%       56.03MB / 16.71GB  0.34%       0B / 0B     0B / 0B     7           2.189451s   3.62%
09093349b4b6  tdm-debian-12    1.06%       64.52MB / 16.71GB  0.39%       0B / 0B     0B / 0B     6           2.0465s     3.41%
```

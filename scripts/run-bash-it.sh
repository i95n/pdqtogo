docker build -t pdqtogo -f continer/Dockerfile .

docker run -it --entrypoint /bin/sh -v $PWD/app:/demo -w /demo -p 8080:8080 pdqtogo
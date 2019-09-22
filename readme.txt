docker run -it ruby /bin/bash


docker run -it --rm -v $PWD/app:/app -w /app -p 8080:8080 ruby /bin/bash
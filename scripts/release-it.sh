docker build -t pdqtogo -f continer/Dockerfile .

sh scripts/version.sh $(cat version.txt) feature > version.txt

imageid=$(docker images | grep "pdqtogo" | grep "latest" | awk '{print $3}')
version=$(cat version.txt)

docker tag $imageid i95north/pdqtogo:$version

echo "latest [pdqtogo#$imageid] was tagged with $version"

docker push i95north/pdqtogo

git tag -a v$version -m "Tagged version v$version"
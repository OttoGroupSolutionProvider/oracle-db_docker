# Build Oracle database image 
# Peter Ramm, 16.04.2019

# Parameter : Database version, supported values:
#   12.1.0.2-ee
#   12.1.0.2-se2
#   12.2.0.1-ee
#   12.2.0.1-se2
#   18.3.0.0-ee
#   18.3.0.0-se2


# Use this script instead of building directly with dockerfiles
if [ $# -ne 1 ]
then
  echo "Syntax: build_db_image <version>"
  echo "Parameter VERSION expected! Like '12.1.0.2-ee'"
  exit 1
fi

export VERSION=$1

if [[ $VERSION == *"xe"* ]]; then
  export ORACLE_SID=XE
  export ORACLE_PDB=XEPDB1
else
  export ORACLE_SID=ORCLCDB
  export ORACLE_PDB=ORCLPDB1
fi
export BASE_IMAGE=oracle/database:${VERSION}

# Ensure that image is loaded before docker inspect
docker pull $BASE_IMAGE

# get environment from base image and replace in Dockerfile
docker inspect ${BASE_IMAGE} | jq ".[0].Config.Env" |
  sed 's/"//g; s/,//; s/^/ENV /; s/\//\\\//g'  |
  grep -v "\[" | grep -v "\]" |
  awk '{printf "%s\\n", $0}' > base.env

sed "s/BASE_ENV/$(cat base.env)/" Dockerfile > Dockerfile.modified

echo "Building Oracle database for version = $VERSION"

# add --squash if it is not experimental no more
# Disable DOCKER_BUILDKIT as workaround for "/sys/fs/cgroup/memory.max no such file or directory" see: https://github.com/oracle/docker-images/issues/2334
DOCKER_BUILDKIT=0 docker build \
    --no-cache \
    --build-arg BASE_IMAGE=$BASE_IMAGE \
    --build-arg ORACLE_SID=$ORACLE_SID \
    --build-arg ORACLE_PDB=$ORACLE_PDB \
    --progress=plain \
    -f Dockerfile.modified \
    -t oracle/database_prebuilt:$VERSION \
    -m 3g .


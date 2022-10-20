# oracle-db_docker
This repo contains the Dockerfiles ans scripts needed to build Docker images with an already installed Oracle Database instance.

Purpose for these images is use for development and test DBs, not production.
A quick start in seconds of a container with a fresh usable running DB instance is especially helpful in CI piplines.



## Steps to build an Oracle DB instance inside a Docker image
### Step 1: Build Docker image for Oracle DB software package

Use Oracle's official Dockerfiles (by Gerald Venzl) at https://github.com/oracle/docker-images.

Follow the instruction from https://github.com/oracle/docker-images/tree/master/OracleDatabase

#### Example steps for single instance Oracle 12.1.0.2 Enterprise Edition:
* Download the Dockerfile package by `git clone https://github.com/oracle/docker-images.git`
* Download software package for 12.1.0.2 EE from https://edelivery.oracle.com/osdc/faces/SoftwareDelivery
* Store the downloaded software package at docker-images/OracleDatabase/SingleInstance/dockerfiles/12.1.0.2 
* create the Docker image by executing:

      cd docker-images/OracleDatabase/SingleInstance/dockerfiles <br/>
      ./buildContainerImage.sh -v 12.1.0.2 -e -t oracle/database:12.1.0.2-ee  -o '--build-arg SLIMMING=false'

  * rename zip files according to the error message if they did not have the expect name (like `linuxamd64_12102_database_1of2.zip`) 
  * the `-o '--build-arg SLIMMING=false'` is needed only if you plan to patch the image in the next step. 
Otherwise the image will be slimmed down by removing unneded packages like sqldeveloper, but patching such a slimmed image becomes impossible.
* The resulting Docker image is named `oracle/database:12.1.0.2-ee`

### Step 2: Patch the image created in step 1
Creates an image with current patch state of underlying OS and Oracle software.
Patching requires a complete ORACLE_HOME, so be aware of setting `-o '--build-arg SLIMMING=false'` in the previous step.
As part of the image build unnecessary packages are removed after patching to reduce the size of the resulting image.
- Change dir to oracle_db_patch
- Download patch file as well as current OPatch utility and store in current directory
- Run "./build_db_image.sh \<VERSION\> \<patch file.zip\> \<opatch file.zip\>"
- Tag created image according to DB release and push it to your local registry

#### Example steps for 12.1.0.2 EE
- Download current opatch tool from https://updates.oracle.com/download/6880880.html
- store the zip file with opatch it in folder `oracle_db_patched`
- Download the current patch set bundle, store it also in  folder `oracle_db_patched`
- Build a new image with patched software and stripped from unused packages by:

      cd oracle_db_patched
      ./build_db_image.sh 12.1.0.2-ee p34386266_121020_Linux-x86-64.zip p6880880_210000_Linux-x86-64.zip

- the resulting Docker image is named `oracle/database_patched:12.1.0.2-ee`
- remove the unpatched image and rename use the patched instead

      docker rmi oracle/database:12.1.0.2-ee
      docker tag oracle/database_patched:12.1.0.2-ee oracle/database:12.1.0.2-ee 

### Step 3: Create an image with a preinstalled database instance
Creates an image with an already installed DB instance.
The default password for sytem accounts is "oracle".
- Change dir to the folder `oracle_db_prebuilt`
- Run `./build_db_image.sh <VERSION>` 
- Tag the created image and push to your local registry

#### Example steps for 12.1.0.2 EE
- Build the image 

      cd oracle_db_prebuilt
      ./build_db_image.sh 12.1.0.2-ee

- the resulting Docker image is named `oracle/database_prebuilt:12.1.0.2-ee`

### Step 4: Create a container with a running DB instance

To create an container based on the example image execute:

      docker run -p 1521:1521 oracle/database_prebuilt:12.1.0.2-ee 


## Alternative: Use existing Docker images from container-registry.oracle.com
https://container-registry.oracle.com contains Docker images for the current release of several Oracle products including Oracle-DB. 

## Reminder
Please note that a valid license is regularly required to run and operate an Oracle Database instance.

git clone https://github.com/gab-3d/GAB-OS.git

cd ~/GAB-OS/


sudo apt update; sudo apt install --yes aria2 coreutils jq p7zip-full qemu-user-static zip

cd ~
git clone https://github.com/guysoft/CustomPiOS.git

cd CustomPiOS
git branch stable 63da54b86ab566c558e9084568d326413f6585d8
git switch stable

cd ~/GAB-OS/

matrix=['armbian/bananapim2zero', 'armbian/orangepi3lts', 'armbian/orangepi4lts', 'orangepi/orangepi_zero2', 'raspberry/rpi32', 'raspberry/rpi64', 'raspberry/rpi64-ks']



IFS='/' read -r -a array <<< "raspberry/rpi64"
TYPE=${array[0]}
SBC=${array[1]}

echo "TYPE=${TYPE}" >> $GITHUB_OUTPUT
echo "SBC=${SBC}" >> $GITHUB_OUTPUT

GENERIC_FILE="./config/default"
if [[ -f "$GENERIC_FILE" ]]; then
    cat "${GENERIC_FILE}" >> ./src/config
fi

TYPE_FILE="./config/${TYPE}/default"
if [[ -f "$TYPE_FILE" ]]; then
    cat "${TYPE_FILE}" >> ./src/config
fi

SBC_FILE="./config/${TYPE}/${SBC}"
if [[ -f "$SBC_FILE" ]]; then
    cat "${SBC_FILE}" >> ./src/config
fi

source ./src/config

echo $DOWNLOAD_URL_CHECKSUM
echo $DOWNLOAD_URL_IMAGE
echo $MODULES
echo $(cat ./src/config)

echo "DOWNLOAD_URL_CHECKSUM=${DOWNLOAD_URL_CHECKSUM}" >> $GITHUB_OUTPUT
echo "DOWNLOAD_URL_IMAGE=${DOWNLOAD_URL_IMAGE}" >> $GITHUB_OUTPUT
echo "MODULES=${MODULES}" >> $GITHUB_OUTPUT


cd ./src/image
FILENAME=$(basename $DOWNLOAD_URL_CHECKSUM )
wget -O $FILENAME $DOWNLOAD_URL_CHECKSUM }
FILE_CONTENT=$(head -n 1 $FILENAME)
CHECKSUM=$(echo $FILE_CONTENT | cut -d' ' -f1)

echo "CHECKSUM=$CHECKSUM" >> $GITHUB_OUTPUT
echo "FILENAME=$FILENAME" >> $GITHUB_OUTPUT


aria2c -d . --seed-time=0 $DOWNLOAD_URL_IMAGE

cd ..
cd ..
cd ./src && ../../CustomPiOS/src/update-custompios-paths
sudo modprobe loop && sudo bash -x ./build_dist
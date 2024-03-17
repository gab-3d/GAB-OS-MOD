./clean.sh
cd ~/

git clone https://github.com/gab-3d/GAB-OS.git

cp -r ~/GAB-OS-MOD/modules/* ~/GAB-OS/src/modules/
cp -r ~/GAB-OS-MOD/config/rpi64-ks-mk3 ~/GAB-OS/config/raspberry/rpi64-ks-mk3



cd ~
git clone https://github.com/guysoft/CustomPiOS.git

cd CustomPiOS
git branch stable 63da54b86ab566c558e9084568d326413f6585d8
git switch stable

cd ~/GAB-OS/

sudo apt update; sudo apt install --yes aria2 coreutils jq p7zip-full qemu-user-static zip

matrix=['armbian/bananapim2zero', 'armbian/orangepi3lts', 'armbian/orangepi4lts', 'orangepi/orangepi_zero2', 'raspberry/rpi32', 'raspberry/rpi64', 'raspberry/rpi64-ks']



IFS='/' read -r -a array <<< "raspberry/rpi64-ks-mk3"
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


#create a filename tat start wirh current date and time add gab-os-mod to the end 
TARGGET_FILENAME=$(date +"%Y-%m-%d-%H-%M-%S")-gab-os-mod

cd ~/GAB-OS/src/workspace/
CPU_COUNT="$(nproc)"
echo -e "\e[32mUsing ${CPU_COUNT} Cores for compression...\e[0m"
xz -efkvz9T"${CPU_COUNT}" '2023-05-03-raspios-bullseye-arm64-lite.img' || true

cp ~/GAB-OS/src/workspace/2023-05-03-raspios-bullseye-arm64-lite.img.xz ~/GAB-OS-MOD/{$TARGGET_FILENAME}.img.xz
cp ~/GAB-OS/src/build.log ~/GAB-OS-MOD/{$TARGGET_FILENAME}.log
./clean.sh




# #remove CustomPiOS folder and GAB-OS folder
# sudo rm -rf ~/CustomPiOS
# sudo rm -rf ~/GAB-OS


generateImage() {
    local version=$1
    cd ~/GAB-OS/

    IFS='/' read -r -a array <<< $version
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
    TARGGET_FILENAME=$(date +"%Y-%m-%d-%H-%M-%S-gab-os-")$SBC

    cd ~/GAB-OS/src/workspace/
    CPU_COUNT=12
    echo -e "\e[32mUsing ${CPU_COUNT} Cores for compression...\e[0m"
    sudo xz -efkvz9T"${CPU_COUNT}" '2023-05-03-raspios-bullseye-arm64-lite.img' || true


    cp ~/GAB-OS/src/workspace/2023-05-03-raspios-bullseye-arm64-lite.img.xz ~/GAB-OS-MOD/$TARGGET_FILENAME.img.xz
    cp ~/GAB-OS/src/build.log ~/GAB-OS-MOD/$TARGGET_FILENAME.log

        # Rest of the code goes here
}

sudo apt update; sudo apt install --yes aria2 coreutils jq p7zip-full qemu-user-static zip dialog

cd ~/GAB-OS-MOD/
./clean.sh


cd ~/

git clone https://github.com/gab-3d/GAB-OS.git

cp -r ~/GAB-OS-MOD/modules/* ~/GAB-OS/src/modules/
cp -r ~/GAB-OS-MOD/config/* ~/GAB-OS/config/raspberry/


cd ~
git clone https://github.com/guysoft/CustomPiOS.git

cd CustomPiOS
git branch stable 63da54b86ab566c558e9084568d326413f6585d8
git switch stable

imageToGenerate=("raspberry/rpi64-base" "raspberry/rpi64-ks-voron" "raspberry/rpi64-ks-mk3")
imageToGenerate=("raspberry/rpi64-base")

for image in "${imageToGenerate[@]}"
do
    generateImage "$image"
    sudo rm -rf ~/GAB-OS/src/workspace/*
done


#generateImage "raspberry/rpi64-ks-voron"


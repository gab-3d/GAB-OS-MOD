# Function to update and install required packages
updateAndInstallPackages() {
    sudo apt update
    sudo apt upgrade --yes
    sudo apt install --yes aria2 coreutils jq p7zip-full qemu-user-static zip dialog xz xz-utils nodejs gh tmux
    sudo npm install -g n


}

# Function to clean the workspace
cleanWorkspace() {
    cd ~/GAB-OS-MOD/
    ./clean.sh
}

# Function to clone the GAB-OS repository
cloneGABOS() {
    cd ~/
    git clone https://github.com/gab-3d/GAB-OS.git
}

# Function to copy modules and config
copyModulesAndConfig() {
    cp -r ~/GAB-OS-MOD/modules/* ~/GAB-OS/src/modules/
    cp -r ~/GAB-OS-MOD/config/* ~/GAB-OS/config/raspberry/
}

# Function to clone the CustomPiOS repository
cloneCustomPiOS() {
    cd ~
    git clone https://github.com/guysoft/CustomPiOS.git
    cd CustomPiOS
    git branch stable 63da54b86ab566c558e9084568d326413f6585d8
    git switch stable
}

# Function to generate an image
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
    wget -O $FILENAME $DOWNLOAD_URL_CHECKSUM
    FILE_CONTENT=$(head -n 1 $FILENAME)
    CHECKSUM=$(echo $FILE_CONTENT | cut -d' ' -f1)

    echo "CHECKSUM=$CHECKSUM" >> $GITHUB_OUTPUT
    echo "FILENAME=$FILENAME" >> $GITHUB_OUTPUT

    aria2c -d . --seed-time=0 $DOWNLOAD_URL_IMAGE

    cd ..
    cd ..
    cd ./src && ../../CustomPiOS/src/update-custompios-paths
    sudo modprobe loop && sudo bash -x ./build_dist

    if [ $? -ne 0 ]; then
        echo "Build failed"
        exit 1
    fi

    compressAndCopyFiles

}
# Function to compress and copy image and log files
compressAndCopyFiles() {
    TARGGET_FILENAME=$(date +"%Y-%m-%d-%H-%M-gab-os-")$SBC

    cd ~/GAB-OS/src/workspace/
    CPU_COUNT=$(grep -c ^processor /proc/cpuinfo)
    echo -e "\e[32mUsing ${CPU_COUNT} Cores for compression...\e[0m"
    sudo xz -efkvz9T"${CPU_COUNT}" '2023-05-03-raspios-bullseye-arm64-lite.img' || true

    cp ~/GAB-OS/src/workspace/2023-05-03-raspios-bullseye-arm64-lite.img.xz ~/GAB-OS-MOD/$TARGGET_FILENAME.img.xz

    cp ~/GAB-OS/src/build.log ~/GAB-OS-MOD/$TARGGET_FILENAME.log

    # After generating the image, upload it to a GitHub release
    local image_path=~/GAB-OS-MOD/$TARGGET_FILENAME.img.xz
    cd ~/GAB-OS-MOD/
    gh release upload $TARGGET_FILENAME.img.xz $image_path --clobber
    cd ~/GAB-OS/src/workspace/
}
# Function to get the images to generate
getImagesToGenerate() {
    # Ask for which image to generate with dialog
    dialog --checklist "Select the images to generate" 0 0 0 \
    "raspberry/rpi64-base" "Base image" on \
    "raspberry/rpi64-ks-voron" "Voron image" on \
    "raspberry/rpi64-ks-mk3" "MK3 image" on 3>&1 1>&2 2>&3
}

# Function to generate all images
generateAllImages() {
    imageToGenerate=($(getImagesToGenerate))

    for image in "${imageToGenerate[@]}"
    do
        generateImage "$image"
        if [ $? -ne 0 ]; then
            echo "Build failed"
            exit 1
        fi
        sudo rm -rf ~/GAB-OS/src/workspace/*



    done
}

createGithubRelease() {
    cd ~/GAB-OS-MOD/
    #check if gh is already logged in
    gh auth status
    if [ $? -ne 0 ]; then
        gh auth login
    fi

    # Determine the tag for the new release
    local latest_tag=$(git describe --tags `git rev-list --tags --max-count=1`)
    local prefix=${latest_tag%.*}
    local suffix=${latest_tag##*.}
    local new_suffix=$((suffix + 1))
    release_tag="$prefix.$new_suffix"

    # After generating the image, upload it to a GitHub release
    
    gh release create $release_tag --title $release_tag GAB OS --prerelease --draft

}


# Call all functions
updateAndInstallPackages
cleanWorkspace
createGithubRelease
cloneGABOS
copyModulesAndConfig
cloneCustomPiOS
generateAllImages

createGithubRelease() {
    cd ~/GAB-OS-MOD/
    #echo al files that ens with .img.xz
    ls -l *.img.xz
    #ask for confirmaion to proceed



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

    #output new release tag
    
    read -e -p "Creating release:" -i $release_tag release_tag

    echo "Creating release $release_tag"
     

    # After generating the image, upload it to a GitHub release
    
    gh release create $release_tag --notes "bugfix release"

    gh release upload $release_tag ~/GAB-OS-MOD/*.img.xz --clobber
}

#check if gh is installed
gh --version
if [ $? -ne 0 ]; then
    echo "gh is not installed. Please install it first"
    exit 1
fi
#delete all file ending with .img--
rm -f ~/GAB-OS-MOD/*.img--
#loop all the files in the folder ending with .img
for f in ~/GAB-OS-MOD/*.img; do
    #compress the file
    xz -efkvz9T10 $f || true
    #rename uncompressed file to .img--
    mv $f $f--

done





createGithubRelease



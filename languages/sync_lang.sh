case `uname -s` in
    Darwin) 
           txtrst='\033[0m' # Color off
           txtgrn='\033[0;32m' # Green
           txtblu='\033[0;34m' # Blue
           ;;
    *)
           txtrst='\e[0m' # Color off
           txtgrn='\e[0;32m' # Green
           txtblu='\e[0;36m' # Blue
           ;;
esac

LANG=$1
ISO=$2
REPO=$3
echo -e "${txtblu}\nSyncing $LANG${txtrst}"
if [ -e languages/$ISO ]; then
     cd languages/$ISO; git pull; cd ../..
else
     git clone $REPO languages/$ISO
fi

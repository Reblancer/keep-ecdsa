#!/bin/bash
set -e

# Dafault inputs.
KEEP_ETHEREUM_PASSWORD_DEFAULT=password
LOG_LEVEL_DEFAULT="info"
CONFIG_DIR_PATH_DEFAULT=$(realpath -m $(dirname $0)/../configs)

# Read user inputs.
read -p "Enter ethereum accounts password [$KEEP_ETHEREUM_PASSWORD_DEFAULT]: " ethereum_password
KEEP_ETHEREUM_PASSWORD=${ethereum_password:-$KEEP_ETHEREUM_PASSWORD_DEFAULT}

read -p "Enter path to keep-ecdsa config files directory [$CONFIG_DIR_PATH_DEFAULT]: " config_dir_path
CONFIG_DIR_PATH=${config_dir_path:-$CONFIG_DIR_PATH_DEFAULT}

config_files=($CONFIG_DIR_PATH/*.toml)
config_files_count=${#config_files[@]}
while :
do
    printf "\nSelect client config file: \n"
    i=1
    for o in "${config_files[@]}"; do
        echo "$i) ${o##*/}"
        let i++
    done

    read reply
    if [ "$reply" -ge 1 ] && [ "$reply" -le $config_files_count ]; then
        CONFIG_FILE_PATH=${config_files["$reply"-1]}
        break
    else
        printf "\nInvalid choice. Please choose an existing option number.\n"
    fi
done
printf "\nClient config file: \"$CONFIG_FILE_PATH\" \n\n"

log_level_options=("info" "debug" "custom...")
while :
do
    echo "Select log level [$LOG_LEVEL_DEFAULT]: "
    i=1
    for o in  "${log_level_options[@]}"; do
        echo "$i) $o"
        let i++
    done

    read reply
    case $reply in
        "1"|"${log_level_options[0]}") LOG_LEVEL=${log_level_options[0]}; break;;
        "2"|"${log_level_options[1]}") LOG_LEVEL=${log_level_options[1]}; break;;
        "3"|"${log_level_options[2]}")
            read -p "Enter custom log level: [$LOG_LEVEL_DEFAULT]" log_level
            LOG_LEVEL=${log_level:-$LOG_LEVEL_DEFAULT}
            break
            ;;
        "") LOG_LEVEL=$LOG_LEVEL_DEFAULT; break;;
        *) echo "Invalid choice. Please choose an existing option number.";;
    esac
done
echo "Log level: \"$LOG_LEVEL\""

# Run script.
LOG_START='\n\e[1;36m' # new line + bold + color
LOG_END='\n\e[0m' # new line + reset color

KEEP_ECDSA_PATH=$(realpath $(dirname $0)/../)
KEEP_ECDSA_CONFIG_FILE_PATH=$(realpath $CONFIG_FILE_PATH)

printf "${LOG_START}Starting keep-ecdsa client...${LOG_END}"
cd $KEEP_ECDSA_PATH
KEEP_ETHEREUM_PASSWORD=$KEEP_ETHEREUM_PASSWORD \
    LOG_LEVEL=${LOG_LEVEL} \
    ./keep-ecdsa --config $KEEP_ECDSA_CONFIG_FILE_PATH start

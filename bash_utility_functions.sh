#!/bin/bash
#
######################################################################################################################
#                                                                                                                    #
#     Program: bash_utility_functions.sh                                                                             #
#                                                                                                                    #
#        Desc: Utility functions for your day to day bash scripts                                                    #
#                                                                                                                    #
#     Version: 0.2                                                                                                   #
#                                                                                                                    #
#        Date: 13/01/2022                                                                                            #
#                                                                                                                    #
#      Author: Prajwal Shetty D                                                                                      #
#                                                                                                                    #
######################################################################################################################
#
#------
# Name: set_colors_codes()
# Desc: Bash color codes, reference: https://misc.flogisoft.com/bash/tip_colors_and_formatting
#   In: <NA>
#  Out: <NA>
#------
function set_colors_codes(){
    # Foreground colors
    black=$'\e[30m'
    red=$'\e[31m'
    green=$'\e[1;32m'
    yellow=$'\e[1;33m'
    blue=$'\e[1;34m'
    light_blue=$'\e[94m'
    magenta=$'\e[1;35m'
    cyan=$'\e[1;36m'
    grey=$'\e[38;5;243m'
    white=$'\e[0m'
    light_yellow=$'\e[38;5;101m' 
    orange=$'\e[38;5;215m'

    # Color term
    end=$'\e[0m'

    # Background colors
    red_bg=$'\e[41m'
    green_bg=$'\e[42m'
    blue_bg=$'\e[44m'
    yellow_bg=$'\e[43m'
    darkgrey_bg=$'\e[100m'
    orange_bg=$'\e[48;5;215m'
    white_bg=$'\e[107m'

    # Manipulators
    blink=$'\e[5m'
    bold=$'\e[1m'
    italic=$'\e[3m'
    underline=$'\e[4m'

    # Reset text attributes to normal without clearing screen.
    alias reset_colors="tput sgr0" 

    # Checkmark (green)
    green_check_mark="\033[0;32m\xE2\x9C\x94\033[0m"
}
#------
# Name: replace_word()
# Desc: Replaces a word with other in a file, in place
#   In: as-is, to-be, file-name, options
#  Out: <NA>
#------
function replace_word(){
    # Input parameters
    repwrd_src_word=$1
    repwrd_tgt_word=$2
    repwrd_file=$3
    repwrd_opt=$4

	sed -i "s/\b${repwrd_src_word}\b/${repwrd_tgt_word}/g" ${repwrd_file}
}
#------
# Name: check_if_the_file_exists()
# Desc: Check if the specified file exists
#   In: file-name (multiple could be specified), additional-options (--noexit), additional-message
#  Out: <NA>
#------
function check_if_the_file_exists(){
	noexit=0
	for p in "$@"
    do
        if [[ "$p" == "--noexit" ]]; then
            noexit=1
        fi
    done
    for file in "$@"
    do
        if [ ! -f "$file" ] && [ ! "$file" == "--noexit" ] ; then
            printf "\n${red}*** ERROR: File ${black}${red_bg}$file${white}${red} was not found in the server (PWD: $PWD) *** ${white}"
			if [[ $noexit -eq 0 ]]; then
				clear_session_and_exit
			fi
        fi
        if [ "$file" == "--noexit" ] ; then
            break
        fi
    done
}
#------
# Name: check_if_the_dir_exists()
# Desc: Check if the specified directory exists
#   In: directory-name (multiple could be specified)
#  Out: <NA>
#------
function check_if_the_dir_exists(){
    for dir in "$@"
    do
        if [[ ! -d "$dir" ]]; then
            printf "${red}*** ERROR: Directory ${white}${red_bg}$dir${white}${red} was not found *** ${white}"
            exit 1
        fi
    done
}
#------
# Name: create_a_file_if_not_exists()
# Desc: This function will create a new file if it doesn't exist, that's all.
#   In: file-name (multiple files can be provided)
#  Out: <NA>
#------
function create_a_file_if_not_exists(){
    for fil in "$@"
    do
        if [[ ! -f $fil ]]; then
            echo 0 > $fil
            # Check if the file was created successfully
            if [[ ! -f $fil ]]; then
                printf "${red}*** ERROR: ${white}${red_bg}$fil${white}${red} could not be created, check the permissions *** ${white}\n"
                exit 1
            else
                chmod 775 $fil
            fi
        fi
    done
}
#------
# Name: rsync_to_local_directory()
# Desc: Sync the remote directory with local directory contents via rsync
#   In: local-directory-root, remote-directory-base-root (without the folder name), remote-server-username, remote-server-password, enable-debug (Y/N), other-options (optional)
#  Out: <NA>
#------
function rsync_directories(){
    # Input parameters
    local_dir=$1
    remote_dir=$2
    remote_server_user=$3
    remote_server_pass=$4
    enable_debug_in_rsync=$5
    other_options=$6

    # Command
    rsync_cmd="rsync -rlptzv --progress --delete"

    # Log
    printf "\n${green}Syncing ${local_dir}/* (local) <-- ${remote_dir}/* (remote: $remote_server_user@$remote_server_hostname) ${white}\n"

    # Debug 
    if [[ "$enable_debug_in_rsync" == "Y" || "$enable_debug_in_rsync" == "y"  ]]; then
        printf "${yellow}(DEBUG): ${white}$rsync_cmd ${remote_server_user}@${remote_server_hostname}:${remote_dir}${white} ${local_dir}\n"
    fi

    printf "${red}Press ENTER key to continue...${white}"
    read enter_to_continue_user_input

    # Sync
    $rsync_cmd $other_options "${remote_server_user}@${remote_server_hostname}:${remote_dir}" "${local_dir}"
}
#------
# Name: rsync_to_remote_directory()
# Desc: Sync the remote directory with local directory contents via rsync
#   In: local-directory-root, remote-directory-base-root (without the folder name), remote-server-username, remote-server-password, enable-debug (Y/N), other-options (optional)
#  Out: <NA>
#------
function rsync_to_remote_directory(){
    # Input parameters
    local_dir=$1
    remote_dir=$2
    remote_server_hostname=$3
    remote_server_user=$4
    enable_debug_in_rsync=$5
    other_options=$6

    # Command
    rsync_cmd="rsync -rlptzv --progress --delete"

    # Log
    printf "\n${green}Syncing ${local_dir} (local) --> ${remote_dir} (remote: $remote_server_user@$remote_server_hostname) ${white}\n"

    # Debug 
    if [[ "$enable_debug_in_rsync" == "Y" || "$enable_debug_in_rsync" == "y"  ]]; then
        printf "${yellow}(DEBUG): ${white}$rsync_cmd ${local_dir} ${remote_server_user}@${remote_server_hostname}:${remote_dir}${white}\n"
    fi

    printf "${red}Press ENTER key to continue...${white}"
    read enter_to_continue_user_input

    # Sync
    $rsync_cmd $other_options "${local_dir}" "${remote_server_user}@${remote_server_hostname}:${remote_dir}"
}
#------
# Name: convert_secs_to_hours_mins_secs()
# Desc: Show duration in hours, mins and seconds 
#   In: duration-in-secs,
#  Out: 
#------
function convert_secs_to_hours_mins_secs(){
    # Input parameters
    conv_s2h_duration_in_secs=$1

    # Show in hours, mins, seconds.
    conv_s2h_duration_in_hms=`printf '%dh:%dm:%ds\n' $((conv_s2h_duration_in_secs/3600)) $((conv_s2h_duration_in_secs%3600/60)) $((conv_s2h_duration_in_secs%60))`
}
#------
# Name: check_runsas_linux_program_dependencies()
# Desc: Checks if the dependencies have been installed and can install the missing dependencies automatically via "yum" 
#   In: program-name or package-name (multiple inputs could be specified)
#  Out: <NA>
#------
function check_runsas_linux_program_dependencies(){
    # Dependency checker
    if [[ "$ENABLE_RUNSAS_DEPENDENCY_CHECK" == "Y" ]]; then
        for prg in "$@"
        do
            # Defaults
            check_dependency_cmd=`which $prg`

            # Check
            printf "${white}"
            if [[ -z "$check_dependency_cmd" ]]; then
                printf "${red}\n*** ERROR: Dependency checks failed, ${white}${red_bg}$prg${white}${red} program is not found, runSAS requires this program to run. ***\n"

                # If the package installer is available try installing the missing dependency
                if [[ ! -z `which $SERVER_PACKAGE_INSTALLER_PROGRAM` ]]; then
                    printf "${green}\nPress Y to auto install $prg (requires $SERVER_PACKAGE_INSTALLER_PROGRAM and sudo access if you're not root): ${white}"
                    read read_install_dependency
                    if [[ "$read_install_dependency" == "Y" ]]; then
                        printf "${white}\nAttempting to install $prg, running ${green}sudo yum install $prg${white}...\n${white}"
                        
                        # Command 
                        sudo $SERVER_PACKAGE_INSTALLER_PROGRAM install $prg

                        # Test if it's installed now?
                        if [[ ! -z `which $SERVER_PACKAGE_INSTALLER_PROGRAM` ]]; then
                            printf "${red}\nAttempt to install the program didn't work, install the program ${yellow}$prg${white} manually (Google is your friend!) or ask server administrator.${white}\n${white}"
                            clear_session_and_exit
                        fi
                    else
                        printf "${white}Try installing this using $SERVER_PACKAGE_INSTALLER_PROGRAM, run ${green}sudo $SERVER_PACKAGE_INSTALLER_PROGRAM install $prg${white} or download the $prg package from web (Goooooogle!)"
                    fi
                else
                    printf "${green}\n$SERVER_PACKAGE_INSTALLER_PROGRAM not found, skipping auto-install.\n${white}"
                    printf "${white}\nLaunch the script after installing the ${green}$prg${white} program manually (Google is your friend!) or ask server administrator.\n${white}"
                    clear_session_and_exit
                fi
            fi
        done
    fi
}
#------
# Name: remove_double_quotes_from_file_contents()
# Desc: Removes all double quotes (") from the file contents
#   In: file-name, options (--silent)
#  Out: <NA>
#------
function remove_double_quotes_from_file_contents(){
    in_doublequotes_filename=$1
    in_doublequotes_opt=$2

    in_doublequotes_tempout_file=./.tmp_doublequotes_check
    
    check_if_the_file_exists "${in_doublequotes_filename}"

    grep -o '".*"' ${in_doublequotes_filename} | sed 's/"//g' > $in_doublequotes_tempout_file


    if [ -s $in_doublequotes_tempout_file ]; then
        if [[ ! "$in_doublequotes_opt" == "--silent" ]]; then
            printf "\n${grey}NOTE: The file ${in_doublequotes_filename} has double-quotes in its contents, cleaning up...(review the file if needed) *** ${white}\n"
        fi        

        sed -i 's/\"//g' "$in_doublequotes_filename"
    fi

    delete_a_file "${in_doublequotes_tempout_file}" --silent
}
#------
# Name: disable_keyboard_inputs()
# Desc: This function will disable user inputs via keyboard
#   In: <NA>
#  Out: <NA>
#------
function disable_keyboard_inputs(){
    # Disable user inputs via keyboard
    stty -echo < /dev/tty
}
#------
# Name: enable_keyboard_inputs()
# Desc: This function will enable user inputs via keyboard
#   In: <NA>
#  Out: <NA>
#------
function enable_keyboard_inputs(){
    # Enable user inputs via keyboard
    stty echo < /dev/tty
}
#------
# Name: disable_enter_key()
# Desc: This function will disable carriage return (ENTER key)
#   In: <NA>
#  Out: <NA>
#------
function disable_enter_key(){
    # Disable carriage return (ENTER key) during the script run
    stty igncr < /dev/tty
    # Disable keyboard inputs too if user has asked for it
    if [[ ! "$1" == "" ]]; then
        disable_keyboard_inputs
    fi
}
#------
# Name: enable_enter_key()
# Desc: This function will enable carriage return (ENTER key)
#   In: <NA>
#  Out: <NA>
#------
function enable_enter_key(){
    # Enable carriage return (ENTER key) during the script run
    stty -igncr < /dev/tty
    # Enable keyboard inputs too if user has asked for it
    if [[ ! "$1" == "" ]]; then
        enable_keyboard_inputs
    fi
}
#------
# Name: press_enter_key_to_continue()
# Desc: This function will pause the script and wait for the ENTER key to be pressed
#   In: before-newline-count, after-newline-count, color (default is green)
#  Out: <NA>
#------
function press_enter_key_to_continue(){
	# Input parameters
    ekey_newlines_before=$1
    ekey_newlines_after=$2
	ekey_color=${3:-"green"}

    # Enable carriage return (ENTER key) during the script run
    enable_enter_key
    
    # Newlines (before)
    if [[ "$ekey_newlines_before" != "" ]] && [[ "$ekey_newlines_before" != "0" ]]; then
        for (( i=1; i<=$ekey_newlines_before; i++ )); do
            printf "\n"
        done
    fi
    
    # Show message
    printf "${!ekey_color}Press ENTER key to continue...${white}"
    read enter_to_continue_user_input
    
    # Newlines (after)
    if [[ "$ekey_newlines_after" != "" ]] && [[ "$ekey_newlines_after" != "0" ]]; then
        for (( i=1; i<=$ekey_newlines_after; i++ )); do
            printf "\n"
        done
    fi
    
    # Disable carriage return (ENTER key) during the script run
    enable_enter_key
}
#------
# Name: add_html_color_tags_for_keywords()
# Desc: This adds color tags for based on the content of the file (used in email)
#   In: file-name
#  Out: <NA>
#------
function add_html_color_tags_for_keywords(){
	sed -e 's/$/<br>/'                                                                      -i  $1
	sed -e "s/ERROR/<font size=\"2\" face=\"courier\"color=\"RED\">ERROR<\/font>/g"         -i  $1
	sed -e "s/MISSING/<font size=\"2\" face=\"courier\"color=\"RED\">MISSING<\/font>/g"     -i  $1
	sed -e "s/LOCK/<font size=\"2\" face=\"courier\"color=\"RED\">LOCK<\/font>/g"           -i  $1
	sed -e "s/ABORT/<font size=\"2\" face=\"courier\"color=\"RED\">ABORT<\/font>/g"         -i  $1
	sed -e "s/WARNING/<font size=\"2\" face=\"courier\"color=\"YELLOW\">WARNING<\/font>/g"  -i  $1
	sed -e "s/NOTE/<font size=\"2\" face=\"courier\"color=\"GREEN\">NOTE<\/font>/g"         -i  $1
}
#------
# Name: add_bash_color_tags_for_keywords()
# Desc: This adds bash color tags to a keyword in a file (in file replacement)
#   In: file-name, keyword, begin-color-code, end-color-code
#  Out: <NA>
#------
function add_bash_color_tags_for_keywords(){
	sed -e "s/$2/$3$2$4/g" -i $1
}
#------
# Name: send_an_email()
# Desc: This routine will send an email alert to the intended recipient(s)
#   In: email-mode, subject-identifier, subject, to-address (separated by semi-colon), email-body-msg-html-file, 
#       optional-email-attachment-dir, optional-email-attachment, optional-from-address (separated by semi-colon), optional-to-distribution-list (separated by semi-colon)
#  Out: <NA>
#------
function send_an_email(){
# Parameters
email_mode=$1
email_subject_id=$2
email_subject=$3
email_to_address=$4
email_body_message_file=$5
email_optional_attachment_directory=$6
email_optional_attachment=$7
email_optional_from_address=$8
email_optional_to_distribution_list=$9

# Defaults (DO NOT CHANGE THIS)
email_boundary_string="ZZ_/afg6432dfgkl.94531q"

# Email files root directory (default is set to current directory)
email_html_files_root_directory=.

# HTML files
email_header_file="$email_html_files_root_directory/.email_header.html" 
email_body_file="$email_html_files_root_directory/.email_body.html"
email_footer_file="$email_html_files_root_directory/.email_footer.html"

# Do not change this
email_boundary_string="ZZ_/afg6432dfgkl.94531q"

# Check for the file size limit, if there's an attachment
if [[ "$email_optional_attachment" != "" ]]; then
	this_attachment_size=`du -b "$email_optional_attachment_directory/$email_optional_attachment" | cut -f1`
	if (( $this_attachment_size > $EMAIL_ATTACHMENT_SIZE_LIMIT_IN_BYTES )); then
        printf "${red}The log is too big for attachment ($this_attachment_size bytes). ${white}"
		email_optional_attachment=;
	fi
fi

# Customize the email content (HTML is default format used here, you could use any!) as per the customer need. 
# The email body (dynamic) will be sandwiched between header and footer
# Header 
cat << EOF > $email_header_file
<html><body>
<font face=Arial size=2>Hi,<br>
<font face=courier size=2><div style="font-size: 13; font-family: 'Courier New', Courier, monospace"><p style="color: #ffffff; background-color: #303030">
EOF
# Body (this is dynamically constructed)
# Footer
cat << EOF > $email_footer_file
</p></div></body>
<p><font face=Arial size=2>Cheers,<br>Server</p>
EOF

# Validation
if [[ "$email_to_address" == "" ]]; then
    printf "${red}*** ERROR: Recipient email address was not specified in the parameters sections of the script, review and try again. *** \n${white}"
    clear_session_and_exit
fi

# Compose the email body 
cat $email_header_file       | awk '{print $0}'  > $email_body_file
cat $email_body_message_file | awk '{print $0}' >> $email_body_file
cat $email_footer_file       | awk '{print $0}' >> $email_body_file

# Get the file contents to the variable
email_body=$(<$email_body_file)

# Build "To", "From" and "Subject"
email_from_address_complete="$EMAIL_ALERT_USER_NAME <$USER@`hostname`>"
email_to_address_complete="$email_to_address $email_optional_to_distribution_list" 
email_subject_full_line="$email_subject_id $email_subject $EMAIL_USER_MESSAGE"

# Remember the current directory and switch to attachments root directory (is switched back once the routine is complete)
curr_directory=`pwd`
cd $email_optional_attachment_directory

# Build a terminal message (first part of the message)
email_attachment_msg=
if [[ "$email_mode" != "-s" ]]; then
    printf "${grey} (An email ${white}"
    email_attachment_msg="with no attachment "
fi

# Email routine
declare -a attachments
attachments=( "$email_optional_attachment" )
{
# Do not change anything beyond this line
printf '%s\n' "FROM: $email_from_address_complete
To: $email_to_address_complete
SUBJECT: $email_subject_full_line
Mime-Version: 1.0
Content-Type: multipart/mixed; BOUNDARY=\"$email_boundary_string\"

--${email_boundary_string}
Content-Type: text/html; charset=\"US-ASCII\"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

$email_body
"
# Loop over the attachments, guess the type and produce the corresponding part, encoded base64
for attached_file in "${attachments[@]}"; do
[ ! -f "$attached_file" ] && printf "${grey}$email_attachment_msg${white}" >&2 && continue
printf '%s\n' "--${email_boundary_string}
Content-Type:text/plain; charset=\"US-ASCII\"
Content-Transfer-Encoding: base64
Content-Disposition: attachment; filename=\"$attached_file\"
"
base64 "$attached_file"
echo
done
# Print last email_boundary_string with closing --
printf '%s\n' "--${email_boundary_string}--"
} | sendmail -t -oi

# Post email alert
if [[ "$email_mode" != "-s" ]]; then
    printf "${grey}was sent to $email_to_address$email_to_distribution_list) ${white}"
    sleep 0.5
fi

# Publish
publish_to_messagebar "${grey}NOTE: $email_subject, notified $email_to_address$email_to_distribution_list via email...${white}"

# Go back to the previous directory
cd $curr_directory

# Clear the temporary files
rm -rf $email_header_file $email_body_file $email_footer_file
}
#------
# Name: move_files_to_a_directory()
# Desc: Move files to a specified directory
#   In: filename, directory-name
#  Out: <NA>
#------
function move_files_to_a_directory(){
    if [ `ls -1 $1 2>/dev/null | wc -l` -gt 0 ]; then
        mv -f $1 $2
    fi
}
#------
# Name: copy_files_to_a_directory()
# Desc: Copy files to a specified directory
#   In: filename, directory-name
#  Out: <NA>
#------
function copy_files_to_a_directory(){
    if [ `ls -1 $1 2>/dev/null | wc -l` -gt 0 ]; then
        cp $1 $2
    fi
}
#------
# Name: check_if_the_dir_exists()
# Desc: Check if the specified directory exists
#   In: directory-name (multiple could be specified)
#  Out: <NA>
#------
function check_if_the_dir_exists(){
    for dir in "$@"
    do
        if [[ ! -d "$dir" ]]; then
            printf "${red}*** ERROR: Directory ${white}${red_bg}$dir${white}${red} was not found in the server, make sure you have correctly set the script parameters as per the environment (PWD: $PWD)*** ${white}"
            clear_session_and_exit
        fi
    done
}
#------
# Name: clear_session_and_exit()
# Desc: Resets the terminal
#   In: email-short-message, email-long-message
#  Out: <NA>
#------
function clear_session_and_exit(){
    # Input parameters
    clear_session_and_exit_email_short_message=$1
    clear_session_and_exit_email_long_message=${2:-$clear_session_and_exit_email_short_message}
    clear_session_and_exit_rc=${3:-1}
    clear_session_and_exit_dont_check_files_n_processes=$4

    # Disable the keyboard
    disable_enter_key
    disable_keyboard_inputs

    # Print two newlines
    printf "${white}\n\n${white}"

    # Show cursor
    show_cursor

    # Reset the scrollable area 
    tput csr 0 $tput_lines

    # Enable enter key and keyboard inputs
    enable_enter_key
    enable_enter_key keyboard

    # Goodbye!
    exit $clear_session_and_exit_rc
}
#------
# Name: messagebar_controlseq()
# Desc: This function is called by publish_to_messagebar() 
#   In: <NA>
#  Out: <NA>
#------
function messagebar_controlseq() {
    # Save cursor position
    tput sc

    # Add a new line
    # tput il 1

    # Change scroll region to exclude the last lines
    tput csr 0 $(($(tput lines) - TERM_BOTTOM_LINES_EXCLUDE_COUNT))

    # Move cursor to bottom line
    tput cup $(tput lines) 0

    # Clear to the end of the line
    tput el

    # Echo the content on that row
    cat "${BOTTOM_LINE_CONTENT_FILE}"

    # Get the value from user via user prompt
    if [[ "$1" == "Y" ]]; then
        # Enable keyboard and user inputs
        if [[ "$3" == "" ]]; then
            enable_enter_key
        fi
        enable_keyboard_inputs
    
        # Show the prompt (add single character input overrides)
        read ${3} ${2} < /dev/tty
    else
        # Restore cursor position
        tput rc
    fi
}
#------
# Name: publish_to_messagebar()
# Desc: This function creates a message bar feature and will update the message
#   In: message, prompt-required (optional), prompt-variable (optional)
#  Out: prompt-variable (assigned if the prompt is used)
#  Ref: https://stackoverflow.com/questions/51175911/line-created-with-tput-gets-removed-on-scroll
#------
function publish_to_messagebar() {
    # Input parameters
    pubmsg_message=$1
    pubmsg_prompt_required=$2
    pubmsg_prompt_var_name=$3
    pubmsg_prompt_opt=$4

    # Get current cursor position
    get_current_terminal_cursor_position

    # Publish to the message bar
    local bottomLinePromptSeq='\[$(messagebar_controlseq)\]'

    # To the bottom lines
    if [[ "$PS1" != *$bottomLinePromptSeq* ]]
    then
        PS1="$bottomLinePromptSeq$PS1"
    fi
    if [ -z "$BOTTOM_LINE_CONTENT_FILE" ]
    then
        export BOTTOM_LINE_CONTENT_FILE="$(mktemp --tmpdir messagebar.$$.XXX)"
    fi

    # Print the message to the file
    echo -ne "$pubmsg_message" > "$BOTTOM_LINE_CONTENT_FILE"
    
    # Read the file, refresh the message bar
    messagebar_controlseq $pubmsg_prompt_required $pubmsg_prompt_var_name $pubmsg_prompt_opt

    # Restore the cursor back to the content
    move_cursor $row_pos_output_var $col_pos_output_var    
    
    # echo -ne "" > "$BOTTOM_LINE_CONTENT_FILE"
    # messagebar_controlseq $pubmsg_prompt_required $pubmsg_prompt_var_name $pubmsg_prompt_opt
}
#------
# Name: move_cursor()
# Desc: Moves the cursor to a specific point on terminal using ANSI/VT100 cursor control sequences
#   In: row-position, col-position, row-offset, col-offset
#  Out: <NA>
#------
function move_cursor(){
    # Input parameters
	target_row_pos=$1
	target_col_pos=$2
    target_row_offset=${3:-1}
    target_col_offset=${4:-1}

	# Go to the specified row (make sure no invalid position is requested)
    if [[ "$target_row_pos" != "" ]] && [[ "$target_col_pos" != "" ]] && [[ ! -z "$target_row_pos" ]] && [[ ! -z "$target_col_pos" ]]; then
        if [[ $target_row_offset -le $target_row_pos ]] && [[ $target_col_offset -le $target_col_pos ]]; then
            tput cup $((target_row_pos-target_row_offset)) $((target_col_pos-target_col_offset))
        fi
    fi
}
#------
# Name: get_current_terminal_cursor_position()
# Desc: Get the current cursor position, reference: https://stackoverflow.com/questions/2575037/how-to-get-the-cursor-position-in-bash
#   In: col-pos-output-variable-name (optional), row-pos-output-variable-name (optional)
#  Out: current_cursor_row_pos, current_cursor_col_pos
#------
function get_current_terminal_cursor_position() {
    # Input parameters
    row_pos_output_var="${1:-current_cursor_row_pos}"
    col_pos_output_var="${1:-current_cursor_col_pos}"

    # Get cursor position
    local pos
    printf "${red}"
    IFS='[;' read -p < /dev/tty $'\e[6n' -d R -a pos -rs || echo "*** ERROR: The cursor position fetch function failed with an error: $? ; ${pos[*]} ***"
    # Assign to the output variables
    eval "$row_pos_output_var=${pos[1]}"
    eval "$col_pos_output_var=${pos[2]}"
    printf "${white}"
}
#------
# Name: get_remaining_lines_on_terminal()
# Desc: Get the rows/lines remaining on screen
#   In: <NA>
#  Out: remaining_lines_in_screen
#------
function get_remaining_lines_on_terminal(){
    # Output 
    remaining_lines_in_screen=999999 # Default!

    # Calculate
    # Get current terminal positions
    get_current_terminal_cursor_position # returns $row_pos_output_var
    current_terminal_height=`tput lines`

    # Remaining lines in the screen
    if [[ "$row_pos_output_var" != "" ]] && [[ $row_pos_output_var -le $current_terminal_height ]]; then
        remaining_lines_in_screen=$((current_terminal_height-row_pos_output_var))
    fi
}
#------
# Name: get_remaining_cols_on_terminal()
# Desc: Get the cols remaining on screen
#   In: <NA>
#  Out: remaining_cols_in_screen
#------
function get_remaining_cols_on_terminal(){
    remaining_cols_in_screen=1

    # Get the current terminal cursor position
    get_current_terminal_cursor_position
    current_available_cols=`tput cols`            
    remaining_cols_in_screen=$((current_available_cols-$col_pos_output_var))
}
#------
# Name: check_terminal_size()
# Desc: This function checks the current terminal size and prompts the user to resize the screen if needed (and finally saves the current terminal size)
#   In: required-rows, required-cols
#  Out: <NA>
#------
function check_terminal_size(){
    # Input parameters
    required_terminal_rows=$1
    required_terminal_cols=$2

    # Flag
    term_req_resizing=0

    # Current terminal width
    current_term_width=`tput cols`
    current_term_height=`tput lines`

    # Hide the cursor
    hide_cursor  

    # Check (skip on batch mode)
    while [[ $current_term_width -lt $required_terminal_cols ]] || [[ $current_term_height -lt $required_terminal_rows ]]; do
        # Flag to indicate the terminal required resizing
        term_req_resizing=1

        # Hide the cursor
        hide_cursor        

        # Message
        printf "${red}*** ERROR: Terminal window too small to fit the flows, requires at least $required_terminal_cols cols x $required_terminal_rows rows terminal ***${white}"
        printf "${red} Current terminal: $current_term_width cols x $current_term_height rows). *** ${white}\n"
        printf "${red_bg}${black}Try to close side panes and zoom out by pressing CTRL key and scroll down/up using your mouse scroll wheel, script will auto-detect the right settings and resume.${white}"
        
        # Refresh
        current_term_width=`tput cols`
        current_term_height=`tput lines`

        # Clear
        clear
    done 

    # Confirm the dimensions
    if [[ $term_req_resizing -eq 1 ]]; then
        printf "${green}Good work, it's now $current_term_width cols x $current_term_height rows${white}\n"
        press_enter_key_to_continue
        clear
    fi
}
#------
# Name: show_cursor()
# Desc: Shows the cursor
#   In: <NA>
#  Out: <NA>
#------
function show_cursor(){
    setterm -cursor on
}
#------
# Name: hide_cursor()
# Desc: Hides the cursor
#   In: <NA>
#  Out: <NA>
#------
function hide_cursor(){
    setterm -cursor off
}
#------
# Name: evalf()
# Desc: Creates a dynamic variable 
#   In: parameter, key, prefix, value
#  Out: Variable format is "$prefix_$parameter_$key = $value"
#------
function evalf(){
    # Input parameters
    ev_paramater=$1
    ev_key=$2
    ev_parameter_prefix=$3
    ev_parameter_value=$4

    # Create a dynamic variable and assign the value
    eval "$ev_paramater=${ev_parameter_prefix}_${ev_key}"
    eval "${!ev_paramater}=$ev_parameter_value"
}
#------
# Name: remove_empty_lines_from_file()
# Desc: This function removes any unwanted empty lines from the file
#   In: file-name
#  Out: <NA>
#------
function remove_empty_lines_from_file(){
	sed -i '/^$/d' $1
}
#------
# Name: remove_a_line_from_file()
# Desc: Remove a line from a file
#   In: string, filename
#  Out: <NA>
#------
function remove_a_line_from_file(){
    # Input parameters
    rm_pat=$1
    rm_file=$2

    # Match and remove the line (in line edit)
    if [[ ! "$rm_pat" == "" ]]; then
        sed -i "/$rm_pat/d" $rm_file
    fi
}
#------
# Name: show_server_and_user_details()
# Desc: This function will show details about the server and the user
#   In: <NA>
#  Out: <NA> 
#------
function show_server_and_user_details(){
    printf "\n${white}The script was launched (in "${1:-'a default'}" mode with ${2:-"no"} ${3:-"filter"}) with PID $$ in $HOSTNAME on `date '+%Y-%m-%d %H:%M:%S'` by ${white}"
    printf '%s' ${white}"${SUDO_USER:-$USER}${white}"
    printf "${white} user\n${white}"
}
#------
# Name: display_progressbar_with_offset()
# Desc: Calculates the progress bar parameters (https://en.wikipedia.org/wiki/Block_Elements#Character_table & https://www.rapidtables.com/code/text/unicode-characters.html, alternative: Ã¢â€“Ë†)
#   In: steps-completed, total-steps, offset (-1 or 0), optional-message, active-color, bypass-backspacing (use it when the whole row refreshes)
#  Out: <NA>
# Note: Requries get_current_terminal_cursor_position() and move
#------
function display_progressbar_with_offset(){
    # Defaults
    progressbar_default_active_color=$DEFAULT_PROGRESS_BAR_COLOR
    progressbar_width=20
    progressbar_sleep_interval_in_secs=0.25
    progressbar_color_unicode_char=" "
    progressbar_grey_unicode_char=" "
    progress_bar_pct_symbol_length=1
    progress_bar_100_pct_length=3

    # Input parameters
    progressbar_steps_completed=$1
	progressbar_total_steps=$2
    progressbar_offset=$3
	progressbar_post_message=$4
    progressbar_color=${5:-$progressbar_default_active_color}
    progressbar_bypass_backspacing=${6:-0}   

    # Calculate the scale
    let progressbar_scale=100/$progressbar_width

    # No steps (empty job scenario needs handling)
    if [[ $progressbar_total_steps -le 0 ]]; then
        progressbar_steps_completed=1
        progressbar_total_steps=1
    fi

    # Reset (>100% scenario!)
    if [[ $progressbar_steps_completed -gt $progressbar_total_steps ]]; then
        progressbar_steps_completed=$progressbar_total_steps
    fi

    # Calculate the percentage completed
    progress_bar_pct_completed=`bc <<< "scale = 0; ($progressbar_steps_completed + $progressbar_offset) * 100 / $progressbar_total_steps / $progressbar_scale"`

    # Reset the progress bar, backspace the previously shown percentage numbers (e.g. 10) and symbol (%)
    if [[ $progressbar_bypass_backspacing -eq 0 ]]; then 
        # Bypass the backspacing operation if the whole row is being refreshed instead of just the progress bar 
        if [[ "$progress_bar_pct_completed_charlength" != "" ]] && [[ $progress_bar_pct_completed_charlength -gt 0 ]]; then
            for (( i=1; i<=$progress_bar_pct_symbol_length; i++ )); do
                printf "\b"
            done
            for (( i=1; i<=$progress_bar_pct_completed_charlength; i++ )); do
                printf "\b"
            done
        fi
    fi 

    # Calculate percentage variables
    progress_bar_pct_completed_x_scale=`bc <<< "scale = 0; ($progress_bar_pct_completed * $progressbar_scale)"`

    # Reset if the variable goes beyond the boundary values
    if [[ $progress_bar_pct_completed_x_scale -lt 0 ]]; then
        progress_bar_pct_completed_x_scale=0
    fi

    # Get the length of the current percentage
    progress_bar_pct_completed_charlength=${#progress_bar_pct_completed_x_scale}

    # When "bypass backspacing" is turned on, just backspace at the end of the progress bar update (i.e. when progressbar_offset is 0)  
    if [[ $progressbar_bypass_backspacing -eq 1 ]]; then 
        if [[ $progressbar_offset -eq 0 ]] && [[ "$progress_bar_pct_completed_charlength" != "" ]] && [[ $progress_bar_pct_completed_charlength -gt 0 ]]; then
            for (( i=1; i<=$progress_bar_pct_completed_charlength; i++ )); do
                printf "\b"
            done
        fi
    fi

    # Show the percentage on console, right justified
    printf "${!progressbar_color}${black}${progress_bar_pct_completed_x_scale}%%${white}"

    # Reset if the variable goes beyond the boundary values
    if [[ $progress_bar_pct_completed -lt 0 ]]; then
        progress_bar_pct_completed=0
    fi

    progress_bar_pct_remaining=`bc <<< "scale = 0; $progressbar_width-$progress_bar_pct_completed"`

    # Reset if the variable goes beyond the boundary values
    if [[ "$progress_bar_pct_remaining" == "" ]] || [[ $progress_bar_pct_remaining -lt 0 ]]; then
        progress_bar_pct_remaining=$progressbar_width
    fi

    # Show the completed "green" block
    if [[ $progress_bar_pct_completed -ne 0 ]]; then
        printf "${!progressbar_color}"	
        for (( i=1; i<=$progress_bar_pct_completed; i++ )); do
            printf "$progressbar_color_unicode_char"
        done	
    fi

    # Show the remaining "grey" block
    if [[ $progress_bar_pct_remaining -ne 0 ]]; then
        printf "${darkgrey_bg}"
        for (( i=1; i<=$progress_bar_pct_remaining; i++ )); do
            printf "$progressbar_color_unicode_char"
        done		
    fi
    
    # Reset the message when offset is 0 (to remove the message from last iteration, cleaning up)
    if [[ $progressbar_offset -eq 0 ]]; then
        progressbar_post_message="                                      "
    fi

    # Show the optional message after the progress bar
    if [ ! -z "$progressbar_post_message" ]; then
        printf "${white}$progressbar_post_message${end}"
    fi

    # Delay
    printf "${white}"
    sleep $progressbar_sleep_interval_in_secs

    # Erase the progress bar (reset)
    for (( i=1; i<=$progressbar_width; i++ )); do
        printf "\b"
    done

    # Width of the optional message 
    progressbar_post_message_width=${#progressbar_post_message}
    
    # Erase the optional progress bar message 
    if [ ! -z "$progressbar_post_message" ]; then
        for (( i=1; i<=$progressbar_post_message_width; i++ )); do
            printf "\b"
        done
    fi

    # Erase the percent shown in the progress bar on the last call i.e. reset the percentage variables on last iteration (i.e. when the offset is 0)
    if [[ $progressbar_offset -eq 0 ]]; then
        progress_bar_pct_completed_charlength=0
        # Remove the percentages from console
        for (( i=1; i<=$progress_bar_pct_symbol_length+$progress_bar_100_pct_length; i++ )); do
            printf "\b"
        done
    fi
}
#------
# Name: clone_a_repo()
# Desc: Clones a repo to a local directory
#   In: clone-repo-url, clone-repo-directory, clone-repo-options ("delete-repo")
#  Out: <NA>
# Note: Requries get_current_terminal_cursor_position() and move
#------
function clone_a_repo(){
    # Input parameters
    clone_repo_url=$1
    clone_repo_local_dir=${2:-"."}
    clone_repo_opt=$3

    # Git base command
    git_cmd="git clone"

    # Initialise 
    if [[ "$clone_repo_url" == "" ]]; then
        printf "${red}*** ERROR: Provide a valid repository URL ***\n${white}"
    fi  
    if [[ ! "$clone_repo_local_dir" == "." ]]; then
        cd $clone_repo_local_dir
    fi  
    if [[ "$clone_repo_opt" == "delete-repo" ]];
        rm -rf "$clone_repo_local_dir"
    fi

    # Clone
    $git_cmd "$clone_repo_url"
}
#------
# Name: add_a_newline_char_to_eof()
# Desc: This function will add a new line character to the end of file (only if it doesn't exists)
#   In: file-name
#  Out: <NA>
#------
function add_a_newline_char_to_eof(){
    # Input parameters
    file_name_to_add_eof=$1

    # Process the file
    if [ "$(tail -c1 "$file_name_to_add_eof"; echo x)" != $'\nx' ]; then     
        echo "" >> "$file_name_to_add_eof"; 
    fi
}
#------
# Name: create_a_directory_if_not_exists()
# Desc: This function will create a new directory if it doesn't exist, that's all.
#   In: dir-name
#  Out: <NA>
#------
function create_a_directory_if_not_exists(){
    # Input parameters
    dir_name=$1

    # Create a directory, if it's not present
    if [ ! -d ${dir_name} ]; then
        printf "${grey}${dir_name} is missing, creating a new directory...${white}\n";
        mkdir -p ${dir_name};
    fi

    # Check
    if [ ! -d ${dir_name} ]; then
        printf "${red}ERROR: Something went wrong, ${dir_name} directory cannot be created (invalid path OR permission issues?)${white}\n";
        exit
    fi
}
#------
# Name: delete_a_file()
# Desc: Removes/deletes file(s) 
#   In: file-name (wild-card "*" supported, multiple files not supported), post-delete-message (optional, specify "--silent" for no message post deletion), delete-options(optional), post-delete-message-color(optional)
#  Out: <NA>
#------
function delete_a_file(){
    # Parameters
    delete_filename=$1
    delete_message="${2:-...(DONE)}"
    delete_options="${3:--rf}"
    delete_message_color="${4:-green}"

    # Check if the file exists before attempting to delete it.
    if ls $delete_filename 1> /dev/null 2>&1; then
        rm $delete_options $delete_filename
        # Check if the file exists post delete
        if ls $delete_filename 1> /dev/null 2>&1; then
            printf "${red}\n*** ERROR: Delete request did not complete successfully, $delete_filename was not removed (permissions issue?) ***\n${white}"
            clear_session_and_exit
        else
            if [[ ! "$delete_message" == "--silent" ]]; then 
                printf "${!delete_message_color}${delete_message}${white}"
            fi
        fi
    else
        if [[ ! "$delete_message" == "--silent" ]]; then 
            printf "${grey}...(file does not exist, no action taken)${white}"
        fi
    fi        
}
#------
# Name: delete_a_directory_if_it_exists()
# Desc: This function will delete the specified directory if it exists
#   In: dir-name, opt (--silent)
#  Out: <NA>
#------
function delete_a_directory_if_it_exists(){
    # Input parameters
    dir_name=$1
    dir_opt=$2

    # Delete a directory if it is present
    if [ -d ${dir_name} ]; then 
        if [[ ! "$dir_name" == "" ]] && [[ ! "$dir_name" == "/" ]]; then
            rm -rf ${dir_name};
            if [[ "$dir_opt" == "" ]]; then
                printf "NOTE: Deleted ${dir_name}..."
            fi
        else
            printf "${red}ERROR: [${dir_name}] directory will NOT be deleted...${white}\n";
            exit;
        fi
    fi

    # Check
    if [ -d ${dir_name} ]; then
        printf "${red}ERROR: Something went wrong, ${dir_name} directory cannot be created (invalid path OR permission issues?)${white}\n";
        exit
    fi
}
#------
# Name: print_a_line_break()
# Desc: This prints a line break
#   In: line-break-single-char
#  Out: <NA>
#------
function print_a_line_break(){
    # Input parameters
    line_break_color=${1:-green}

    # Create a directory, if it's not present
    printf ${!line_break_color}
    printf '%.s─' $(seq 1 $(tput cols))
    printf ${end}
}
#------
# Name: print_a_timestamp()
# Desc: Formats and prints a timestamp ("mins ago or days ago" format) 
#   In: last-sync-timestamp
#  Out: <NA>
#------
function print_a_timestamp(){
    # Input parameters
    prnt_timestamp=$1
    prnt_timestamp_msg=$2

    # Calc
    if [[ $(((current_timestamp-last_sync_timestamp))) -lt 60 ]]; then
        prnt_time_elapsed_msg="$(((current_timestamp-last_sync_timestamp))) secs ago";
    elif [[ $((((current_timestamp-last_sync_timestamp)+60-1)/60)) -lt 60 ]]; then
        prnt_time_elapsed_msg="$((((current_timestamp-last_sync_timestamp)+60-1)/60)) mins ago";
    elif [[ $((((current_timestamp-last_sync_timestamp)+3600-1)/3600)) -lt 24 ]]; then
        prnt_time_elapsed_msg="$((((current_timestamp-last_sync_timestamp)+3600-1)/3600)) hours ago";
    else
        prnt_time_elapsed_msg="$((((current_timestamp-last_sync_timestamp)+86400-1)/86400)) days ago";
    fi
        
    # Print
    if [[ $last_sync_timestamp -gt 0 ]]; then 
        if [[ $OSTYPE == 'darwin'* ]]; then # macoS bash quirk!
            printf "${green}${prnt_timestamp_msg} `date -r ${last_sync_timestamp}` (i.e., ~${prnt_time_elapsed_msg})${white}\n"
        else
            printf "${green}${prnt_timestamp_msg} `date -d @${last_sync_timestamp} +"%d/%m/%Y %T"` (i.e., ~${prnt_time_elapsed_msg})${white}\n"
        fi
    else
        printf "${green}${white}\n"
    fi
}
#------
# Name: fill_up_remaining_cols_with_a_char()
# Desc: Fill up the rest of the line with a character (Ansible style)
#   In: message, character-to-fill, color, column-override
#  Out: current_cursor_row_pos, current_cursor_col_pos
#------
function fill_up_remaining_cols_with_a_char(){
    # Input parameters
    flup_msg=$1
    flup_char=${2:-"-"}
    flup_color=${!3}
    flup_col_override_pos=${4:-0}

    # Print the message
    printf "${green}${flup_msg}${white}" 

    # Get the current cursor position based on the above message, fill the rest
    get_current_terminal_cursor_position curr_cursor_row_pos curr_cursor_col_pos

    # Fill up!
    if [[ $flup_col_override_pos -eq 0 ]]; then
        cols=$(tput cols)   
    else
        cols=$flup_col_override_pos
    fi
    remaining_cols=$((cols-curr_cursor_col_pos))
    for ((i=0; i<remaining_cols; i++));do printf "${green}${flup_char}${white}"; done;
}
#------
# Name: string_to_hash()
# Desc: Creates a hash of string using md5sum utility
#   In: string, hash-output-var-name
#  Out: ${!hash-output-var-name}
#------
function string_to_hash(){
    # Input parameters
    s2h_in_string=$1
    s2h_hash_out_var_name=${2:-string_hash_out}

    # Create a hash
    if [[ $OSTYPE == 'darwin'* ]]; then # macoS bash quirk!
        eval "$s2h_hash_out_var_name=`echo ${s2h_in_string} | md5`"
    else
        eval "$s2h_hash_out_var_name=`/bin/echo ${s2h_in_string} | /usr/bin/md5sum | /bin/cut -f1 -d" "`"
    fi
}
#------
# Name: check_if_file_has_been_modified()
# Desc: This checks if the file specified has been modified 
#   In: file-name, last-sync-timestamp (%s format)
#  Out: <NA>
#------
function check_if_file_has_been_modified(){
    # Input parameters
    file_name_to_check_for_modif=$1
    last_sync_timestamp=${2:-0}

    # Check
    file_last_modified=$(date -r $file_name_to_check_for_modif +%s)
    time_in_seconds_since_last_sync=$(((file_last_modified-last_sync_timestamp)))

    if [[ $time_in_seconds_since_last_sync -gt 0 ]]; then
        printf "${red}NOTE: File ${file_name_to_check_for_modif} which is on exception list has been modified since the last sync on `date -r $last_sync_timestamp`. Upload this file manually, if needed. ${white}\n"
    fi
}
#------
# Name: check_if_file_has_been_modified_recursive()
# Desc: Checks for an existence of file, and then checks the time elapsed since the specified timestamp
#   In: search-type ("filename" or "file-list"), filename-or-listfile, timestamp, search-directory
#  Out: <NA>
#------
function check_if_file_has_been_modified_recursive(){
    # Input parameters
    filechk_input_type=${1:-"filename"}
    filechk_input_file_or_list=$2
    filechk_since_last_timestamp=${3:-0}
    filechk_srch_dir=${4:-"."}

    # Recursively check for all the files in the target directory
    if [[ "$filechk_input_type" == "file-list" ]]; then
        # A list of file is provided for check
        while IFS='' read -r filename; do
            # Loop only through the files, ignore the directories
            if [[ ! "${filename##*.}" == "" ]] && [[ ! "${filename%.*}" == "" ]]; then 
                files_found=$(find $filechk_srch_dir -type f -name "$filename")
                if [[ ! ${files_found} == "" ]]; then 
                    # Loop through the space-limited files (if there are multiple files by the same name that is)
                    for file_found in ${files_found}; do
                        check_if_file_has_been_modified "$file_found" "$filechk_since_last_timestamp"
                    done
                fi
            fi
        done < $filechk_input_file_or_list    
    else
        files_found=$(find $filechk_srch_dir -type f -name "$filename")
        if [[ ! ${files_found} == "" ]]; then
            # Loop through the space-limited files (if there are multiple files by the same name that is)
            for file_found in ${files_found}; do
                check_if_file_has_been_modified "$file_found" "$filechk_since_last_timestamp"
            done
        fi
    fi
}
#------
# Name: unzip_a_file()
# Desc: Unzips a file to a specified directory (defaults to current if unspecified)
#   In: file, target-directory, other-opts 
#  Out: <NA>
#------
function unzip_a_file(){
    # Input parameters
    uz_file="$1"
    uz_target_directory="$2"
    uz_opt="$3"

    # Process the file
    uz_base_filename=`get_file_details $uz_file "file-name"; echo $get_file_details_return_value`
    uz_file_path=`get_file_details $uz_file "file-path"; echo $get_file_details_return_value`
    uz_extension=`get_file_details $uz_file "file-extension"; echo $get_file_details_return_value`
    uz_filename_without_extension=`get_file_details $uz_file "file-name-without-extension"; echo $get_file_details_return_value`

    # Check if the file exists
    check_if_the_file_exists "$uz_file"

    # Check for valid file
    if [[ ! "${uz_extension}" == "zip" ]]; then
        printf "${red}\n*** ERROR: Invalid zip file extension (required .zip, provided [${uz_extension}]) ${white} ***"
    fi

    # Check for target directory
    if [[ "${uz_target_directory}" == "" ]]; then
        uz_target_directory="${uz_file_path}/${uz_filename_without_extension}"
    fi

     # Delete the target directory if it exists
    delete_a_directory_if_it_exists "${uz_target_directory}"

    # Unzip utility 
    uz_prg="unzip -q"

    # Unzip
    printf "${grey}Unzipping $uz_file to $uz_target_directory...\n${white}"
    $uz_prg "$uz_file" -d "$uz_target_directory" $uz_opt
}
#------
# Name: zip_contents()
# Desc: Zips the contents to a file
#   In: source-file-or-directory, target-directory, target-zip-file-name, other-options
#  Out: <NA>
#------
function zip_contents(){
    # Input parameters
    z_src="$1"
    z_target_directory="$2"
    z_target_zip_filename="$3"
    z_opt="$4"

    # Process the file
    z_base_filename=`get_file_details $z_src "file-name"; echo $get_file_details_return_value`
    z_file_path=`get_file_details $z_src "file-path"; echo $get_file_details_return_value`
    z_extension=`get_file_details $z_src "file-extension"; echo $get_file_details_return_value`
    z_filename_without_extension=`get_file_details $z_src "file-name-without-extension"; echo $get_file_details_return_value`

    # Timestamp
    curr_timestamp=`date +%Y%m%d`

    # Defaults
    if [[ "$z_target_directory" == "" ]]; then
        z_target_directory=${z_file_path}
    fi
    if [[ "$z_target_zip_filename" == "" ]]; then
        if [[ "$z_extension" == "" ]]; then
            z_target_zip_filename=${z_base_filename}
        else
            z_target_zip_filename=${z_filename_without_extension}
        fi
    fi

    # Utility
    z_prg=zip

    # Check if the target and source directories exists
    check_if_the_dir_exists ${z_target_directory} ${z_src}
 
    # Housekeeping
    delete_a_file ${z_target_directory}/${z_target_zip_filename}-${curr_timestamp}.zip --silent # if at all it exists...

    # Zip!
    echo "$z_prg -r ${z_opt} ${z_target_directory}/${z_target_zip_filename}-${curr_timestamp}.zip ${z_src}"
    $z_prg -r ${z_opt} ${z_target_directory}/${z_target_zip_filename}-${curr_timestamp}.zip ${z_src}

    # Check if the zip was created successfully.
    check_if_the_file_exists ${z_target_directory}/${z_target_zip_filename}-${curr_timestamp}.zip
}
#------
# Name: backup_directory()
# Desc: Backup a directory to a folder as tar zip with timestamp (filename_YYYYMMDD.tar.gz)
#   In: source-dir, target-dir, target-zip-file-name, other-opts
#  Out: <NA>
#------
function backup_directory(){
    # Input parameters
    bkp_src_dir=$1
    bkp_tgt_dir=$2
    bkp_tgt_zip_filename=$3
    bkp_other_opts=$4

    # Default timestamp
	curr_timestamp=`date +%Y%m%d`

    # Backup
	tar -zcf ${bkp_other_opts} ${bkp_tgt_dir}/${bkp_tgt_zip_filename}_${curr_timestamp}.tar.gz ${bkp_src_dir}
}
#------
# Name: get_file_details()
# Desc: Extracts the filename, pathname, extension and filename without extension
#   In: file, opt ("file-name-without-extension" OR "file-name" OR "file-path" OR "file-extension")
#  Out: <NA>
#------
function get_file_details(){
    # Input parameters
    gtfn_file=$1
    gtfn_opt=$2

    # Process the file
    gtfn_base_filename=$(basename -- "$gtfn_file")
    gtfn_file_path=$(dirname -- "$gtfn_file")
    gtfn_extension="${gtfn_base_filename##*.}"
    gtfn_filename_without_extension="${gtfn_base_filename%.*}"

    # Override the path
    if [[ "$gtfn_file_path" == "." ]];  then
        gtfn_file_path=$PWD
    fi

    case $gtfn_opt in   
    file-name)
        get_file_details_return_value=$gtfn_base_filename
        ;;
    file-name-without-extension)
        get_file_details_return_value=$gtfn_filename_without_extension
        ;;
    file-path)
        get_file_details_return_value=$gtfn_file_path
        ;;
    file-extension)
        get_file_details_return_value=$gtfn_extension
        ;;
    *)
        get_file_details_return_value=$gtfn_base_filename
        ;;
    esac
}
#------
# Name: print_the_current_working_directory()
# Desc: Prints the PWD
#   In: <NA>
#  Out: <NA>
#------
function print_the_current_working_directory(){
    printf "\n${grey}Present working directory has been switched to: $PWD ${white}"
}
#------
# Name: display_fillers()
# Desc: Fetch cursor position and populate the fillers
#   In: filler-character-upto-column, filler-character, optional-backspace-counts
#  Out: <NA>
#------
function display_fillers(){
        # Input parameters
        filler_char_upto_col=$1
        filler_char_to_display=$2
        pre_filler_backspace_char_count=$3
        use_preserved_filler_char_count=$4
        post_filler_backspace_char_count=$5
        filler_char_color=$6

        # Get the current cursor position
        get_current_terminal_cursor_position

        # Calculate no of fillers required to reach the specified column
        filler_char_count=$((filler_char_upto_col-current_cursor_col_pos))

        # See if a backspace is requested (pre filler)
        if [[ "$pre_filler_backspace_char_count" != "0" ]] && [[ "$pre_filler_backspace_char_count" != "" ]]; then
            for (( i=1; i<=$pre_filler_backspace_char_count; i++ )); do
                printf "\b"
            done
        fi

        # Display fillers
        if [[ "$use_preserved_filler_char_count" != "N" ]] && [[ "$use_preserved_filler_char_count" != "" ]]; then
            for (( i=1; i<=$filler_char_count_prev; i++ )); do
                printf "${!filler_char_color}$filler_char_to_display${white}" 
            done   
        else
            for (( i=1; i<=$filler_char_count; i++ )); do
                printf "${!filler_char_color}$filler_char_to_display${white}"         
            done   
        fi

        # See if a backspace is requested (post filler)
        if [[ "$post_filler_backspace_char_count" != "0" ]] && [[ "$post_filler_backspace_char_count" != "" ]]; then
            for (( i=1; i<=$post_filler_backspace_char_count; i++ )); do
                printf "\b"
            done
        fi

        # Preserve the last count
        filler_char_count_prev=$filler_char_count
    else
        printf "${!filler_char_color}...${white}"
    fi
}
#------
# Name: trim()
# Desc: trims the leading and trailing whitespaces
#   In: input-var
#  Out: <NA>
#------
function trim() {
  local var="$1"
  var="${var#"${var%%[![:space:]]*}"}" # trim leading whitespace chars
  var="${var%"${var##*[![:space:]]}"}" # trim trailing whitespace chars
  echo -n "$var"
}
#------
# Name: remove_top_x_lines()
# Desc: Removes top x number of lines
#   In: <file-name>, <no-of-lines-to-remove>
#  Out: <NA>
#------
function remove_top_x_lines(){
    tail -n +${2} ${1} > ${1}.tmp; mv ${1}.tmp ${1}
}
#------
# Name: remove_bottom_x_lines()
# Desc: Removes bottom x number of lines
#   In: <file-name>, <no-of-lines-to-remove>
#  Out: <NA>
#------
function remove_bottom_x_lines(){
   head -n -${2} ${1} > ${1}.tmp; mv ${1}.tmp ${1}
}
#------
# Name: remove_empty_lines_from_file()
# Desc: This function removes any unwanted empty lines from the file
#   In: file-name
#  Out: <NA>
#------
function remove_empty_lines_from_file(){
	sed -i '/^$/d' $1
}
#------
# Name: put_keyval()
# Desc: Stores a key-value pair in a file
#   In: key, value, file, delimeter
#  Out: <NA>
#------
function put_keyval(){
    # Input parameters
    str_key=$1
    str_val=$2
    str_file="${3:-.parms}"
    str_delim="${4:-\: }"

    # Create a file if it doesn't exist
    create_a_file_if_not_exists $str_file

    # If the file exists remove the previous entry
	if [ -f "$str_file" ]; then
        sed -i "/\b$str_key\b/d" $str_file
    fi 

	# Add the new entry (or update the entry)
    echo "$str_key$str_delim$str_val" >> $str_file # Add a new entry 

    # Remove any empty lines
    remove_empty_lines_from_file $str_file

    # Debug
    # print2debug str_key "\n*** Added key: " "(val: $str_val) to $str_file file ***"
    # print2debug str_file "---Printing state file: " "(START)---\n"
    # cat $str_file >> $RUNSAS_DEBUG_FILE
}
#------
# Name: get_keyval()
# Desc: Check job runtime for the last batch run
#   In: key, file, delimeter (optional, default is ": "), variable-name (optional, default is key)
#  Out: <NA>
#------
function get_keyval(){
    # Parameters
    ret_key=$1
    ret_file="${2:-.parms}"
    ret_delim="${3:-\: }"
    ret_var=${4:-$1}
    ret_debug=${5}

    # Debug
    # print2debug ret_key "\n*** Retreiving a key: " " with $ret_delim delimeter from $ret_file file (command: eval $ret_var=`awk -v pat="$ret_key" -F"$ret_delim" '$0~pat { print $2 }' $ret_file 2>/dev/null`) ***"
    # print2debug ret_file "---Printing state file: " "(START)---\n"
    # if [ -f "$ret_file" ]; then
    #     cat $ret_file >> $RUNSAS_DEBUG_FILE
    # fi

    # Set the value found in the file to the key
    if [ -f "$ret_file" ]; then
        remove_empty_lines_from_file $ret_file
        eval $ret_var=`awk -v pat="$ret_key" -F"$ret_delim" '$0~pat { print $2 }' $ret_file 2>/dev/null`
    fi   

    # Debug
    if [[ "$ret_debug" == "debug" ]]; then
        printf "${yellow}DEBUG keyval(key=$ret_key): [file=$ret_file | delim=$ret_delim | var=$ret_va ] ${white}\n"
    fi
}
#------
# Name: read_from_user()
# Desc: Read inputs from user, saves and retrieves previously keyed in values as defaults 
# Deps: get_keyval(), put_keyval(), set_colors_codes()
#   In: <message>, <target-variable-name>, <target-variable-default-value>, <read-func-parameters, <--skip-keyval-store>
#  Out: <NA>
#------
function read_from_user(){
    # Input
    rfu_message=${1}
    rfu_var_name=${2}
    rfu_default_value=${3}
    rfu_other_opts=${4}

    # Check for modifiers
    for mods in "$@"
    do
        if [[ "${mods}" == "--skip-keyval-store" ]]; then 
            skip_keyval_store=Y
        else
            skip_keyval_store=N
        fi
    done

    if [[ ${skip_keyval_store} == "Y" ]]; then
        read -e -p ${rfu_other_opts} "${rfu_message}: ${white}" -i "${rfu_default_value}" ${!rfu_var_name}
    else
        get_keyval ${rfu_var_name}
        read -e -p ${rfu_other_opts} "${rfu_message}: ${white}" -i "${!rfu_var_name:-$rfu_default_value}" ${rfu_var_name}
        put_keyval ${rfu_var_name} ${!rfu_var_name}
    fi
}
#------
# Name: enter_key()
# Desc: This function will enable/disable enter keys
#   In: <ON/OFF>
#  Out: <NA>
#------
function enter_key(){
    if [[ "${1}" == "OFF" ]] || [[ "${1}" == "off" ]]; then
        # Disable carriage return (ENTER key) during the script run
        stty igncr < /dev/tty
    else
        # Enable carriage return (ENTER key) during the script run
        stty -igncr < /dev/tty
    fi
}
######################################################################################################################

# Initialise
set_colors_codes
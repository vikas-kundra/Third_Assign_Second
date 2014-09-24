str_iden="ashish_key"
dir_string="sudo ssh -i $str_iden agaur@10.33.1.230 '[ -d /home/agaur/temp1 ]'"
#conn_string="ssh -i $str_iden agaur@10.33.1.230"
conn_string="ssh vikas2@192.168.0.9"

##For Parsing Input Parameters
while getopts s:u:p: opt
do
    case $opt in
        s)      serverD="$OPTARG";;
        u)      userD="$OPTARG";;
        p)      pattern="$OPTARG";;
        ?)      bad=1;;
    esac
done

echo "serverDirectory  -> $serverD" ;
echo "userDirectory    -> $userD" ;
echo "patternLength    -> $pattern" ;

len_ser=${#serverD}
echo "Length is $len_ser"

##Checking Whether Remote Destination Is not Empty
if [[ $len_ser -eq 0 ]]; then
    #statements
    echo "Server Directory is Empty"
else

if (  $conn_string "[ -d $serverD ]" ); then
    echo "Direcoty is present"
    len_user=$(echo ${#userD})
    echo "Value input is $userD"
    
    if [[ -d $userD && $len_user >0 ]]
    then
        echo "Directory is Present on Local System"
        dir_to_be_searched=$userD
        
    else
        dir_to_be_searched=$(pwd)
    fi

    echo "Value of Directory in local system is=$dir_to_be_searched"
    len_pattern=${#pattern}	
    echo "Length of patterns is $len_pattern"   
    ##Checking If Patterns i provided or not
    if [[ $len_pattern -ne 0 ]]; then
    	
        server_files=$($conn_string "cd $serverD;ls -ltr --time-style=+%s $serverD"|grep $pattern|awk -F " " '{$1=$2=$3=$4=$5=""; print $0}'|sed 's/^ *//')
        else
        server_files=$($conn_string  'cd $serverD;ls -ltr --time-style=+%s'|awk -F " " '{$1=$2=$3=$4=$5=""; print $0}'|sed 's/^ *//')
       
      
    fi

    echo "Files Recieved are "
    echo "$server_files"
    cd $dir_to_be_searched
    
    touch Local_Files
    touch Server_Files
    echo "$server_files">Server_Files
    ##COmputing Epoch Value for The Files in Local Directory
    ls -ltr --time-style=+%s $dir_to_be_searched|awk -F " " '{$1=$2=$3=$4=$5=""; print $0}'|sed 's/^ *//'>Local_Files
    touch file_to_be_copied
    ##Finding out the Difference between Two Files
    diff  Server_Files Local_Files |grep "<"|awk '{print $3}'>file_to_be_copied
   
    IFS=$'\n'
    touch file_to_be_deleted
    echo "Value for File is $server_files"
    
    ##Finding out Difference Between The Modified Times Of Server Files And Current Time
    for outdated_file in $server_files
    do
      file_val=$(echo "$outdated_file"|awk '{print $1}')
      echo "Value is $v" 
      now_date=$(date +%s)
      Actual_Diff=$((($now_date-$file_val)/3600/24))
      echo "Difference in days is $Actual_Diff"
      if [[ $Actual_Diff -eq 0 ]]; then
            echo "$outdated_file"|awk -F " " '{$1=""; print $0}'>>file_to_be_deleted
      fi      


    done
    
    #For Copying Files
    files_copied_collection=$(cat file_to_be_copied|tr '\n' ',' | sed 's/.$//')
    scp -v  vikas2@192.168.0.9:$serverD/\{$files_copied_collection\}  .
    

    ###For Deleting Files
    value_del=$(cat file_to_be_deleted)
    val=$(echo $value_del)
    #echo "Value obtained is $val"
    ssh vikas2@192.168.0.9 "cd $serverD;rm $val"

else
	
	echo "Directory is not Present!!!Exiting The Program"

fi


fi





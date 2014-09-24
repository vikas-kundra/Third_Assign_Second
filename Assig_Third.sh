str_iden="ashish_key"
dir_string="sudo ssh -i $str_iden agaur@10.33.1.230 '[ -d /home/agaur/temp1 ]'"
#conn_string="ssh -i $str_iden agaur@10.33.1.230"
conn_string="ssh vikas2@192.168.0.9"


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

if [[ $len_ser -eq 0 ]]; then
    #statements
    echo "Server Directory is Empty"
else

#echo "Input the Remote Server Directory"
#read DirPath
if (  $conn_string "[ -d $serverD ]" ); then
    echo "Direcoty is present"
    #echo "Enter The Local Directory Which Needs To be Mirrored"
    #read InputDir
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
    #echo "Enter the patteren to be seached for in file Names"
    #read pattern
    len_pattern=${#pattern}	
    echo "Length of patterns is $len_pattern"   
    if [[ $len_pattern -ne 0 ]]; then
    	echo "Inside if of ssh trarnsfer"
        server_files=$($conn_string "cd $serverD;ls -ltr --time-style=+%s $serverD"|grep $pattern|awk -F " " '{$1=$2=$3=$4=$5=""; print $0}'|sed 's/^ *//')
        #($conn_string "cd $DirPath;touch serverFile;ls -ltr|grep $pattern>serverFile")
        echo "Exiting if of ssh"
    else
        
      echo "Inside else of ssh"
        server_files=$($conn_string  'cd $serverD;ls -ltr --time-style=+%s'|awk -F " " '{$1=$2=$3=$4=$5=""; print $0}'|sed 's/^ *//')
        #($conn_string "cd $DirPath;touch serverFile;ls -ltr>serverFile")
      echo "Exiting else of ssh"
    fi

  #  scp -i ashish_key agaur@10.33.1.230:$DirPath/serverFile $dir_to_be_searched
    
   # copy_status=$?
    
    ##Removing Server File After It Has Been Copied Successfully From Server
   # if [[ $copy_status -eq 0 ]]; then
        #statements
    #    $conn_string "cd $DirPath;rm serverFile"
   # fi
    #echo "Remote Files are "
    #cat serverFile	
    echo "Files Recieved are "
    echo "$server_files"
    cd $dir_to_be_searched
    
    touch Local_Files
    touch Server_Files
    echo "$server_files">Server_Files
    ls -ltr --time-style=+%s $dir_to_be_searched|awk -F " " '{$1=$2=$3=$4=$5=""; print $0}'|sed 's/^ *//'>Local_Files
    #cat serverFile|awk '{OFS=" "}{print $6,$7,$8,$9}'>Server_Files
    #ls -ltr $dir_to_be_searched|awk '{OFS=" "}{print $6,$7,$8,$9}'>Local_Files
    #echo "###########Server Files are $server_files"
#echo $server_files>Server_Files
#

    touch file_to_be_copied
    diff  Server_Files Local_Files |grep "<"|awk '{print $3}'>file_to_be_copied
    #echo "Different Files are"
    
    

   # touch file_to_be_deleted	
   # awk -F " " '{$1=$2=$3=$4=""; print $0}'
   # outdated_files_check=$(cat serverFile|awk '{OFS="#@"}{print $6,$7,$8,$9}')
   # echo "Value For Check is $outdated_files_check"
   # for outdated_file in $outdated_files_check
   # do
    #	date_val=$(echo $outdated_file|awk -F '#@' '{print $1,$2,$3}')
        #echo "date Val is $date_val"
    #    diff=$(date -d "$date_val" +%s)
        #echo "Val is $diff"
    #    now_date=$(date +%s)
        #echo "Difference is $diff"
        #echo "Present time is $now_date"
     #   Actual_Diff=$((($now_date-$diff)/3600/24))
        #echo "Difference in days is $Actual_Diff"
      #  touch file_to_be_deleted
      #  if [[ $Actual_Diff -ge 10 ]]; then
     #   	echo $outdated_file|awk -F '#@' '{print $4}'>>file_to_be_deleted
    #    fi		


 #   done
 IFS=$'\n'
 touch file_to_be_deleted
   echo "Value for File is $server_files"
    for outdated_file in $server_files
    do
        #date_val=$(echo $outdated_file|awk -F '#@' '{print $1,$2,$3}')
        #echo "date Val is $date_val"
        #diff=$(date -d "$date_val" +%s)
      file_val=$(echo "$outdated_file"|awk '{print $1}')
      echo "Value is $v" 
        now_date=$(date +%s)
        #echo "Difference is $diff"
       # echo "Present time is $now_date"
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





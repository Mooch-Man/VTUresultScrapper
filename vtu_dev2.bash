#!/bin/sh
echo "Enter lower limit:- " 
read llt
echo "Enter upper limit:-"
read ult
echo "Enter file name:-"
read fname
if [[ $(which tesseract) == "" ]]
then
   sudo apt-get install tesseract-ocr
fi
if [[ $(which gnumeric) == "" ]]
then
   sudo apt-get install gnumeric
fi   

curl -s --cookie "PHPSESSID=gxty" http://results.vtu.ac.in/vitaviresultcbcs2018/captcha_new.php > pic 
curl -s --cookie "PHPSESSID=gxty" -d "lns=1cr17cs154&&current_url=http://results.vtu.ac.in/vitaviresultcbcs2018/index.php&&captchacode=$(tesseract pic -)" http://results.vtu.ac.in/vitaviresultcbcs2018/resultpage.php > /dev/null
usnp=${ult:0:-3}
for((a=${llt:7:-2};a<=9;a++))
{
 for((b=${llt:8:-1};b<=9;b++))
 {
  for((c=${llt:9};c<=9;c++))
  { 
   no=$usnp$a$b$c
   curl -s --cookie "PHPSESSID=gxty" http://results.vtu.ac.in/vitaviresultcbcs2018/captcha_new.php > pic ;
   res=$(echo -n $(tesseract pic -))
   response=$( curl -s --cookie "PHPSESSID=gxty" -d "lns=$no&&current_url=http://results.vtu.ac.in/vitaviresultcbcs2018/index.php&&captchacode=$(echo -n ${res:0:5})" http://results.vtu.ac.in/vitaviresultcbcs2018/resultpage.php |sed 's/<\/*[^>]*>//g')
   stud_name=$(grep  -w -s -a1 'Student Name' <<< "$response" | sed ':a;N;$!ba;s/\r/ /g' | grep -o ":.*" | sed 's/://g' )
   response=$(sed -e '/Student Name/,+2d' <<< $response)
   sem=$(grep -o "Semester :.." <<<$response |sed 's/Semester ://g')
   if ((${#stud_name} < 4))
   then
     echo "$no is invalid"
     continue; 
   fi
   echo $no
   subs=$(grep -w -b6  -E '(P|F|A|W|X)' <<< "$response" )
   subs=$(grep  -o -w -E  ' [0-9]{1,2}*...*[0-9]{1,2}|(P|F|A|W|X)' <<< "$subs" |sed 's/ //g')
   ((size=$(wc -l <<< $subs)))
   subs=$(sed "$((($size-4))),$size d" <<< $subs)
   if [[ "$(sed '1q' <<< $subs)" == *":"* ]]
   then
     subs=$(sed '1d' <<< $subs)
   fi
   for var1 in $sem
   do
      echo -n $no,$stud_name,$var1, >> $fname.csv
      i=0
      for var2 in $subs
      do
        ((i++))
        if [[ "$var2" == *"Sem"* ]]
        then
          subs=$(sed "1,$i d" <<< $subs)
          break
        fi
        echo -n $var2, >> $fname.csv
     done
     echo "" >> $fname.csv
   done
    if [[ "$ult" == "$no" ]]
   then
     ssconvert $fname.csv $fname.xlsx
     rm "$fname.csv" pic
     exit 0
   fi  
  }
 llt=0000000000000
 }
}

 



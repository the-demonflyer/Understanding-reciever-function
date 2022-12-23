folder="/home/ashik/Downloads/sample_1/Resampled"
for station in $folder/*
	
do
	for revent in $station/*.HHR.*.cut.res
	do
		#To get progress
		echo echo $revent | awk -F"/" '{print $7 , $8}'
		
		#Get corrosponding eevent for nevent
		zevent=`echo $nevent | awk -F"/" '{print $NF}' | awk -v s=$station -F"." '{print s"/"$1"."$2"."$3"."substr($4,1,2)"Z""."$5"."$6"."$7"."$8"."$9"."$10"."$11}'`
		
		echo $zevent
		#Create new filenames for revent and nevent
		revent=`echo $nevent | awk -F"/" '{print $NF}' | awk -v s=$station -F"." '{print s"/"$1"."$2"."$3"."substr($4,1,2)"R""."$5"."$6"."$7"."$8"."$9"."$10"."$11}'`
		tevent=`echo $nevent | awk -F"/" '{print $NF}' | awk -v s=$station -F"." '{print s"/"$1"."$2"."$3"."substr($4,1,2)"T""."$5"."$6"."$7"."$8"."$9"."$10"."$11}'`
		
sac<<!
READ $nevent $eevent
ROTATE TO GCP
W $revent $tevent
Q
!


	done
done

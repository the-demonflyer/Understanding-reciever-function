folder="/home/ashik/Downloads/sample_1/Modified"
for station in $folder/*
	
do
	for rf in $station/*.rf_w1.6
	do
		#To get progress
		echo  $rf | awk -F"/" '{print $7 , $8}'

sac<<!
r $rf
cut b 0 30
r 
cut off
wh
write over
q
!
	#break
	done
#break
done

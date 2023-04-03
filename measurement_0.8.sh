# /bin/bash
# $1 is time limit for the session, $2 is the CCG used for the session, $3 is the name suffix used to name the logs
# file structure should be output/nameSuffix/sessionTime/type of command/
measure(){
path="/home/nickdu/output/$3-$2/$1"
mkdir -p "$path/iperf"
mkdir -p "$path/ss"
mkdir -p "$path/iw"
iperf3 -c eecslab-11.cwru.edu -p 80 -t $1 -J --logfile "$path/iperf/$(date +"%m-%d-%T").json"&
end=$((SECONDS+$1+1))
while [ $SECONDS -lt $end ]; do
ss -int dst 192.168.230.230|sed -n '3 p'> "$path/ss/$(date +"%m-%d-%T").raw"
sudo iwconfig|grep "Noise level">"$path/iw/$(date +"%m-%d-%T").raw"
sleep 5
done
}
#init
random=$((RANDOM % 2))
if [ $random -eq 0 ]; then
    cca="cubic"
sudo sed -i "s/bbr/cubic/" /etc/sysctl.conf
else
    cca="bbr"
sudo sed -i "s/cubic/bbr/" /etc/sysctl.conf
fi
sudo sysctl -p
nameSuffix=$(date +"%m-%d-%T")
measure 1 $cca $nameSuffix 
measure 3 $cca $nameSuffix 
measure 5 $cca $nameSuffix 
measure 180 $cca $nameSuffix 

python3 /home/nickdu/output/scripts/postProcessing.py "/home/nickdu/output/$nameSuffix-$cca" 

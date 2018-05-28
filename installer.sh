#!/bin/bash
CopyFrom=`echo $PWD`

npm list -g --depth=0 > npmpackages.txt 

if grep "vue-cli" npmpackages.txt > /dev/null
then
	cd ..
	vue init webpack our-test-dokku-project
else 
	cd ..
	sudo npm install -g vue-cli
	vue init webpack our-test-dokku-project
fi


cd our-test-dokku-project

dockerfile=`echo ${CopyFrom}/Dockerfile`
Serverjs=`echo ${CopyFrom}/Server.js`

cp $dockerfile $PWD
cp $Serverjs $PWD

yarn
yarn add express ejs

sed -i -e 's/"start": "npm run dev",/"start": "node Server.js",/g' package.json

git init


docker build . 

echo Would you like to generate a SSH-KEY?
read Answer
case $Answer in
	y|yes|Y|YES)
           echo Modify the keyname only ore use your own path ${HOME}/.ssh/keyname?
           read Path
           echo Enter a comment
           read Comment
           ssh-keygen -t rsa -b 4096 -C "$Comment"  -f "$Path" -q

           cat  `echo ${Path}.pub`
           cd    `dirname ${Path}`
           touch config
           echo Hook me up with IP
           read IP
           echo Let me know about the Hostname
           read Hostname
           echo Username
           read User

           echo "host ${IP}">> config
           echo  " Hostname ${Hostname}" >> config
           echo  " IdentityFile ${Path}" >> config
           echo  " User ${User}" >> config

           ;;
    *)
     echo Have a nice day 
         
esac

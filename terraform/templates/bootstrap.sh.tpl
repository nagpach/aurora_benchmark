#!/bin/sh

sudo yum update
sudo yum install -y git automake libtool mysql-devel
cd /home/ec2-user
git clone https://github.com/akopytov/sysbench.git
cd sysbench
sh autogen.sh
sh configure
make
sudo cp sysbench/sysbench /usr/local/bin


cat <<EOF >/home/ec2-user/settings.cf
${settings}
EOF

sudo chmod +x /home/ec2-user/settings.cf

cat <<EOF >/home/ec2-user/gendata.sh
${gendata}
EOF

sudo chmod +x /home/ec2-user/gendata.sh

cat <<EOF >/home/ec2-user/runtest.sh
${runtest}
EOF

sudo chmod +x /home/ec2-user/runtest.sh

sudo chown -R ec2-user:ec2-user /home/ec2-user

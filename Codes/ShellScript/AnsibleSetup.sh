#!/bin/bash
#source コマンドで実行
#Amazon Linux2用

echo "相手のIPを入力してください"
read IP

echo "秘密鍵のパスを指定してください"
read PrivateKey

#Ansible, expectコマンドインストール
amazon-linux-extras install -y ansible2
yum install -y expect

#id_rsaキーがなければ作成
[ -f "/root/.ssh/id_rsa" ] || ssh-keygen -t rsa -b 4096 -C "Ansible_server" -f /root/.ssh/id_rsa -N ""

#接続先のEC2インスタンスで使用する公開鍵登録用のシェルスクリプト作成
cat << 'EOF' > AnsibleSet.sh
#!/bin/bash
[ $(sudo cat /root/.ssh/authorized_keys | grep -o $(awk '{print$2}' /home/ec2-user/Ansible_ServeRkey) | wc -w) -eq 0 ] && sudo sh -c 'cat /home/ec2-user/Ansible_ServeRkey >> /root/.ssh/authorized_keys'
EOF

#SSH接続
expect -c "
spawn scp -i $PrivateKey /root/.ssh/id_rsa.pub ec2-user@$IP:/home/ec2-user/Ansible_ServeRkey
expect \"no)?\"
send \"yes\n\"
expect \"$\"
send \"exit\n\"
"

#接続先でシェルスクリプト使用し、公開鍵登録
ssh -i $PrivateKey ec2-user@$IP 'sh' < AnsibleSet.sh
ssh -i $PrivateKey ec2-user@$IP 'rm -f /home/ec2-user/Ansible_ServeRkey'
[ $(cat /etc/ansible/hosts | grep $IP) = $IP ] || echo $IP >> /etc/ansible/hosts

ansible -i /etc/ansible/hosts -m ping $IP

[ -f ~/.bash_profile.bak ] || cp ~/.bash_profile{,.bak}

#Ansible関連コマンドを短縮した環境変数設定

SetEnv(){
  [ $(cat ~/.bash_profile | grep "$1" | wc -c) -eq 0 ] && echo "$1" >>  ~/.bash_profile && echo "変数設定完了　$1"
}

SetEnv "roles=/etc/ansible/roles"
SetEnv "ans='ansible-playbook -i /etc/ansible/hosts'"
SetEnv "oAns='ansible-playbook -i /etc/ansible/hosts --extra-vars ip='"

source ~/.bash_profile
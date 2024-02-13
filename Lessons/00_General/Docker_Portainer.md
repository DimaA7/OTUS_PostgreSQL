[Docker Portainer Documentation https://docs.portainer.io/](https://docs.portainer.io/)


Download the portain stack yaml that will do this for you
curl -L https://downloads.portainer.io/ce2-17/portainer-agent-stack.yml -o portainer-agent-stack.yml

run portainer
sudo docker stack deploy -c portainer-agent-stack.yml portainer
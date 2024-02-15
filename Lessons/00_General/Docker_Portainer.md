[Docker Portainer Documentation https://docs.portainer.io/](https://docs.portainer.io/)
[Using Portainer with Docker and Docker Compose](https://earthly.dev/blog/portainer-for-docker-container-management/)

Download the portain stack yaml that will do this for you
curl -L https://downloads.portainer.io/ce2-17/portainer-agent-stack.yml -o portainer-agent-stack.yml

run portainer
sudo docker stack deploy -c portainer-agent-stack.yml portainer
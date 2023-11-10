# my-ecs-container-environment
自分で考えたECSのコンテナ環境

## ビルドとECRプッシュコマンド
export AWS_ACCOUNT_ID=$(aws sts get-caller-identity --query 'Account' --output text)

docker build -t app-flask-build-container:latest -f ./docker/build/Dockerfile --platform linux/x86_64 .
docker image tag app-flask-build-container:latest ${AWS_ACCOUNT_ID}.dkr.ecr.ap-northeast-1.amazonaws.com/flask-test-app:v3
### ecr login
aws ecr get-login-password --region ap-northeast-1 | docker login --username AWS --password-stdin ${AWS_ACCOUNT_ID}.dkr.ecr.ap-northeast-1.amazonaws.com
### Push image 
docker image push ${AWS_ACCOUNT_ID}.dkr.ecr.ap-northeast-1.amazonaws.com/flask-test-app:v3
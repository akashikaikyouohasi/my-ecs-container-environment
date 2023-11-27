# my-ecs-container-environment
自分で考えたECSのコンテナ環境

## 環境変数設定
GitHubの`Secrets and variables`から設定してください！
- variable
    - AWS_ACCOUNT_ID
    - AWS_IAM_ROLE_ARN Actionsで利用するIAMロール ARN）


# 手動コマンド集
## ビルドとECRプッシュコマンド
export AWS_ACCOUNT_ID=$(aws sts get-caller-identity --query 'Account' --output text)

docker build -t app-flask-build-container:latest -f ./docker/build/Dockerfile --platform linux/x86_64 .
docker image tag app-flask-build-container:latest ${AWS_ACCOUNT_ID}.dkr.ecr.ap-northeast-1.amazonaws.com/flask-test-app:v3
### ecr login
aws ecr get-login-password --region ap-northeast-1 | docker login --username AWS --password-stdin ${AWS_ACCOUNT_ID}.dkr.ecr.ap-northeast-1.amazonaws.com
### Push image 
docker image push ${AWS_ACCOUNT_ID}.dkr.ecr.ap-northeast-1.amazonaws.com/flask-test-app:v3


## 課金リソース削除
### NATゲートウェイ
```
aws ec2 describe-nat-gateways --filter Name=state,Values=available | grep NatGatewayId | awk '{print$2}' | sed 's/^.*"\(.*\)".*$/\1/' | xargs aws ec2 delete-nat-gateway --nat-gateway-id
```
### ElasticIP
```
aws ec2 describe-addresses | grep AllocationId | awk '{print$2}'| sed 's/^.*"\(.*\)".*$/\1/'  | xargs aws ec2 release-address --allocation-id
```

### ALB
```
aws elbv2 describe-load-balancers | grep LoadBalancerArn  | awk '{print$2}'| sed 's/^.*"\(.*\)".*$/\1/'  |
xargs aws elbv2 delete-load-balancer --load-balancer-arn
```
### ECS
```
TBD
```


## 参考
ECSのIAMロール
- https://dev.classmethod.jp/articles/github-actions-ecs-ecr-minimum-iam-policy/

GitHub Actions系
- アマゾン ウェブ サービスでの OpenID Connect の構成：https://docs.github.com/ja/actions/deployment/security-hardening-your-deployments/configuring-openid-connect-in-amazon-web-services
- OIDC認証：https://zenn.dev/kou_pg_0131/articles/gh-actions-oidc-aws
- OIDC認証でECRへプッシュ：https://zenn.dev/kou_pg_0131/articles/gh-actions-ecr-push-image
- ECRのactions：https://github.com/aws-actions/amazon-ecr-login

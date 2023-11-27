## 概要
ecspressoでデプロイしてみる

## 手順
インストール
```
brew install kayac/tap/ecspresso
```
バージョン確認
```
% ecspresso version
ecspresso v2.2.4
```

何かしらでサービスを作って、タスク定義を出力
```
% ecspresso init --region ap-northeast-1 --cluster flask-test-cluster --service flask-test-ecs-service2 --config flask-app.yaml
023/11/10 23:54:21 flask-test-ecs-service2/flask-test-cluster save service definition to ecs-service-def.json
2023/11/10 23:54:21 flask-test-ecs-service2/flask-test-cluster save task definition to ecs-task-def.json
2023/11/10 23:54:21 flask-test-ecs-service2/flask-test-cluster save config to flask-app.yaml
```

定義を更新してデプロイ
```
% ecspresso deploy --config flask-app.yaml
```




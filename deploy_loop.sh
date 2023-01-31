while [ 1 ]
do
  ECR_ENDPOINT=$ECR_HOST/laa-estimate-eligibility/check-financial-eligibility-partner-ecr CIRCLE_BRANCH=el-609-hello-world CIRCLE_SHA1=3907fbfedba97661d4d2f1286f4cde99a5ab6de1 K8S_NAMESPACE=check-financial-eligibility-partner-uat bin/uat_deploy
  sleep $SLEEP_DELAY
  ECR_ENDPOINT=$ECR_HOST/laa-estimate-eligibility/check-financial-eligibility-partner-ecr CIRCLE_BRANCH=el-609-hello-world CIRCLE_SHA1=5c5331f7dd74ea78569c306767976c3188e552a5 K8S_NAMESPACE=check-financial-eligibility-partner-uat bin/uat_deploy
  sleep $SLEEP_DELAY
done

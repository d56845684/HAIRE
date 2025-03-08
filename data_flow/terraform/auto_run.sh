image_name=terraform_base:1.0
container_name=data_flow
value=$1
if [ $value == "init" ]; then
    docker rm -f $container_name
    docker run -d -v $(pwd)/credentials:/root/.aws/credentials -v $(pwd):/app -w /app --name $container_name $image_name
    docker exec $container_name terraform init
elif [ $value == "plan" ]; then
    docker exec $container_name terraform plan
elif [ $value == "apply" ]; then
    docker exec $container_name terraform apply -auto-approve
elif [ $value == "destory" ]; then
    docker exec $container_name terraform destroy -auto-approve
else 
    docker exec $container_name terraform $value
fi
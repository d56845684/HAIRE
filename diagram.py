from diagrams import Diagram, Cluster, Node, Edge
from diagrams.aws.database import RDS
from diagrams.aws.migration import DMS
from diagrams.aws.analytics import KinesisDataStreams, Glue, Kinesis
from diagrams.aws.storage import S3
from diagrams.aws.compute import Lambda, ECS, EKS, ElasticBeanstalk
from diagrams.aws.integration import SNS, SQS, Eventbridge, StepFunctions
from diagrams.aws.network import APIGateway, VPC
from diagrams.aws.ml import *
from diagrams.onprem.client import User, Users
from diagrams.generic.device import Mobile,Tablet
# 設定字體大小 (fontsize)
graph_attr = {
    "fontsize": "18"  # 整體圖的字體大小
}

node_attr = {
    "fontsize": "14"  # 節點的字體大小
}

edge_attr = {
    "fontsize": "14"  # 邊線的字體大小 (如果有邊線標籤)
}
with Diagram("",
              show=False, 
              filename="aws_architecture", 
              direction="LR", 
              graph_attr=graph_attr, 
              node_attr=node_attr, 
              edge_attr=edge_attr):
    with Cluster("Web"):
        # 前端UI
        website = ElasticBeanstalk("前端UI")
        # API
        backend_api = APIGateway("後端API")
    # 上傳後前處理
    with Cluster("Data preprocessing"):
        pdf_bucket = S3("storage")
        bucket_event = Eventbridge("Trigger")
        write2rds = StepFunctions("Data preprocessing")

    # 使用者與裝置
    user = Users("求職者")
    with Cluster("CDC"):
        # RDS 資料來源
        rds = RDS("PostgreSQL")
        # DMS 監控 RDS
        dms = DMS("DMS")

    # Kinesis & Lambda 
    with Cluster("Streaming Processing"):
        kinesis = KinesisDataStreams("Streaming")
        lambda_func = Lambda("Lambda")
    with Cluster("Models_Backend"):
        bedrock = Sagemaker("Bedrock Endpoint")
        # EC2 with AWS infertia
        aws_asci = ECS("aws inferentia")
        # 地端K8S
        k8s = EKS("Huggingface models")
        # Lambda 調用 Bedrock
    sqs1 = SQS("tmp_queue")
    with Cluster("Notification System"):
        lambda_processing = Lambda("處理結果")
        sns_de = SNS("Topic DE")
        sns_ds = SNS("Topic DS")
        sns_da = SNS("Topic DA")
    # API Gateway 與 SNS
    api_gateway = APIGateway("API Gateway")
    # 連線架構
    internal_users = User("HR、主管")
    user >> website >> backend_api >> pdf_bucket >> bucket_event >> write2rds
    write2rds >> rds >> [kinesis]
    kinesis >> lambda_func >> api_gateway
    api_gateway >> [bedrock, aws_asci, k8s]
    [bedrock, aws_asci, k8s] >> sqs1 >> lambda_processing >> [sns_de, sns_ds, sns_da] << Edge(label="subscription") << internal_users
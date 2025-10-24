# DataForge

DataForge - Scalable End to End Big data processing, visualization and Analytics platform.

Description
-----------
DataForge enables seamless, scalable data ingestion from streaming and batch sources. It provides resilient processing pipelines (Apache Kafka, AWS Lambda), storage & query layers, and visualization/analytics components so teams can ingest, transform, analyze and visualize large datasets from disparate sources.

Key highlights
- Designed to integrate 10+ disparate data feeds via resilient Kafka-based ingestion pipelines.
- Modular services for ingestion, processing, storage, and visualization.
- IaC (Terraform) for reproducible infrastructure provisioning (HCL files in /terraform).
- Polyglot codebase: TypeScript (frontend / serverless wrappers), Python (data processing, ETL), Terraform for infra.

Architecture overview
---------------------
At a high level DataForge consists of:

- Ingestion layer: Apache Kafka topics receive streaming data from sources. Connectors and producers publish to Kafka.
- Processing layer: Consumer services (Python) and AWS Lambda functions subscribe to Kafka (or via MSK or Kafka Connect) and perform transformation, enrichment, and routing to storage.
- Storage & query: Processed events are stored in S3 (raw + parquet), and optionally loaded into a query engine (AWS Athena, Redshift or similar) for analytics.
- Visualization & Analytics: A TypeScript-based web app provides dashboards, charts and exploratory tools built on the processed data. Visualizations are cached and paginated for large datasets.
- Infrastructure as Code: Terraform (HCL) modules provision networking, Kafka (MSK) or managed Kafka, Lambda functions, IAM roles, S3 buckets, and optional analytic stacks.

Repository layout
-----------------
- /terraform - Terraform modules and environment configurations (HCL)
- /services - Backend data processors (Python)
- /frontend - Dashboard and visualization app (TypeScript)
- /scripts - Utility and deployment scripts (shell, python)
- /docs - Additional documentation and diagrams

Prerequisites
-------------
- Node.js >= 16 and npm or Yarn
- Python 3.9+
- Terraform >= 1.0 (for infra provisioning)
- Docker (optional, for local Kafka using docker-compose)
- AWS CLI configured with credentials and an account with permissions to create IAM, S3, MSK, Lambda, etc.

Local development (quickstart)
------------------------------
This quickstart aims to let you run a simplified, mostly-local version of DataForge for development and testing.

1. Clone the repository

   git clone https://github.com/GabiYamato/DataForge.git
   cd DataForge

2. Install dependencies

- Frontend
  cd frontend
  npm install

- Services (Python)
  cd ../services
  python -m venv .venv
  source .venv/bin/activate
  pip install -r requirements.txt

3. Start a local Kafka (optional, recommended for end-to-end dev)

If you have Docker installed you can start a local Kafka and Zookeeper using the provided docker-compose in /scripts or /infra (if available):

  cd scripts
  docker-compose up -d kafka zookeeper

Wait until Kafka is ready.

4. Configure environment variables

Create a .env file (examples provided in .env.example or /services/config) with values for:
- KAFKA_BOOTSTRAP_SERVERS (e.g. localhost:9092)
- S3_BUCKET (localstack or real bucket)
- AWS_REGION
- Other service-specific secrets or endpoints

5. Run backend processors locally

In services/:

  source .venv/bin/activate
  python -m services.consumer --topic my-topic --group dev-group

(Adjust command if the repository has a different entrypoint: see services/README or individual service modules.)

6. Run the frontend

cd frontend
npm run dev

Open http://localhost:3000 (or the port shown) to view the dashboards. Configure the frontend to point to your local API endpoints via environment variables.

Running with AWS (dev/staging)
------------------------------
WARNING: The steps below will create cloud resources which may incur costs.

1. Prepare Terraform variables

cd terraform
cp terraform.tfvars.example terraform.tfvars
# Edit terraform.tfvars to set the environment, AWS region, bucket names and other variables.

2. Initialize and plan

tf init
terraform plan -var-file="terraform.tfvars"

3. Apply

terraform apply -var-file="terraform.tfvars"

The Terraform modules will provision network resources, S3 buckets, IAM roles, and managed Kafka (MSK) or an equivalent managed service, plus any Lambda functions and supporting resources.

4. Deploy services

- For serverless / Lambda deployments, use the deployment scripts in /scripts or a CI pipeline.
- Upload artifacts or use frameworks such as SAM, Serverless Framework, or CDK if you adapt modules.

CI/CD and testing
-----------------
- Unit tests live next to services code. Run pytest in /services.
- Frontend tests with the configured test runner (Jest/React Testing Library) via npm test in /frontend.
- We recommend setting up GitHub Actions to lint, test, and deploy branches to staging.

Troubleshooting
---------------
- Kafka local issues: check docker logs for broker/zookeeper, confirm advertised listeners and ports.
- AWS permissions: Ensure the AWS user/role running Terraform has the necessary permissions.
- Large dataset performance: Use parquet, partition by date, and limit query windows for interactive dashboards.

Contributing
------------
Contributions are welcome. Please follow these steps:
1. Open an issue describing the problem or feature.
2. Create a branch named feature/<your-name>/<short-description>.
3. Open a PR targeting main with a clear description and testing notes.

License
-------
Include the project's license here (e.g., MIT). If the repo already contains a LICENSE file, keep the same license.

Acknowledgements & Contact
--------------------------
If you have questions contact the maintainers or open an issue on the repository.

---

This README provides both a high-level overview and practical instructions to run and develop DataForge locally or on AWS. Adjust the commands and configurations to the concrete modules in this repository (for example, exact service entrypoints or terraform module names).

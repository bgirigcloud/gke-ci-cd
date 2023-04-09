#Google Kubernetes Engine Pipeline using Cloud Build
export PROJECT_ID=$(gcloud config get-value project)
export PROJECT_NUMBER=$(gcloud projects describe $PROJECT_ID --format='value(projectNumber)')
export REGION=us-central1
gcloud config set compute/region $REGION
#Run the following command to enable 
#the APIs for GKE, Cloud Build, Cloud Source Repositories and Container Analysis:
gcloud services enable container.googleapis.com \
    cloudbuild.googleapis.com \
    sourcerepo.googleapis.com \
    containeranalysis.googleapis.com

#Create an Artifact Registry Docker repository named my-repository in the 
#<filled in at lab start> region to store your container images:
gcloud artifacts repositories create my-repository \
  --repository-format=docker \
  --location=$REGION

#Create a GKE cluster to deploy the sample application 
  gcloud container clusters create hello-cloudbuild --num-nodes 1 --region $REGION
#If you have never used Git in Cloud Shell, configure it with your name and email address. 
#Git will use those to identify you as the author of the commits you will create in Cloud Shell 
  git config --global user.email "student-02-7905dbcb5fe0@qwiklabs.net"  
  git config --global user.name "student-02-7905dbcb5fe0"

# Create the Git repositories in Cloud Source Repositories
gcloud source repos create hello-cloudbuild-app
gcloud source repos create hello-cloudbuild-env
cd ~
git clone https://github.com/GoogleCloudPlatform/gke-gitops-tutorial-cloudbuild hello-cloudbuild-app

cd ~/hello-cloudbuild-app
PROJECT_ID=$(gcloud config get-value project)
git remote add google "https://source.developers.google.com/p/${PROJECT_ID}/r/hello-cloudbuild-app"
#Create a container image with Cloud Build
cd ~/hello-cloudbuild-app
COMMIT_ID="$(git rev-parse --short=7 HEAD)"
gcloud builds submit --tag="${REGION}-docker.pkg.dev/${PROJECT_ID}/my-repository/hello-cloudbuild:${COMMIT_ID}" .

#Create the Continuous Integration (CI) pipeline

mannual step 

cd ~/hello-cloudbuild-app
git push google master

#Task 5. Create the Test Environment and CD pipeline


#Grant Cloud Build access to GKE
PROJECT_NUMBER="$(gcloud projects describe ${PROJECT_ID} --format='get(projectNumber)')"
gcloud projects add-iam-policy-binding ${PROJECT_NUMBER} \
--member=serviceAccount:${PROJECT_NUMBER}@cloudbuild.gserviceaccount.com \
--role=roles/container.developer

cd ~
gcloud source repos clone hello-cloudbuild-env
cd ~/hello-cloudbuild-env
git checkout -b production
cd ~/hello-cloudbuild-env

cp ~/hello-cloudbuild-app/cloudbuild-delivery.yaml ~/hello-cloudbuild-env/cloudbuild.yaml


git add .

git commit -m "Create cloudbuild.yaml for deployment"

git checkout -b candidate

git push origin production
git push origin candidate
#Grant the Source Repository 
#Writer IAM role to the Cloud Build service account for the hello-cloudbuild-env repository:

PROJECT_NUMBER="$(gcloud projects describe ${PROJECT_ID} \
--format='get(projectNumber)')"
cat >/tmp/hello-cloudbuild-env-policy.yaml <<EOF
bindings:
- members:
  - serviceAccount:${PROJECT_NUMBER}@cloudbuild.gserviceaccount.com
  role: roles/source.writer
EOF

gcloud source repos set-iam-policy \
hello-cloudbuild-env /tmp/hello-cloudbuild-env-policy.yaml

#Create the trigger for the continuous delivery pipeline



mannul input

#Modify the continuous integration pipeline to trigger the continuous delivery pipeline.

cd ~/hello-cloudbuild-app
cp cloudbuild-trigger-cd.yaml cloudbuild.yaml

cd ~/hello-cloudbuild-app
git add cloudbuild.yaml
git commit -m "Trigger CD pipeline"

git push google master

#Task 6. Review Cloud Build Pipeline

#Task 7. Test the complete pipeline

cd ~/hello-cloudbuild-app

sed -i 's/Hello World/Hello Cloud Build/g' app.py

sed -i 's/Hello World/Hello Cloud Build/g' test_app.py

git add app.py test_app.py

git commit -m "Hello Cloud Build"

git push google master
#This triggers the full CI/CD pipeline.

#Task 8. Test the rollback








# Deploying Four Microservices Using One Helm Template

# Goal

1) Create simple deployment of ngnix using helm
2) Deploy a busybox image with init container
3) Deploy a redis image using helm (contents of the pod specification should be come from  helper.tpl file)
4) Deploy mysql database using Helm(Database user name , password from values.yaml)
5) Deploy all the above using 1 single helm chart (using umbrella chart)

# Chart Picture

parent-nginx-chart
   + Chart.yaml
   + values.yaml ------------  
   + templates               | From Values.yaml to deployment.yaml, nginx deployed
     - deployment.yaml <----- 
     - _helpers.tpl                              # This _helpers.tpl file also used to deployment template for busybox, mysql and redis
   + charts                                                   |
     1. child-busybox-chart                                   |
           + Chart.yaml                                       |
           + values.yaml                                      |
           + templates                                        |
             - deployment.yaml <------------------------------| # deployed a busybox image with InitContainer, 
             - _helpers.tpl                                   | - go to parent-nginx-chart/templates/_helpers.tpl, 46 to 49 line number
     2. child-mysql-chart                                     |
           + Chart.yaml                                       |
           + values.yaml                                      |
           + templates                                        | # deployed mysql database (Database user name, password from values.yaml)
             - deployment.yaml <------------------------------| - go to parent-nginx-chart/templates/_helpers.tpl 39 to 43 line number and 
             - _helpers.tpl                                   |   child-mysql-chart/values.yaml 79 to 81 line number
     3. child-redis-chart                                     |
           + Chart.yaml                                       |
           + values.yaml                                      |
           + templates                                        |
             - deployment.yaml <------------------------------| # deployed a redis image (contents of the pod specification come from helper.tpl)
             - _helpers.tpl                                     - go to parent-nginx-chart/templates/_helpers.tpl, 26 and 33 line number


# Deploy all the above using 1 single helm chart (using umbrella chart) 

/home/parent-nginx-chart
RUN : helm install --dry-run --debug complex-chart .
RUN : helm install complex-chart .

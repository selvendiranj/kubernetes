kubectl create namespace ag1

kubectl create secret generic sql-secrets --from-literal=sapassword="<C0mplexPwd>" --from-literal=masterkeypassword="<C0mplexPwd>" --namespace ag1

kubectl apply -f 1.StorageClass.yaml --namespace ag1

kubectl apply -f 2.pv.yaml --namespace ag1

kubectl apply -f 3.operator.yaml --namespace ag1

kubectl apply -f 4.sqlserver.yaml --namespace ag1

kubectl apply -f 5.ag-services.yaml --namespace ag1

# 1. L'application (le cerveau et les bras)
kubectl delete deployment postgresql-deployment

# 2. Le réseau (la porte d'entrée)
kubectl delete service postgresql-service

# 3. La sécurité (les clés)
kubectl delete secret postgres-secret

# 4. Le stockage (les données)
kubectl delete pvc postgres-pvc
kubectl delete pv postgres-pv

# 1. Le Stockage (On prépare le disque dur virtuel)
kubectl apply -f deployment/pv.yaml
kubectl apply -f deployment/pvc.yaml

# 2. La Sécurité / Configuration (On charge les variables et mots de passe)
# Note : Si tu as un fichier secret.yaml, applique-le ici.
kubectl apply -f deployment/configmap.yaml

# créer un secret
kubectl apply -f deployment/secret.yaml

# 3. L'Application (On lance les Pods de la base de données)
kubectl apply -f deployment/postgresql-deployment.yaml

# 4. Le Réseau (On ouvre les ports pour rendre l'appli accessible)
kubectl apply -f deployment/postgresql-service.yaml

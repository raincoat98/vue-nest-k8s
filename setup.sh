#!/bin/bash

set -e  # 오류 발생 시 스크립트 중단

# 0. 기존 컨테이너와 네트워크 정리
echo "🧹 기존 컨테이너와 네트워크 정리 중..."
docker stop $(docker ps -q) || true
docker rm $(docker ps -a -q) || true
docker network rm app-network || true

# 1. 도커 이미지 빌드
echo "🏗️ PostgreSQL 이미지 빌드 중..."
cd postgres
docker build -t postgres-image:latest .
cd ..

echo "🏗️ 백엔드 이미지 빌드 중..."
cd backend
docker build -t backend-image:latest .
cd ..

echo "🏗️ 프론트엔드 이미지 빌드 중..."
cd frontend
docker build -t frontend-image:latest .
cd ..

# 2. Minikube 초기화
echo "🔄 Minikube 초기화 중..."
minikube stop || true
minikube delete || true
rm -rf ~/.minikube || true
rm -rf ~/.kube || true

# 3. Minikube 시작
echo "🚀 Minikube 시작 중..."
minikube start --driver=docker --cpus=2 --memory=4096

# 4. Ingress 애드온 활성화
echo "🔌 Ingress 애드온 활성화 중..."
minikube addons enable ingress

# 5. Ingress 컨트롤러가 준비될 때까지 대기
echo "⏳ Ingress 컨트롤러 준비 대기 중..."
sleep 10
kubectl wait --namespace ingress-nginx \
  --for=condition=ready pod \
  --selector=app.kubernetes.io/component=controller \
  --timeout=120s

# 6. 이미지를 Minikube로 로드
echo "📥 도커 이미지를 Minikube로 로드 중..."
echo "프론트엔드 이미지 로드 중..."
minikube image load frontend-image:latest || echo "프론트엔드 이미지 로드 실패"
echo "백엔드 이미지 로드 중..."
minikube image load backend-image:latest || echo "백엔드 이미지 로드 실패"
echo "PostgreSQL 이미지 로드 중..."
minikube image load postgres-image:latest || echo "PostgreSQL 이미지 로드 실패"

# 이미지 로드 확인
echo "📋 로드된 이미지 확인 중..."
minikube image list

# 7. PostgreSQL 비밀번호를 위한 Secret 생성
echo "🔐 PostgreSQL Secret 생성 중..."
kubectl apply -f k8s/postgres-secret.yml || true

# 8. PostgreSQL 배포
echo "📦 PostgreSQL 배포 중..."
kubectl apply -f k8s/postgres-pvc.yaml
kubectl apply -f k8s/postgres-deployment.yaml

# 9. PostgreSQL이 준비될 때까지 대기
echo "⏳ PostgreSQL 준비 대기 중..."
kubectl wait --for=condition=ready pod -l app=postgres --timeout=120s

# 10. Backend 배포
echo "📦 Backend 배포 중..."
kubectl apply -f k8s/backend-deployment.yaml

# 11. Frontend 배포
echo "📦 Frontend 배포 중..."
kubectl apply -f k8s/frontend-deployment.yaml

# 12. Ingress 리소스 배포
echo "🌐 Ingress 리소스 배포 중..."
kubectl apply -f k8s/ingress-resource.yaml

# 13. Kubernetes 서비스 상태 확인
echo "🔍 Kubernetes 서비스 상태 확인 중..."
kubectl get pods
kubectl get services
kubectl get ingress

# 14. Kubernetes 접속 정보 출력
echo "🌍 Kubernetes 서비스 접속 정보"
echo "Ingress IP: $(minikube ip)"
echo "프론트엔드 접속: http://$(minikube ip)/"
echo "백엔드 API 접속: http://$(minikube ip)/api"
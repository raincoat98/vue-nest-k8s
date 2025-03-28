#!/bin/bash

set -e  # 오류 발생 시 스크립트 중단

# 0. 삭제 (기존 배포된 리소스 삭제)
echo "🗑️ 기존 배포 삭제 중..."
kubectl delete deployment --all || true
kubectl delete service --all || true
kubectl delete pvc --all || true
kubectl delete pv --all || true

# 1. Minikube 시작
echo "🚀 Minikube 시작 중..."
minikube start --driver=docker --cpus=2 --memory=4096

# 2. 도커 이미지 빌드
echo "🏗️ Frontend 도커 이미지 빌드 중..."
cd frontend
docker build -t frontend-image:latest .
cd ..

echo "🏗️ Backend 도커 이미지 빌드 중..."
cd backend
docker build -t backend-image:latest .
cd ..

echo "🏗️ PostgreSQL 도커 이미지 빌드 중..."
cd postgres
docker build -t postgres:13 .
cd ..

# 3. 이미지를 Minikube로 로드
echo "📥 도커 이미지를 Minikube로 로드 중..."
minikube image load frontend-image:latest
minikube image load backend-image:latest
minikube image load postgres:17

# 2. PostgreSQL 비밀번호를 위한 Secret 생성
echo "🔐 PostgreSQL Secret 생성 중..."
kubectl apply -f k8s/postgres-secret.yml || true

# 4. PostgreSQL 배포
echo "📦 PostgreSQL 배포 중..."
kubectl apply -f k8s/postgres-pvc.yaml
kubectl apply -f k8s/postgres-deployment.yaml

# 5. Backend 배포
echo "📦 Backend 배포 중..."
kubectl apply -f k8s/backend-deployment.yaml

# 6. Frontend 배포
echo "📦 Frontend 배포 중..."
kubectl apply -f k8s/frontend-deployment.yaml

# 7. 서비스 상태 확인
echo "🔍 서비스 상태 확인 중..."
kubectl get pods
kubectl get services

# 8. 서비스 확인
echo "🔍 클러스터 내 모든 서비스 확인"
kubectl get svc
minikube service list
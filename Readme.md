# Vue + NestJS + PostgreSQL + Kubernetes 프로젝트

## 1. 프로젝트 개요

이 프로젝트는 Vue(프론트엔드) + NestJS(백엔드) + PostgreSQL(데이터베이스)로 구성된 애플리케이션을 Kubernetes(Minikube) 환경에서 실행하는 예제입니다.

---

## 2. 프로젝트 구조

```
vue-nest-k8s
├── backend            # NestJS 백엔드
│   ├── src/          # 소스 코드
│   ├── Dockerfile    # 백엔드 도커 이미지 설정
│   └── .env          # 환경 변수 설정
├── frontend          # Vue 프론트엔드
│   ├── src/         # 소스 코드
│   └── Dockerfile   # 프론트엔드 도커 이미지 설정
├── k8s               # Kubernetes 설정 파일
│   ├── backend-deployment.yaml
│   ├── frontend-deployment.yaml
│   ├── postgres-deployment.yaml
│   └── postgres-secret.yml
├── setup.sh          # Minikube 실행 및 배포 스크립트
└── README.md
```

---

## 3. 실행 방법

### 3.1 Docker 및 Minikube 실행

먼저 Docker가 실행 중인지 확인합니다.

```bash
docker info
```

만약 실행되지 않았다면, macOS에서는 다음 명령어를 사용합니다.

```bash
open -a Docker
```

Docker가 실행된 후, Minikube를 시작합니다.

```bash
minikube start --driver=docker --cpus=2 --memory=4096
```

---

### 3.2 프로젝트 배포 (자동 스크립트 실행)

프로젝트를 실행하는 간단한 방법은 `setup.sh` 스크립트를 실행하는 것입니다.

```bash
chmod +x setup.sh  # 실행 권한 부여
./setup.sh  # 실행
```

이 스크립트는 다음 작업을 수행합니다.

- 기존 배포된 리소스 삭제
- Minikube 시작
- Docker 이미지 빌드 (프론트엔드, 백엔드, PostgreSQL)
- Kubernetes 배포
- 서비스 상태 확인

---

## 4. 접속 방법

### 4.1 프론트엔드 접속

프론트엔드는 다음 URL로 접속할 수 있습니다:

```
http://localhost:30000
```

### 4.2 백엔드 API 접속

백엔드 API는 다음 URL로 접속할 수 있습니다:

```
http://localhost:30001
```

### 4.3 PostgreSQL 접속

PostgreSQL Pod 이름을 확인한 후, 내부에서 데이터베이스에 접속합니다.

```bash
kubectl get pods  # PostgreSQL Pod 이름 확인
kubectl exec -it postgres-xxxxx-yyyyy -- psql -U postgres -d postgres
```

또는 로컬에서 PostgreSQL에 접속하려면 포트 포워딩을 설정합니다.

```bash
kubectl port-forward deployment/postgres 5432:5432
```

이후 DB 클라이언트(DBeaver, pgAdmin)에서 다음 정보로 접속합니다.

- **Host**: `localhost`
- **Port**: `5432`
- **Username**: `postgres`
- **Password**: `postgres`
- **Database**: `postgres`

---

## 5. 환경 변수 설정

### 5.1 백엔드 환경 변수

백엔드의 `.env` 파일에 다음 환경 변수들이 설정되어 있습니다:

```
DB_HOST=postgres
DB_PORT=5432
DB_USER=postgres
DB_PASSWORD=postgres
DB_NAME=postgres
CORS_ORIGIN=http://localhost:30000
API_URL=http://localhost:30001
```

---

## 6. 문제 해결

### 6.1 서비스 상태 확인

```bash
kubectl get pods
kubectl get services
```

### 6.2 로그 확인

```bash
# 백엔드 로그
kubectl logs deployment/backend

# 프론트엔드 로그
kubectl logs deployment/frontend

# PostgreSQL 로그
kubectl logs deployment/postgres
```

### 6.3 재배포

문제가 발생한 경우 다음 명령어로 재배포할 수 있습니다:

```bash
./setup.sh
```

---

## 7. 개발 환경

- Node.js: v20
- Vue.js: 최신 버전
- NestJS: 최신 버전
- PostgreSQL: 13
- Kubernetes: Minikube
- Docker: 최신 버전

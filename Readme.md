# Vue + NestJS + PostgreSQL + Kubernetes 프로젝트

## 1. 프로젝트 개요

이 프로젝트는 Vue(프론트엔드) + NestJS(백엔드) + PostgreSQL(데이터베이스)로 구성된 애플리케이션을 Kubernetes(Minikube) 환경에서 실행하는 예제입니다.

---

## 2. 프로젝트 구조

```
vue-nest-k8s
├── backend            # NestJS 백엔드
├── frontend           # Vue 프론트엔드
├── k8s                # Kubernetes 설정 파일
│   ├── backend-deployment.yaml
│   ├── frontend-deployment.yaml
│   ├── postgres-deployment.yaml
│   ├── backend-service.yaml
│   ├── frontend-service.yaml
│   ├── postgres-service.yaml
├── setup.sh           # Minikube 실행 및 배포 스크립트
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
minikube start --driver=docker
```

---

### 3.2 프로젝트 배포 (자동 스크립트 실행)

프로젝트를 실행하는 간단한 방법은 `setup.sh` 스크립트를 실행하는 것입니다.

```bash
chmod +x setup.sh  # 실행 권한 부여
./setup.sh  # 실행
```

이 스크립트는 다음 작업을 수행합니다.

- Minikube 시작
- Docker 환경 설정
- 백엔드 및 프론트엔드 Docker 이미지 빌드
- Kubernetes 배포
- 서비스 URL 출력

---

## 4. 개별 실행 방법 (수동 배포)

### 4.1 Docker 이미지 빌드

```bash
eval $(minikube docker-env)  # Minikube 내부에서 로컬 빌드 활성화
docker build -t backend-image:latest ./backend
docker build -t frontend-image:latest ./frontend
```

### 4.2 Kubernetes 배포

```bash
kubectl apply -f k8s/postgres-deployment.yaml
kubectl apply -f k8s/backend-deployment.yaml
kubectl apply -f k8s/frontend-deployment.yaml
```

---

## 5. 접속 방법

### 5.1 프론트엔드 접속

```bash
minikube service frontend --url
```

출력된 URL을 브라우저에서 열어 Vue 애플리케이션을 확인합니다.

### 5.2 백엔드 (NestJS) API 확인

```bash
minikube service backend --url
```

출력된 URL을 Postman 또는 브라우저에서 호출하여 API 응답을 확인합니다.

### 5.3 PostgreSQL 접속

PostgreSQL Pod 이름을 확인한 후, 내부에서 데이터베이스에 접속합니다.

```bash
kubectl get pods  # PostgreSQL Pod 이름 확인
kubectl exec -it postgres-xxxxx-yyyyy -- psql -U postgres -d nestjs
```

또는 로컬에서 PostgreSQL에 접속하려면 포트 포워딩을 설정합니다.

```bash
kubectl port-forward deployment/postgres 5432:5432
```

이후 DB 클라이언트(DBeaver, pgAdmin)에서 다음 정보로 접속합니다.

- **Host**: `localhost`
- **Port**: `5432`
- **Username**: `postgres`
- **Password**: `password`
- **Database**: `nestjs`

---

## 6. Minikube 실행 오류 해결 방법 (Mac M1/M2)

Minikube 실행 시 `Cannot connect to the Docker daemon` 및 `connect: connection refused` 오류가 발생하는 경우, 아래 해결 방법을 순서대로 시도해보세요.

### **6.1 Docker 데몬이 실행 중인지 확인**

```bash
docker info
```

만약 실행 중이 아니라면, Docker를 실행합니다.

```bash
open -a Docker
```

완전히 실행될 때까지 기다린 후 다시 Minikube를 시작해보세요.

```bash
minikube delete
minikube start --driver=docker
```

### **6.2 Minikube 드라이버 변경**

Mac M1/M2에서는 `docker` 드라이버 대신 `hyperkit` 또는 `virtualbox` 드라이버를 사용할 수 있습니다.

#### **Hyperkit 드라이버 사용**

```bash
brew install hyperkit
minikube start --driver=hyperkit
```

#### **VirtualBox 드라이버 사용**

```bash
brew install --cask virtualbox
minikube start --driver=virtualbox
```

### **6.3 Minikube 환경 초기화 후 다시 실행**

```bash
minikube stop
minikube delete
rm -rf ~/.minikube
rm -rf ~/.kube
minikube start --driver=docker
```

### **6.4 Minikube와 Kubernetes 버전 확인**

```bash
minikube version
kubectl version --client
```

최신 버전으로 업데이트 후 다시 실행해보세요.

```bash
brew upgrade minikube
brew upgrade kubectl
minikube delete
minikube start --driver=docker
```

### **6.5 Minikube 강제 재설정**

```bash
minikube stop
minikube delete
rm -rf ~/.minikube
minikube start --force --driver=docker
```

---

### **7. 최종 실행 확인**

위 단계를 수행한 후 다시 `setup.sh` 실행:

```bash
chmod +x setup.sh
./setup.sh
```

그리고 Minikube 상태를 확인합니다.

```bash
minikube status
```

정상적으로 실행되었다면 서비스 URL을 확인하세요.

```bash
minikube service frontend --url
minikube service backend --url
```

이제 Vue + NestJS + PostgreSQL 프로젝트를 Kubernetes 환경에서 실행하고 관리할 수 있습니다! 🚀

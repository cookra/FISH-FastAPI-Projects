# 🚀 MMFFDev FastAPI Project Generator

FastAPI Python Docker Fish Shell

A powerful, interactive FastAPI project generator that creates production-ready APIs with Docker support, Git integration, and MMFFDev branding.

## ✨ Features

- 🚀 **Interactive CLI** - Guided prompts with validation for project name, port, Docker, and Git
- 📁 **Smart Structure** - Production-ready project layout with separation of concerns (api, core, models, schemas, services)
- 🐳 **Docker Support** - Containerization with multi-stage builds, health checks, and docker-compose
- 🔧 **Git Integration** - Automatic repository initialization with dev branch creation and checkout
- 🎨 **MMFFDev Branding** - Customized API titles, welcome messages, and response formatting
- 📝 **Auto Documentation** - Generated README, Swagger UI at /docs, and ReDoc at /redoc
- ✅ **Input Validation** - Prevents common mistakes with proper error messages and suggestions
- 🔄 **Auto-Reload** - Development server with hot reload for rapid development
- 🧪 **Test Scripts** - Built-in API testing script to verify all endpoints
- 🐚 **Fish Shell Optimized** - Beautiful colored output and native Fish syntax

## 🚀 Quick Start

### Prerequisites
- Python 3.9+
- Fish Shell
- Docker (optional)
- Git (optional)

### Create Your First Project

>./new-fastapi.fish

# Follow the prompts:
# 📁 Enter project name: myawesomeapi
# 🔌 Enter port number [default: 8000]: 
# 🐳 Include Docker support? [default: y]: y
# 🔧 Initialize Git repository? [default: y]: y
# 🌿 Create Dev branch? [default: y]: y

>cd ~/Documents/FastAPI\ Projects/MyNewAPI
>./scripts/run.fish
>./scripts/docker-run.sh
>./scripts/test.fish
>open http://localhost:8000/docs

### Project Structure
your-project-name/
├── app/
│   ├── api/
│   │   └── routes.py
│   ├── core/
│   │   └── config.py
│   ├── models/
│   ├── schemas/
│   ├── services/
│   └── utils/
├── scripts/
│   ├── docker-run.sh
│   ├── run.fish
│   └── test.fish
├── tests/
├── main.py
├── requirements.txt
├── .env
├── .env.example
├── Dockerfile
├── docker-compose.yml
├── .dockerignore
├── .gitignore
└── README.md

### Configuration

!!! Edit: new-fastapi.fish

set -g STUDIO_NAME "MMFFDev"
set -g DEFAULT_GREETING "Welcome to the MMFFDev"
set -g DEFAULT_PORT 8000
set -g API_VERSION "1.0.0"
set -g BASE_DIR ~/Documents/FastAPI\ Projects

### Docker Commands
>docker-compose up -d
>docker-compose logs -f
>docker-compose down
.docker-compose up -d --build

### Testing
>./scripts/test.fish
>curl http://localhost:8000/
>curl http://localhost:8000/health
>curl http://localhost:8000/api/info
>curl "http://localhost:8000/items/42?q=test"

### Contributing
>docker-compose up -d
>docker-compose logs -f
>docker-compose down
>docker-compose up -d --build

### Licensing
MIT © MMFFDev

Contact
code@mmffdev.com
https://github.com/cookra/FISH-FastAPI-Projects
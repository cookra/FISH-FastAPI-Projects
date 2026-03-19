#!/usr/bin/env fish

# =============================================================================
# FastAPI Project Generator
#=============================================================================
# Creates new FastAPI projects in ~/Documents/FastAPI Projects/
# =============================================================================

# =============================================================================
# CONFIGURATION VARIABLES
# =============================================================================
set -g STUDIO_NAME "MMFFDev"
set -g DEFAULT_GREETING "Welcome to the MMFFDev"
set -g DEFAULT_PORT 8000
set -g API_VERSION "1.0.0"
set -g BASE_DIR ~/Documents/FastAPI\ Projects

function print_header
    echo ""
    echo "🚀 FastAPI Project Generator"
    echo "================================"
    echo "Projects will be created in: $BASE_DIR"
    echo ""
end

function print_error
    set_color red
    echo "❌ $argv"
    set_color normal
end

function print_success
    set_color green
    echo "✅ $argv"
    set_color normal
end

function print_info
    set_color blue
    echo "ℹ️ $argv"
    set_color normal
end

# Function to create a prompt that shows the question
function prompt_question
    echo -n -s $argv[1]
end

# Start
print_header

# =============================================================================
# Step 1: Get and validate project name
# =============================================================================

while true
    read -p "prompt_question '📁 Enter project name: '" project_name
    
    # Check if empty
    if test -z "$project_name"
        print_error "Project name cannot be empty"
        continue
    end
    
    # Remove spaces and special characters (allow only letters, numbers, hyphens, underscores)
    set clean_name (echo $project_name | sed 's/[^a-zA-Z0-9_-]//g')
    
    if test "$clean_name" != "$project_name"
        print_error "Project name can only contain letters, numbers, hyphens, and underscores"
        echo "Suggested: $clean_name"
        continue
    end
    
    # Check if directory already exists
    set project_dir "$BASE_DIR/$project_name"
    if test -d "$project_dir"
        print_error "Directory already exists: $project_dir"
        read -p "prompt_question '❓ Overwrite? (y/n): '" overwrite
        if test "$overwrite" = "y"
            rm -rf "$project_dir"
            break
        else
            continue
        end
    else
        break
    end
end

print_success "Project name accepted: $project_name"

# =============================================================================
# Step 2: Get and validate port number
# =============================================================================

while true
    read -p "prompt_question '🔌 Enter port number [default: $DEFAULT_PORT]: '" port_input
    
    # Use default if empty
    if test -z "$port_input"
        set port $DEFAULT_PORT
        print_info "Using default port: $port"
        break
    end
    
    # Check if it's a number
    if not string match -q -r '^[0-9]+$' "$port_input"
        print_error "Port must be a number"
        continue
    end
    
    # Check port range (1-65535)
    if test "$port_input" -lt 1 -o "$port_input" -gt 65535
        print_error "Port must be between 1 and 65535"
        continue
    end
    
    # Check if port is in common reserved range (optional)
    if test "$port_input" -lt 1024
        print_info "Note: Ports below 1024 may require sudo privileges"
    end
    
    set port $port_input
    break
end

print_success "Using port: $port"

# =============================================================================
# Step 3: Ask about Docker
# =============================================================================

while true
    read -p "prompt_question '🐳 Include Docker support? (y/n) [default: y]: '" docker_choice
    
    if test -z "$docker_choice"
        set docker_choice "y"
    end
    
    if test "$docker_choice" = "y" -o "$docker_choice" = "n"
        break
    else
        print_error "Please enter 'y' or 'n'"
    end
end

if test "$docker_choice" = "y"
    set include_docker true
    print_success "Docker support enabled"
    
    # Convert project name to lowercase for Docker compatibility
    set docker_name (echo $project_name | tr '[:upper:]' '[:lower:]')
    print_info "Docker will use lowercase name: $docker_name"
else
    set include_docker false
    print_info "Skipping Docker setup"
end

# =============================================================================
# Step 4: Ask about Git
# =============================================================================

while true
    read -p "prompt_question '🔧 Initialize Git repository? (y/n) [default: y]: '" git_choice
    
    if test -z "$git_choice"
        set git_choice "y"
    end
    
    if test "$git_choice" = "y" -o "$git_choice" = "n"
        break
    else
        print_error "Please enter 'y' or 'n'"
    end
end

if test "$git_choice" = "y"
    set include_git true
    
    # Check if git is installed
    if not command -v git > /dev/null
        print_error "Git is not installed. Please install Git first."
        set include_git false
    else
        print_success "Git will be initialized"
        
        # Ask about branch strategy
        while true
            read -p "prompt_question '🌿 Create Dev branch and checkout? (y/n) [default: y]: '" branch_choice
            if test -z "$branch_choice"
                set branch_choice "y"
            end
            if test "$branch_choice" = "y" -o "$branch_choice" = "n"
                break
            else
                print_error "Please enter 'y' or 'n'"
            end
        end
        
        if test "$branch_choice" = "y"
            set create_dev_branch true
        else
            set create_dev_branch false
        end
    end
else
    set include_git false
    print_info "Skipping Git setup"
end

# =============================================================================
# Step 5: Create project directory and structure
# =============================================================================

echo ""
print_info "Creating project: $project_name"
print_info "Location: $project_dir"

# Create main project directory
mkdir -p "$project_dir"
cd "$project_dir"

# Create basic structure
mkdir -p app/api/routes
mkdir -p app/core
mkdir -p app/models
mkdir -p app/schemas
mkdir -p app/services
mkdir -p app/utils
mkdir -p tests
mkdir -p scripts

print_success "Project structure created"

# =============================================================================
# Step 6: Generate Python files
# =============================================================================

echo ""
print_info "Generating Python files..."

# Create requirements.txt
echo "fastapi>=0.104.0" > requirements.txt
echo "uvicorn[standard]>=0.24.0" >> requirements.txt
echo "pydantic>=2.4.0" >> requirements.txt
echo "pydantic-settings>=2.0.0" >> requirements.txt
echo "python-dotenv>=1.0.0" >> requirements.txt

# Create main.py
echo '"""' > main.py
echo 'Main application entry point.' >> main.py
echo '"""' >> main.py
echo 'from fastapi import FastAPI' >> main.py
echo 'from fastapi.middleware.cors import CORSMiddleware' >> main.py
echo 'from app.api.routes import api_router' >> main.py
echo 'from app.core.config import settings' >> main.py
echo '' >> main.py
echo '# Create FastAPI app' >> main.py
echo 'app = FastAPI(' >> main.py
echo "    title=\"$STUDIO_NAME | $project_name | FastAPI\"," >> main.py
echo '    description="API generated by FastAPI Project Generator",' >> main.py
echo "    version=\"$API_VERSION\"," >> main.py
echo '    docs_url="/docs",' >> main.py
echo '    redoc_url="/redoc"' >> main.py
echo ')' >> main.py
echo '' >> main.py
echo '# Configure CORS' >> main.py
echo 'app.add_middleware(' >> main.py
echo '    CORSMiddleware,' >> main.py
echo '    allow_origins=settings.CORS_ORIGINS,' >> main.py
echo '    allow_credentials=True,' >> main.py
echo '    allow_methods=["*"],' >> main.py
echo '    allow_headers=["*"],' >> main.py
echo ')' >> main.py
echo '' >> main.py
echo '# Include routers' >> main.py
echo 'app.include_router(api_router, prefix="/api")' >> main.py
echo '' >> main.py
echo '@app.get("/")' >> main.py
echo 'async def root():' >> main.py
echo '    """' >> main.py
echo '    Root endpoint - API information' >> main.py
echo '    """' >> main.py
echo '    return {' >> main.py
echo "        'message': f'$DEFAULT_GREETING {settings.PROJECT_NAME} API'," >> main.py
echo "        'version': '$API_VERSION'," >> main.py
echo "        'docs': '/docs'," >> main.py
echo "        'redoc': '/redoc'" >> main.py
echo '    }' >> main.py
echo '' >> main.py
echo '@app.get("/health")' >> main.py
echo 'async def health_check():' >> main.py
echo '    """' >> main.py
echo '    Health check endpoint' >> main.py
echo '    """' >> main.py
echo '    return {' >> main.py
echo "        'status': 'healthy'," >> main.py
echo "        'project': '$project_name'" >> main.py
echo '    }' >> main.py
echo '' >> main.py
echo 'if __name__ == "__main__":' >> main.py
echo '    import uvicorn' >> main.py
echo '    uvicorn.run(' >> main.py
echo '        "main:app",' >> main.py
echo '        host="0.0.0.0",' >> main.py
echo "        port=$port," >> main.py
echo '        reload=True' >> main.py
echo '    )' >> main.py

print_success "main.py created"

# =============================================================================
# Step 7: Create configuration files
# =============================================================================

# Create .env file
echo "# Environment variables for $project_name" > .env
echo "PROJECT_NAME=$project_name" >> .env
echo "ENVIRONMENT=development" >> .env
echo "DEBUG=true" >> .env
echo "PORT=$port" >> .env
echo "CORS_ORIGINS=[\"http://localhost:3000\",\"http://localhost:$port\"]" >> .env

print_success ".env created"

# Create .env.example
echo "# Environment variables for $project_name (example)" > .env.example
echo "PROJECT_NAME=$project_name" >> .env.example
echo "ENVIRONMENT=production" >> .env.example
echo "DEBUG=false" >> .env.example
echo "PORT=$port" >> .env.example
echo "CORS_ORIGINS=[\"https://yourdomain.com\"]" >> .env.example

print_success ".env.example created"

# Create app/core/config.py
mkdir -p app/core
echo '"""' > app/core/config.py
echo 'Configuration management using Pydantic settings.' >> app/core/config.py
echo '"""' >> app/core/config.py
echo 'from typing import List' >> app/core/config.py
echo 'from pydantic_settings import BaseSettings' >> app/core/config.py
echo 'from pydantic import AnyHttpUrl, validator' >> app/core/config.py
echo 'import json' >> app/core/config.py
echo '' >> app/core/config.py
echo '' >> app/core/config.py
echo 'class Settings(BaseSettings):' >> app/core/config.py
echo "    PROJECT_NAME: str = \"$project_name\"" >> app/core/config.py
echo '    ENVIRONMENT: str = "development"' >> app/core/config.py
echo '    DEBUG: bool = True' >> app/core/config.py
echo "    PORT: int = $port" >> app/core/config.py
echo '' >> app/core/config.py
echo '    # CORS configuration' >> app/core/config.py
echo '    CORS_ORIGINS: List[AnyHttpUrl] = []' >> app/core/config.py
echo '' >> app/core/config.py
echo '    @validator("CORS_ORIGINS", pre=True)' >> app/core/config.py
echo '    def parse_cors_origins(cls, v):' >> app/core/config.py
echo '        """Parse CORS origins from string or list"""' >> app/core/config.py
echo '        if isinstance(v, str):' >> app/core/config.py
echo '            try:' >> app/core/config.py
echo '                return json.loads(v)' >> app/core/config.py
echo '            except json.JSONDecodeError:' >> app/core/config.py
echo '                return [v]' >> app/core/config.py
echo '        return v' >> app/core/config.py
echo '' >> app/core/config.py
echo '    class Config:' >> app/core/config.py
echo '        env_file = ".env"' >> app/core/config.py
echo '        case_sensitive = True' >> app/core/config.py
echo '' >> app/core/config.py
echo '' >> app/core/config.py
echo 'settings = Settings()' >> app/core/config.py

print_success "app/core/config.py created"

# Create app/api/routes.py
mkdir -p app/api
echo '"""' > app/api/routes.py
echo 'Main API router that includes all endpoint modules.' >> app/api/routes.py
echo '"""' >> app/api/routes.py
echo 'from fastapi import APIRouter' >> app/api/routes.py
echo '' >> app/api/routes.py
echo '' >> app/api/routes.py
echo '# Create main router' >> app/api/routes.py
echo 'api_router = APIRouter()' >> app/api/routes.py
echo '' >> app/api/routes.py
echo '' >> app/api/routes.py
echo '@api_router.get("/info")' >> app/api/routes.py
echo 'async def api_info():' >> app/api/routes.py
echo '    """' >> app/api/routes.py
echo '    Get API information' >> app/api/routes.py
echo '    """' >> app/api/routes.py
echo '    return {' >> app/api/routes.py
echo '        "name": "'$project_name' API",' >> app/api/routes.py
echo '        "version": "1.0.0",' >> app/api/routes.py
echo '        "endpoints": [' >> app/api/routes.py
echo '            "/api/info - This info",' >> app/api/routes.py
echo '            "/api/health - Health check",' >> app/api/routes.py
echo '            "/api/items - Example endpoints (coming soon)"' >> app/api/routes.py
echo '        ]' >> app/api/routes.py
echo '    }' >> app/api/routes.py
echo '' >> app/api/routes.py
echo '' >> app/api/routes.py
echo '@api_router.get("/health")' >> app/api/routes.py
echo 'async def api_health():' >> app/api/routes.py
echo '    """' >> app/api/routes.py
echo '    API health check' >> app/api/routes.py
echo '    """' >> app/api/routes.py
echo '    return {' >> app/api/routes.py
echo '        "status": "healthy",' >> app/api/routes.py
echo '        "timestamp": "import time; time.time()"  # Placeholder' >> app/api/routes.py
echo '    }' >> app/api/routes.py

print_success "app/api/routes.py created"

# =============================================================================
# Step 8: Docker support (if selected)
# =============================================================================

if test "$include_docker" = true
    echo ""
    print_info "Adding Docker support..."
    
    # Add gunicorn to requirements.txt
    echo "gunicorn>=21.2.0" >> requirements.txt
    
    # Create Dockerfile
    echo 'FROM python:3.11-slim' > Dockerfile
    echo '' >> Dockerfile
    echo 'WORKDIR /app' >> Dockerfile
    echo '' >> Dockerfile
    echo '# Install system dependencies' >> Dockerfile
    echo 'RUN apt-get update && apt-get install -y \\' >> Dockerfile
    echo '    gcc \\' >> Dockerfile
    echo '    && rm -rf /var/lib/apt/lists/*' >> Dockerfile
    echo '' >> Dockerfile
    echo '# Copy requirements first (for better caching)' >> Dockerfile
    echo 'COPY requirements.txt .' >> Dockerfile
    echo 'RUN pip install --no-cache-dir -r requirements.txt' >> Dockerfile
    echo '' >> Dockerfile
    echo '# Copy application code' >> Dockerfile
    echo 'COPY . .' >> Dockerfile
    echo '' >> Dockerfile
    echo '# Create non-root user' >> Dockerfile
    echo 'RUN useradd -m -u 1000 appuser && chown -R appuser:appuser /app' >> Dockerfile
    echo 'USER appuser' >> Dockerfile
    echo '' >> Dockerfile
    echo '# Expose port' >> Dockerfile
    echo "EXPOSE $port" >> Dockerfile
    echo '' >> Dockerfile
    echo '# Run the application' >> Dockerfile
    echo 'CMD ["uvicorn", "main:app", "--host", "0.0.0.0", "--port", "'$port'"]' >> Dockerfile
    
    print_success "Dockerfile created"
    
    # Create docker-compose.yml
    echo 'services:' > docker-compose.yml
    echo "  $docker_name:" >> docker-compose.yml
    echo '    build: .' >> docker-compose.yml
    echo "    container_name: $docker_name" >> docker-compose.yml
    echo "    ports:" >> docker-compose.yml
    echo "      - \"$port:$port\"" >> docker-compose.yml
    echo '    environment:' >> docker-compose.yml
    echo '      - ENVIRONMENT=development' >> docker-compose.yml
    echo '      - DEBUG=true' >> docker-compose.yml
    echo '    volumes:' >> docker-compose.yml
    echo '      - ./app:/app/app' >> docker-compose.yml
    echo '      - ./main.py:/app/main.py' >> docker-compose.yml
    echo '    restart: unless-stopped' >> docker-compose.yml
    echo '    healthcheck:' >> docker-compose.yml
    echo '      test: ["CMD", "curl", "-f", "http://localhost:'$port'/health"]' >> docker-compose.yml
    echo '      interval: 30s' >> docker-compose.yml
    echo '      timeout: 10s' >> docker-compose.yml
    echo '      retries: 3' >> docker-compose.yml
    echo '      start_period: 10s' >> docker-compose.yml
    
    print_success "docker-compose.yml created (lowercase: $docker_name)"
    
    # Create .dockerignore
    echo '__pycache__' > .dockerignore
    echo '*.pyc' >> .dockerignore
    echo '.env' >> .dockerignore
    echo '.git' >> .dockerignore
    echo '.gitignore' >> .dockerignore
    echo 'Dockerfile' >> .dockerignore
    echo 'docker-compose.yml' >> .dockerignore
    echo 'README.md' >> .dockerignore
    echo 'venv' >> .dockerignore
    echo 'env' >> .dockerignore
    echo '.venv' >> .dockerignore
    
    print_success ".dockerignore created"
    
    # Create docker-run.sh script
    echo '#!/bin/bash' > scripts/docker-run.sh
    echo '' >> scripts/docker-run.sh
    echo '# Script to build and run the Docker container' >> scripts/docker-run.sh
    echo '# Generated by new-fastapi.fish' >> scripts/docker-run.sh
    echo '' >> scripts/docker-run.sh
    echo "# Original project name: $project_name" >> scripts/docker-run.sh
    echo "PROJECT_NAME=\"$docker_name\"" >> scripts/docker-run.sh
    echo "PORT=\"$port\"" >> scripts/docker-run.sh
    echo '' >> scripts/docker-run.sh
    echo '# Get the absolute path of the current directory' >> scripts/docker-run.sh
    echo 'CURRENT_DIR=$(pwd)' >> scripts/docker-run.sh
    echo '' >> scripts/docker-run.sh
    echo '# Build the image' >> scripts/docker-run.sh
    echo 'echo "🔨 Building Docker image: $PROJECT_NAME"' >> scripts/docker-run.sh
    echo 'docker build -t $PROJECT_NAME .' >> scripts/docker-run.sh
    echo 'if [ $? -ne 0 ]; then' >> scripts/docker-run.sh
    echo '    echo "❌ Docker build failed"' >> scripts/docker-run.sh
    echo '    exit 1' >> scripts/docker-run.sh
    echo 'fi' >> scripts/docker-run.sh
    echo '' >> scripts/docker-run.sh
    echo '# Stop and remove existing container if running' >> scripts/docker-run.sh
    echo 'if docker ps -a --format "{{.Names}}" | grep -q "^$PROJECT_NAME$"; then' >> scripts/docker-run.sh
    echo '    echo "🛑 Stopping existing container..."' >> scripts/docker-run.sh
    echo '    docker stop $PROJECT_NAME >/dev/null 2>&1' >> scripts/docker-run.sh
    echo '    docker rm $PROJECT_NAME >/dev/null 2>&1' >> scripts/docker-run.sh
    echo 'fi' >> scripts/docker-run.sh
    echo '' >> scripts/docker-run.sh
    echo '# Run the container' >> scripts/docker-run.sh
    echo 'echo "🚀 Starting container on port $PORT..."' >> scripts/docker-run.sh
    echo '' >> scripts/docker-run.sh
    echo '# Check if app directory exists' >> scripts/docker-run.sh
    echo 'if [ ! -d "$CURRENT_DIR/app" ]; then' >> scripts/docker-run.sh
    echo '    echo "⚠️  Warning: app directory not found, creating empty mount point"' >> scripts/docker-run.sh
    echo '    mkdir -p "$CURRENT_DIR/app"' >> scripts/docker-run.sh
    echo 'fi' >> scripts/docker-run.sh
    echo '' >> scripts/docker-run.sh
    echo '# Run with proper volume mounts' >> scripts/docker-run.sh
    echo 'docker run -d \\' >> scripts/docker-run.sh
    echo '  --name $PROJECT_NAME \\' >> scripts/docker-run.sh
    echo '  -p $PORT:$PORT \\' >> scripts/docker-run.sh
    echo '  -v "$CURRENT_DIR/app:/app/app" \\' >> scripts/docker-run.sh
    echo '  -v "$CURRENT_DIR/main.py:/app/main.py" \\' >> scripts/docker-run.sh
    echo '  --restart unless-stopped \\' >> scripts/docker-run.sh
    echo '  $PROJECT_NAME' >> scripts/docker-run.sh
    echo '' >> scripts/docker-run.sh
    echo '# Check if container started successfully' >> scripts/docker-run.sh
    echo 'if [ $? -eq 0 ]; then' >> scripts/docker-run.sh
    echo '    echo "✅ Container started successfully!"' >> scripts/docker-run.sh
    echo '    echo "📊 Container status:"' >> scripts/docker-run.sh
    echo '    docker ps --filter "name=$PROJECT_NAME" --format "table {{.Names}}\t{{.Status}}\t{{.Ports}}"' >> scripts/docker-run.sh
    echo '    echo ""' >> scripts/docker-run.sh
    echo '    echo "🌐 Your API is running at: http://localhost:$PORT"' >> scripts/docker-run.sh
    echo '    echo "📚 API Docs: http://localhost:$PORT/docs"' >> scripts/docker-run.sh
    echo '    echo "📝 View logs: docker logs $PROJECT_NAME"' >> scripts/docker-run.sh
    echo '    echo "🛑 Stop container: docker stop $PROJECT_NAME"' >> scripts/docker-run.sh
    echo 'else' >> scripts/docker-run.sh
    echo '    echo "❌ Failed to start container"' >> scripts/docker-run.sh
    echo '    exit 1' >> scripts/docker-run.sh
    echo 'fi' >> scripts/docker-run.sh
    
    chmod +x scripts/docker-run.sh
    print_success "scripts/docker-run.sh created (with proper path handling)"
    
    # Create a test script
    echo '#!/usr/bin/env fish' > scripts/test.fish
    echo '' >> scripts/test.fish
    echo '# Quick test script for the API' >> scripts/test.fish
    echo '' >> scripts/test.fish
    echo "set PORT $port" >> scripts/test.fish
    echo '' >> scripts/test.fish
    echo 'echo "🧪 Testing API endpoints..."' >> scripts/test.fish
    echo '' >> scripts/test.fish
    echo '# Test root endpoint' >> scripts/test.fish
    echo 'echo -n "Testing / endpoint... "' >> scripts/test.fish
    echo 'if curl -s "http://localhost:$PORT/" | grep -q "message";' >> scripts/test.fish
    echo '    echo "✅"' >> scripts/test.fish
    echo 'else' >> scripts/test.fish
    echo '    echo "❌"' >> scripts/test.fish
    echo 'end' >> scripts/test.fish
    echo '' >> scripts/test.fish
    echo '# Test health endpoint' >> scripts/test.fish
    echo 'echo -n "Testing /health endpoint... "' >> scripts/test.fish
    echo 'if curl -s "http://localhost:$PORT/health" | grep -q "healthy";' >> scripts/test.fish
    echo '    echo "✅"' >> scripts/test.fish
    echo 'else' >> scripts/test.fish
    echo '    echo "❌"' >> scripts/test.fish
    echo 'end' >> scripts/test.fish
    echo '' >> scripts/test.fish
    echo '# Test API info endpoint' >> scripts/test.fish
    echo 'echo -n "Testing /api/info endpoint... "' >> scripts/test.fish
    echo 'if curl -s "http://localhost:$PORT/api/info" | grep -q "version";' >> scripts/test.fish
    echo '    echo "✅"' >> scripts/test.fish
    echo 'else' >> scripts/test.fish
    echo '    echo "❌"' >> scripts/test.fish
    echo 'end' >> scripts/test.fish
    echo '' >> scripts/test.fish
    echo 'echo ""' >> scripts/test.fish
    echo 'echo "📊 To see full response, run:"' >> scripts/test.fish
    echo 'echo "  curl http://localhost:$PORT/"' >> scripts/test.fish
    echo 'echo "  curl http://localhost:$PORT/health"' >> scripts/test.fish
    echo 'echo "  curl http://localhost:$PORT/api/info"' >> scripts/test.fish
    
    chmod +x scripts/test.fish
    print_success "scripts/test.fish created"
    
    print_success "Docker setup complete"
else
    print_info "Skipping Docker setup"
end

## =============================================================================
# Step 9: Git initialization (if selected)
# =============================================================================

if test "$include_git" = true
    echo ""
    print_info "Initializing Git repository..."
    
    # Initialize git
    git init > /dev/null 2>&1
    if test $status -eq 0
        print_success "Git repository initialized"
        
        # Add all files
        git add .
        print_success "Files added to git"
        
        # Initial commit
        git commit -m "API Initial Build" > /dev/null 2>&1
        if test $status -eq 0
            print_success "Initial commit created: 'API Initial Build'"
            
            # Create and checkout dev branch if selected
            if test "$create_dev_branch" = true
                # Create dev branch
                git branch dev > /dev/null 2>&1
                if test $status -eq 0
                    print_success "Branch 'dev' created"
                    
                    # Switch to dev branch
                    git checkout dev > /dev/null 2>&1
                    if test $status -eq 0
                        print_success "Switched to branch 'dev'"
                        
                        # Show current branch
                        set current_branch (git branch --show-current)
                        print_info "Currently on branch: $current_branch"
                    else
                        print_error "Failed to checkout 'dev' branch"
                        # Stay on main/master
                    end
                else
                    print_error "Failed to create 'dev' branch"
                end
            else
                set current_branch (git branch --show-current)
                print_info "Currently on branch: $current_branch"
            end
        else
            print_error "Failed to create initial commit"
        end
    else
        print_error "Failed to initialize Git repository"
    end
end

# =============================================================================
# Step 10: Create README and final summary
# =============================================================================

echo ""
print_info "Creating README and finalizing..."

# Create README.md
echo "# $project_name" > README.md
echo "" >> README.md
echo "FastAPI project generated with the FastAPI Project Generator." >> README.md
echo "" >> README.md
echo "## 🚀 Quick Start" >> README.md
echo "" >> README.md
echo "### Local Development" >> README.md
echo '```bash' >> README.md
echo "# Create virtual environment" >> README.md
echo "python3 -m venv venv" >> README.md
echo "source venv/bin/activate  # On Windows: venv\\Scripts\\activate" >> README.md
echo "" >> README.md
echo "# Install dependencies" >> README.md
echo "pip install -r requirements.txt" >> README.md
echo "" >> README.md
echo "# Run the application" >> README.md
echo "uvicorn main:app --reload --port $port" >> README.md
echo '```' >> README.md
echo "" >> README.md

if test "$include_docker" = true
    echo "### Docker Development" >> README.md
    echo '```bash' >> README.md
    echo "# Build and run with Docker" >> README.md
    echo "./scripts/docker-run.sh" >> README.md
    echo "" >> README.md
    echo "# Or using docker-compose" >> README.md
    echo "docker-compose up -d" >> README.md
    echo "" >> README.md
    echo "# Test the API" >> README.md
    echo "./scripts/test.fish" >> README.md
    echo '```' >> README.md
    echo "" >> README.md
end

if test "$include_git" = true
    echo "### Git Repository" >> README.md
    echo '```bash' >> README.md
    echo "# Repository initialized with:" >> README.md
    echo "# - Initial commit: 'API Initial Build'" >> README.md
    if test "$create_dev_branch" = true
        echo "# - Branch 'dev' created and active" >> README.md
    else
        echo "# - On main/master branch" >> README.md
    end
    echo '```' >> README.md
    echo "" >> README.md
end

echo "### API Documentation" >> README.md
echo "Once running, visit:" >> README.md
echo "- Swagger UI: http://localhost:$port/docs" >> README.md
echo "- ReDoc: http://localhost:$port/redoc" >> README.md
echo "" >> README.md
echo "## 📁 Project Structure" >> README.md
echo '```' >> README.md
echo "$project_name/" >> README.md
echo "├── app/" >> README.md
echo "│   ├── api/" >> README.md
echo "│   │   └── routes.py      # API endpoints" >> README.md
echo "│   ├── core/" >> README.md
echo "│   │   └── config.py       # Configuration" >> README.md
echo "│   ├── models/             # Database models" >> README.md
echo "│   ├── schemas/            # Pydantic schemas" >> README.md
echo "│   ├── services/           # Business logic" >> README.md
echo "│   └── utils/              # Utility functions" >> README.md
echo "├── tests/                   # Test files" >> README.md
echo "├── scripts/                 # Helper scripts" >> README.md
echo "│   ├── docker-run.sh       # Docker run script" >> README.md
echo "│   ├── run.fish             # Fish run script" >> README.md
echo "│   └── test.fish            # Test script" >> README.md
echo "├── main.py                  # Application entry" >> README.md
echo "├── requirements.txt         # Dependencies" >> README.md
echo "├── .env                     # Environment variables" >> README.md
echo "├── .env.example             # Example env file" >> README.md
echo "└── README.md                # This file" >> README.md

if test "$include_docker" = true
    echo "├── Dockerfile              # Docker configuration" >> README.md
    echo "├── docker-compose.yml      # Docker Compose config" >> README.md
    echo "└── .dockerignore           # Docker ignore file" >> README.md
end

if test "$include_git" = true
    echo "├── .git/                   # Git repository" >> README.md
    echo "└── .gitignore              # Git ignore file" >> README.md
end

echo '```' >> README.md

print_success "README.md created"

# Create .gitignore
echo "# Python" > .gitignore
echo "__pycache__/" >> .gitignore
echo "*.py[cod]" >> .gitignore
echo "*\$py.class" >> .gitignore
echo "*.so" >> .gitignore
echo ".Python" >> .gitignore
echo "env/" >> .gitignore
echo "venv/" >> .gitignore
echo "ENV/" >> .gitignore
echo "env.bak/" >> .gitignore
echo "venv.bak/" >> .gitignore
echo "" >> .gitignore
echo "# IDE" >> .gitignore
echo ".vscode/" >> .gitignore
echo ".idea/" >> .gitignore
echo "*.swp" >> .gitignore
echo "*.swo" >> .gitignore
echo "" >> .gitignore
echo "# Environment" >> .gitignore
echo ".env" >> .gitignore
echo ".env.local" >> .gitignore
echo ".env.*.local" >> .gitignore
echo "" >> .gitignore
echo "# Docker" >> .gitignore
echo "docker-compose.override.yml" >> .gitignore
echo "" >> .gitignore
echo "# Logs" >> .gitignore
echo "*.log" >> .gitignore

print_success ".gitignore created"

# =============================================================================
# Step 11: Create run script for fish
# =============================================================================

echo '#!/usr/bin/env fish' > scripts/run.fish
echo '' >> scripts/run.fish
echo '# Quick run script for fish shell' >> scripts/run.fish
echo '' >> scripts/run.fish
echo 'if not test -d venv' >> scripts/run.fish
echo '    echo "📦 Creating virtual environment..."' >> scripts/run.fish
echo '    python3 -m venv venv' >> scripts/run.fish
echo 'end' >> scripts/run.fish
echo '' >> scripts/run.fish
echo 'source venv/bin/activate.fish' >> scripts/run.fish
echo '' >> scripts/run.fish
echo 'echo "📦 Installing/updating dependencies..."' >> scripts/run.fish
echo 'pip install -r requirements.txt' >> scripts/run.fish
echo '' >> scripts/run.fish
echo "echo \"🚀 Starting server on port $port...\"" >> scripts/run.fish
echo "uvicorn main:app --reload --port $port" >> scripts/run.fish

chmod +x scripts/run.fish
print_success "scripts/run.fish created (with auto-install)"

# =============================================================================
# Step 12: Final summary
# =============================================================================

echo ""
echo "╔══════════════════════════════════════════════════════════════╗"
echo "║                     🎉 PROJECT CREATED!                       ║"
echo "╚══════════════════════════════════════════════════════════════╝"
echo ""

print_success "Project: $project_name"
print_success "Location: $project_dir"
print_success "Port: $port"

if test "$include_docker" = true
    print_success "Docker: Enabled (using lowercase: $docker_name)"
else
    print_info "Docker: Disabled"
end

if test "$include_git" = true
    print_success "Git: Initialized"
    if test "$create_dev_branch" = true
        print_success "Branch: dev (active)"
    else
        print_success "Branch: main/master (active)"
    end
else
    print_info "Git: Disabled"
end

echo ""
echo "📋 Next steps:"
echo ""
echo "  cd \"$project_dir\""
echo ""

if test "$include_docker" = true
    echo "  🐳 Run with Docker:"
    echo "    ./scripts/docker-run.sh"
    echo "    # or"
    echo "    docker-compose up -d"
    echo "    ./scripts/test.fish  # Test the API"
    echo ""
end

echo "  🏃 Run locally:"
echo "    ./scripts/run.fish"
echo ""
echo "  📚 API Documentation:"
echo "    http://localhost:$port/docs"
echo "    http://localhost:$port/redoc"
echo ""
echo "  📝 Edit your project:"
echo "    code ."
echo ""
echo "✨ Happy coding! ✨"

# Script ends here - user stays in original directory
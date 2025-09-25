#!/bin/bash

# Quick Fix Script for Jenkins Pipeline Issues
# This script resolves common pipeline problems

set -e

echo "🔧 Jenkins Pipeline Quick Fix"
echo "=============================="

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

print_status() {
    echo -e "${GREEN}✅ $1${NC}"
}

print_warning() {
    echo -e "${YELLOW}⚠️  $1${NC}"
}

print_error() {
    echo -e "${RED}❌ $1${NC}"
}

# Function to check and fix port conflicts
fix_port_conflicts() {
    echo "🔍 Checking for port conflicts..."
    
    # Check if port 27017 is in use
    if lsof -i :27017 >/dev/null 2>&1; then
        print_warning "Port 27017 is in use"
        
        # Find and stop MongoDB containers
        MONGO_CONTAINERS=$(docker ps --format "table {{.Names}}" | grep -E "(mongo|mongodb)" | head -5 || true)
        
        if [ ! -z "$MONGO_CONTAINERS" ]; then
            echo "Found MongoDB containers:"
            echo "$MONGO_CONTAINERS"
            
            read -p "Stop these containers temporarily? (y/n): " -n 1 -r
            echo
            if [[ $REPLY =~ ^[Yy]$ ]]; then
                echo "$MONGO_CONTAINERS" | xargs -r docker stop
                print_status "Stopped conflicting containers"
                
                # Store stopped containers for later restart
                echo "$MONGO_CONTAINERS" > /tmp/stopped_containers.txt
                print_warning "Container names saved to /tmp/stopped_containers.txt"
                echo "You can restart them later with: cat /tmp/stopped_containers.txt | xargs docker start"
            fi
        fi
    else
        print_status "Port 27017 is available"
    fi
}

# Function to clean up Docker resources
cleanup_docker() {
    echo "🧹 Cleaning up Docker resources..."
    
    # Clean up test containers
    docker compose -f docker-compose.test.yml down -v >/dev/null 2>&1 || true
    docker compose down -v >/dev/null 2>&1 || true
    
    # Clean up dangling images and containers
    docker system prune -f >/dev/null 2>&1 || true
    
    print_status "Docker cleanup completed"
}

# Function to verify Docker is working
verify_docker() {
    echo "🐳 Verifying Docker setup..."
    
    if ! docker info >/dev/null 2>&1; then
        print_error "Docker daemon is not running"
        echo "Please start Docker: sudo systemctl start docker"
        exit 1
    fi
    
    if ! docker compose version >/dev/null 2>&1; then
        print_error "Docker Compose is not available"
        exit 1
    fi
    
    print_status "Docker is working properly"
}

# Function to check Jenkins permissions
check_permissions() {
    echo "🔐 Checking permissions..."
    
    # Check if current user can run Docker
    if ! docker ps >/dev/null 2>&1; then
        print_warning "Current user may not have Docker permissions"
        echo "Add user to docker group: sudo usermod -aG docker \$USER"
        echo "Then logout and login again"
    else
        print_status "Docker permissions are correct"
    fi
}

# Function to restart stopped containers
restart_containers() {
    if [ -f /tmp/stopped_containers.txt ]; then
        echo "🔄 Do you want to restart previously stopped containers?"
        read -p "Restart containers? (y/n): " -n 1 -r
        echo
        if [[ $REPLY =~ ^[Yy]$ ]]; then
            cat /tmp/stopped_containers.txt | xargs -r docker start
            print_status "Restarted containers"
            rm /tmp/stopped_containers.txt
        fi
    fi
}

# Main execution
main() {
    verify_docker
    check_permissions
    fix_port_conflicts
    cleanup_docker
    
    echo ""
    print_status "All fixes applied successfully!"
    echo ""
    echo "📋 Next steps:"
    echo "1. Go to Jenkins: http://localhost:9090"
    echo "2. Run your pipeline: cicd-demo-pipeline"
    echo "3. Monitor the console output"
    echo ""
    echo "If you need to restart stopped containers later:"
    echo "cat /tmp/stopped_containers.txt | xargs docker start"
    
    # Offer to restart containers
    restart_containers
}

# Show help
if [[ "$1" == "--help" || "$1" == "-h" ]]; then
    echo "Jenkins Pipeline Quick Fix Script"
    echo ""
    echo "This script fixes common Jenkins pipeline issues:"
    echo "- Port 27017 conflicts (MongoDB)"
    echo "- Docker permission issues"
    echo "- Cleanup old containers and images"
    echo "- Verify Docker setup"
    echo ""
    echo "Usage: ./fix-pipeline-issues.sh"
    echo ""
    echo "Options:"
    echo "  --help, -h    Show this help message"
    echo "  --restart     Restart previously stopped containers"
    exit 0
fi

# Restart containers option
if [[ "$1" == "--restart" ]]; then
    restart_containers
    exit 0
fi

# Run main function
main "$@"
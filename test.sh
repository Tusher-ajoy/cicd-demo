#!/bin/bash
echo "=== Testing Node.js Demo Application ==="

echo "1. Testing /health endpoint..."
HEALTH_RESPONSE=$(curl -s http://localhost:3000/health)
if [[ $HEALTH_RESPONSE == *'"status":"ok"'* ]]; then
    echo "✅ Health endpoint test passed"
else
    echo "❌ Health endpoint test failed"
    exit 1
fi

echo "2. Testing user creation..."
CREATE_RESPONSE=$(curl -s -X POST -H "Content-Type: application/json" -d '{"name":"Test User 2","email":"test2@example.com"}' http://localhost:3000/users)
if [[ $CREATE_RESPONSE == *'"name":"Test User 2"'* ]]; then
    echo "✅ User creation test passed"
else
    echo "❌ User creation test failed"
    exit 1
fi

echo "3. Testing user retrieval..."
USERS_RESPONSE=$(curl -s http://localhost:3000/users)
if [[ $USERS_RESPONSE == *'"email":"admin@example.com"'* ]] && [[ $USERS_RESPONSE == *'"email":"test2@example.com"'* ]]; then
    echo "✅ User retrieval test passed"
else
    echo "❌ User retrieval test failed"
    exit 1
fi

echo ""
echo "🎉 All tests passed! Application is working correctly."
echo ""
echo "📋 Summary:"
echo "- Express server running on http://localhost:3000"
echo "- MongoDB connected and working"
echo "- Migration script created admin user"
echo "- REST API endpoints working"
echo "- Docker services running"